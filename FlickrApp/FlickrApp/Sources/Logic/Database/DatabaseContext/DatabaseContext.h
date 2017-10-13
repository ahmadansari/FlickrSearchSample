//
//  DatabaseContext.h
//  FlickrApp
//
//  Created by Ahmad Ansari on 11/10/2017.
//  Copyright © 2017 Ahmad Ansari. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <stdio.h>

/*
 *  Global Managed Object Context Save Block
 */
static void (^ContextSaveBlock)(NSManagedObjectContext *) = ^(NSManagedObjectContext *context) {
    // Save the context.
    NSError *error = nil;
    if([context persistentStoreCoordinator] != nil) {
        if ([context hasChanges] && (![context save:&error])) {
            DDLogError(@"Error in Saving MOC: %@", [error description]);
        } else {
            DDLogDebug(@"Saved to PSC");
        }
    }
};

@interface DatabaseContext : NSObject

@property(readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property(readonly, strong, nonatomic) NSManagedObjectContext *writerManagedObjectContext;
@property(readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property(readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (instancetype)sharedContext;

- (void)saveContext;
- (void)saveContext:(void (^)(void))completion;
- (void)resetCoreDataStack;

+ (void)turnObjectIntoFault:(NSManagedObjectID *)objectID;
+ (void)turnObjectIntoFault:(NSManagedObjectID *)objectID
                    context:(NSManagedObjectContext *)managedObjectContext;
+ (void)deleteManagedObjectFromCoreDataWithID:(NSManagedObjectID *)objectID;
+ (void)deleteManagedObjectFromCoreDataWithID:(NSManagedObjectID *)objectID
                                      context:(NSManagedObjectContext *)
managedObjectContext;

@end

