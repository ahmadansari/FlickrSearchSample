//
//  DatabaseContext.m
//  FlickrApp
//
//  Created by Ahmad Ansari on 11/10/2017.
//  Copyright © 2017 Ahmad Ansari. All rights reserved.
//

#import "DatabaseContext.h"

@implementation DatabaseContext

@synthesize managedObjectContext = _managedObjectContext;
@synthesize writerManagedObjectContext = _writerManagedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

#pragma mark -
#pragma mark ARC Singleton Implementation
static DatabaseContext *sharedInstance = nil;
+ (DatabaseContext *)sharedContext {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DatabaseContext alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [super allocWithZone:zone];
    });
    return sharedInstance;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

#pragma mark - Methods
- (void)saveContext {
    return [[DatabaseContext sharedContext] saveContext:nil];
}

- (void)saveContext:(void (^)(void))completion {
    __block NSManagedObjectContext *writerObjectContext =
    [[DatabaseContext sharedContext] writerManagedObjectContext];
    __block NSManagedObjectContext *managedObjectContext =
    [[DatabaseContext sharedContext] managedObjectContext];
    [managedObjectContext performBlock:^{
        // Save the context.
        NSError *error = nil;
        if ([managedObjectContext hasChanges] &&
            ![managedObjectContext save:&error]) {
            DDLogError(@"Error in Saving MOC: %@", [error description]);
        }
        
        [writerObjectContext performBlock:^{
            // Save the context.
            NSError *error = nil;
            if ([writerObjectContext hasChanges] &&
                ![writerObjectContext save:&error]) {
                DDLogError(@"Error in Saving MOC: %@", [error description]);
            }
            if (completion) {
                dispatch_after(
                               dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)),
                               dispatch_get_main_queue(), ^{
                                   completion();
                               });
            }
        }]; // writer
    }];   // main
}

- (void)resetCoreDataStack {
    @synchronized(self) {
        DDLogInfo(@"resetCoreDataStack");
        
        [_managedObjectContext reset];
        [_writerManagedObjectContext reset];
        [_managedObjectContext performBlockAndWait:^{
            NSArray *persistentStores = self.persistentStoreCoordinator.persistentStores;
            for (NSPersistentStore *store in persistentStores) {
                [self.persistentStoreCoordinator removePersistentStore:store error:nil];
                [[NSFileManager defaultManager]removeItemAtURL:store.URL error:nil];
            }
            
            _managedObjectContext = nil;
            _writerManagedObjectContext = nil;
            _persistentStoreCoordinator = nil;
            
            // Create Read MOC
            [[DatabaseContext sharedContext] managedObjectContext];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:kNotifCoreDataResetPerformed object:nil];
            });
        }];
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the
// persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    _managedObjectContext = [[NSManagedObjectContext alloc]
                             initWithConcurrencyType:NSMainQueueConcurrencyType];
    _managedObjectContext.parentContext = [self writerManagedObjectContext];
    
    return _managedObjectContext;
}

// Parent context
- (NSManagedObjectContext *)writerManagedObjectContext {
    if (_writerManagedObjectContext != nil) {
        return _writerManagedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _writerManagedObjectContext = [[NSManagedObjectContext alloc]
                                       initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_writerManagedObjectContext setPersistentStoreCoordinator:coordinator];
        _writerManagedObjectContext.mergePolicy =
        NSMergeByPropertyObjectTrumpMergePolicy;
    }
    return _writerManagedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's
// model.
- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSString *path = [[NSBundle mainBundle] pathForResource:kXCDataModelFile
                                                     ofType:kXCDataModelType];
    NSURL *momURL = [NSURL fileURLWithPath:path];
    _managedObjectModel =
    [[NSManagedObjectModel alloc] initWithContentsOfURL:momURL];
    return self.managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's
// store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create Persistence Store
    NSURL *storeURL = [[self applicationDocumentsDirectory]
                       URLByAppendingPathComponent:kXCDataSQLiteFile];
    
    // Lightweight Migration Options
    NSDictionary *options = [NSDictionary
                             dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],
                             NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES],
                             NSInferMappingModelAutomaticallyOption, nil];
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
                                   initWithManagedObjectModel:[self managedObjectModel]];
    
    NSError *error;
    if (![self.persistentStoreCoordinator
          addPersistentStoreWithType:NSSQLiteStoreType
          configuration:nil
          URL:storeURL
          options:options
          error:&error]) {
        // Update to handle the error appropriately.
        DDLogError(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    return self.persistentStoreCoordinator;
}

#pragma mark -
#pragma mark Application's documents directory
/**
 *  Returns the URL to the application's Documents directory.
 *
 *  @return URL
 */
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                   inDomains:NSUserDomainMask]
            lastObject];
}

#pragma mark -
#pragma mark Faulting

+ (void)turnObjectIntoFault:(NSManagedObjectID *)objectID {
    // Turn Fault On Core Data Object
    if (objectID != nil) {
        NSError *error = nil;
        NSManagedObject *_object =
        [[DatabaseContext sharedContext]
         .managedObjectContext existingObjectWithID:objectID
         error:&error];
        if (_object != nil) {
            // DLog(@"Turning Managed Object into Fault: %@", _object);
            [[DatabaseContext sharedContext]
             .managedObjectContext refreshObject:_object
             mergeChanges:NO];
        }
    }
}

+ (void)turnObjectIntoFault:(NSManagedObjectID *)objectID
                    context:(NSManagedObjectContext *)managedObjectContext {
    // Remove Object From CoreData
    if (objectID != nil) {
        NSError *error = nil;
        NSManagedObject *_object =
        [managedObjectContext existingObjectWithID:objectID error:&error];
        if (_object != nil) {
            // DLog(@"Turning Managed Object into Fault: %@", _object);
            [managedObjectContext refreshObject:_object mergeChanges:NO];
        }
    }
}

#pragma mark - NSManagedObject Deletion
+ (void)deleteManagedObjectFromCoreDataWithID:(NSManagedObjectID *)objectID {
    if (objectID) {
        @autoreleasepool {
            __block NSManagedObjectContext *managedObjectContext =
            [[DatabaseContext sharedContext] managedObjectContext];
            __block NSManagedObjectContext *writerObjectContext =
            [[DatabaseContext sharedContext] writerManagedObjectContext];
            __block NSManagedObjectContext *temporaryContext =
            [[NSManagedObjectContext alloc]
             initWithConcurrencyType:NSPrivateQueueConcurrencyType];
            temporaryContext.parentContext = managedObjectContext;
            [temporaryContext performBlock:^{
                
                [self deleteManagedObjectFromCoreDataWithObjectID:objectID
                                                          context:temporaryContext];
                
                [managedObjectContext performBlock:^{
                    // Save the context.
                    NSError *error = nil;
                    if ([managedObjectContext hasChanges] &&
                        (![managedObjectContext save:&error])) {
                        DDLogError(@"Error in Saving MOC: %@", [error description]);
                    }
                    [writerObjectContext performBlock:^{
                        // Save the context.
                        NSError *error = nil;
                        if ([writerObjectContext hasChanges] &&
                            (![writerObjectContext save:&error])) {
                            DDLogError(@"Error in Saving MOC: %@", [error description]);
                        }
                    }]; // writer
                }];   // main
            }];     // parent
        }
    }
}

+ (void)deleteManagedObjectFromCoreDataWithID:(NSManagedObjectID *)objectID
                                      context:(NSManagedObjectContext *)
managedObjectContext {
    // Remove Object From CoreData
    if (objectID != nil) {
        // Creating managed objects
        NSError *error = nil;
        NSManagedObject *_object =
        [managedObjectContext existingObjectWithID:objectID error:&error];
        if (_object != nil) {
            [managedObjectContext deleteObject:_object];
            
            NSError *error = nil;
            DDLogDebug(@"Saving to PSC");
            if ([managedObjectContext hasChanges] &&
                (![managedObjectContext save:&error])) {
                DDLogError(@"Error in Saving MOC: %@", [error description]);
            }
        }
    }
}

+ (void)deleteManagedObjectFromCoreDataWithObjectID:(NSManagedObjectID *)objectID
                                            context:(NSManagedObjectContext *)
managedObjectContext {
    // Remove Object From CoreData
    if (objectID != nil) {
        // Creating managed objects
        NSManagedObject *_object =
        [managedObjectContext objectWithID:objectID];
        if (_object != nil) {
            [managedObjectContext deleteObject:_object];
            
            NSError *error = nil;
            DDLogDebug(@"Saving to PSC");
            if ([managedObjectContext hasChanges] &&
                (![managedObjectContext save:&error])) {
                DDLogError(@"Error in Saving MOC: %@", [error description]);
            }
        }
    }
}
@end

