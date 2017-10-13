//
//  Macros.h
//  FlickrApp
//
//  Created by Ahmad Ansari on 11/10/2017.
//  Copyright © 2017 Ahmad Ansari. All rights reserved.
//

#ifndef Macros_h
#define Macros_h


// Macro to Create an UIColor Object From RGB Values
#define UIColorFromHex(rgbValue)                                              \
    [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0      \
                    green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0         \
                    blue:((float)(rgbValue & 0xFF)) / 255.0                   \
                   alpha:1.0]

#define LOC(key) NSLocalizedStringFromTable(key, @"Localizable", @"")

#pragma mark - Blocks
//NULL Block / NULL Function Pointer
static void (*FP_NULL) (void) = NULL;
//Block Execution Macro
#define BLOCK_EXEC(block, ...)  if (block) { block(__VA_ARGS__); };

#pragma mark - NSObjcet Emptiness
/*!
 @discussion
 isEmpty Method Checks Data Integrity. Can be used for any NSObject type
 instance.
 Particularly usefull for NSString, NSData, NSDictionary, NSArray, NSSet, etc.
 */
#ifdef __OBJC__
static inline BOOL isEmpty(id thing) {
    return thing == nil || thing == [NSNull null] ||
    ([thing respondsToSelector:@selector(length)] &&
     [(NSData *)thing length] == 0) ||
    ([thing respondsToSelector:@selector(count)] &&
     [(NSArray *)thing count] == 0) ||
    ([thing respondsToSelector:@selector(count)] &&
     [(NSDictionary *)thing count] == 0);
}

#define NULL_TO_NIL(obj)                            \
    ({                                              \
        __typeof__(obj) __obj = (obj);              \
        __obj == [NSNull null] ? nil : obj;         \
    })

#define NIL_TO_NULL(obj)                            \
    ({                                              \
        __typeof__(obj) __obj = (obj);              \
        __obj == nil ? [NSNull null] : obj;         \
    })

#endif

#endif /* Macros_h */
