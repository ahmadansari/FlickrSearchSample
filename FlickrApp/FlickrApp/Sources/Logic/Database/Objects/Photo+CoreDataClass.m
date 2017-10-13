//
//  Photo+CoreDataClass.m
//  
//
//  Created by Ahmad Ansari on 12/10/2017.
//
//

#import "Photo+CoreDataClass.h"

@implementation Photo

+ (NSString *)entityName {
    return @"Photo";
}

+ (void)savePhotosData:(NSDictionary *)photosData
            completion:(void (^__nullable)(BOOL error))completion {
    @autoreleasepool {
        __block BOOL success = NO;
        __block NSManagedObjectContext *managedObjectContext = [[DatabaseContext sharedContext] managedObjectContext];
        __block NSManagedObjectContext *writerObjectContext = [[DatabaseContext sharedContext] writerManagedObjectContext];
        __block NSManagedObjectContext *temporaryContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        temporaryContext.parentContext = managedObjectContext;
        [temporaryContext performBlockAndWait:^{
            @autoreleasepool {
                NSFetchRequest *request = [Photo fetchRequest];
                NSArray *allPhotos = [temporaryContext executeFetchRequest:request error:nil];
                NSArray *photosList = [[photosData objectForKey:@"photos"] objectForKey:@"photo"];
                if(!isEmpty(photosList)) {
                    for (NSDictionary *photoData in photosList) {
                        NSString *photoID = NULL_TO_NIL([photoData objectForKey:@"id"]);
                        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.photoID == %@", photoID];
                        NSArray *filteredPhoto = [allPhotos filteredArrayUsingPredicate:predicate];
                        Photo *photo = nil;
                        if(!isEmpty(filteredPhoto)) {
                            photo = [filteredPhoto lastObject];
                        } else {
                            photo = [NSEntityDescription insertNewObjectForEntityForName:[Photo entityName] inManagedObjectContext:temporaryContext];
                        }
                        
                        NSString *owner = NULL_TO_NIL([photoData objectForKey:@"owner"]);
                        NSString *secret = NULL_TO_NIL([photoData objectForKey:@"secret"]);
                        NSString *server = NULL_TO_NIL([photoData objectForKey:@"server"]);
                        NSString *title = NULL_TO_NIL([photoData objectForKey:@"title"]);
                        NSNumber *farm = NULL_TO_NIL([photoData objectForKey:@"farm"]);
                        BOOL isPublic = [NULL_TO_NIL([photoData objectForKey:@"ispublic"]) boolValue];
                        BOOL isFriend = [NULL_TO_NIL([photoData objectForKey:@"isfriend"]) boolValue];
                        BOOL isFamily = [NULL_TO_NIL([photoData objectForKey:@"isfamily"]) boolValue];
                        
                        photo.photoID = photoID;
                        photo.owner = owner;
                        photo.secret = secret;
                        photo.server = server;
                        photo.title = title;
                        photo.farm = [farm integerValue];
                        photo.isPublic = isPublic;
                        photo.isFriend = isFriend;
                        photo.isFamily = isFamily;
                        photo.creationDate = [NSDate date];
                    }
                    success = YES;
                }
            }
            
            BLOCK_EXEC(ContextSaveBlock, temporaryContext);
            
            [managedObjectContext performBlock:^{
                BLOCK_EXEC(ContextSaveBlock, managedObjectContext);
                BLOCK_EXEC(completion,success);
                [writerObjectContext performBlock:^{
                    BLOCK_EXEC(ContextSaveBlock, writerObjectContext);
                }]; // writer
            }];   // main
        }];     // parent
    }
}

//Instance Methods
- (NSString *)photoPath {
    NSString *path = nil;
    if(self.farm != NSNotFound &&
       !isEmpty(self.server) &&
       !isEmpty(self.photoID) &&
       !isEmpty(self.secret)
       ) {
        path = [NSString stringWithFormat:FL_PHOTO_URL,self.farm,self.server,self.photoID,self.secret];
    }
    return path;
}

@end
