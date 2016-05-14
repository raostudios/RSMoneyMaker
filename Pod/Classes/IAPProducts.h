//
//  IAPProducts.h
//  TheBigClock
//
//  Created by Rao, Venkat on 2/25/15.
//  Copyright (c) 2015 Venkat Rao. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IAPProduct;

@interface IAPProducts : NSObject

+ (IAPProduct *)productForIdentifier:(NSString *)identifier;
+ (NSArray<IAPProduct *> *)products;
+ (void) setProducts:(NSArray<IAPProduct *> *)products;

@end
