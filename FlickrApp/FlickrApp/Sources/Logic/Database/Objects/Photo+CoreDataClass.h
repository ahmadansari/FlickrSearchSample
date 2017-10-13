//
//  Photo+CoreDataClass.h
//  
//
//  Created by Ahmad Ansari on 12/10/2017.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface Photo : NSManagedObject
+ (NSString *)entityName;

+ (void)savePhotosData:(NSDictionary *)photosData
            completion:(void (^__nullable)(BOOL error))completion;


//Instance Methods
- (NSString *)photoPath;
@end

NS_ASSUME_NONNULL_END

#import "Photo+CoreDataProperties.h"
