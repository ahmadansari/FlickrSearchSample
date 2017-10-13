//
//  Photo+CoreDataProperties.h
//  
//
//  Created by Ahmad Ansari on 12/10/2017.
//
//

#import "Photo+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Photo (CoreDataProperties)

+ (NSFetchRequest<Photo *> *)fetchRequest;

@property (nonatomic) int64_t farm;
@property (nonatomic) BOOL isFamily;
@property (nonatomic) BOOL isFriend;
@property (nonatomic) BOOL isPublic;
@property (nullable, nonatomic, copy) NSString *owner;
@property (nullable, nonatomic, copy) NSString *photoID;
@property (nullable, nonatomic, copy) NSString *secret;
@property (nullable, nonatomic, copy) NSString *server;
@property (nullable, nonatomic, copy) NSString *title;
@property (nullable, nonatomic, copy) NSDate *creationDate;

@end

NS_ASSUME_NONNULL_END
