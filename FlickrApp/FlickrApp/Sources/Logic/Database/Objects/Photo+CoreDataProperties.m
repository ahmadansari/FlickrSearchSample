//
//  Photo+CoreDataProperties.m
//  
//
//  Created by Ahmad Ansari on 12/10/2017.
//
//

#import "Photo+CoreDataProperties.h"

@implementation Photo (CoreDataProperties)

+ (NSFetchRequest<Photo *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Photo"];
}

@dynamic farm;
@dynamic isFamily;
@dynamic isFriend;
@dynamic isPublic;
@dynamic owner;
@dynamic photoID;
@dynamic secret;
@dynamic server;
@dynamic title;
@dynamic creationDate;

@end
