//
//  IAPProducts.m
//  TheBigClock
//
//  Created by Rao, Venkat on 2/25/15.
//  Copyright (c) 2015 Venkat Rao. All rights reserved.
//

#import "IAPProducts.h"
#import "IAPProduct.h"
#import "IAPMarketingItem.h"
#import "IAPManager.h"

#import <UIKit/UIKit.h>

@import StoreKit;

@interface IAPProducts ()

@end

@implementation IAPProducts

static NSArray<IAPProduct *> *savedProducts;

+(void)setProducts:(NSArray<IAPProduct *> *)products {
    savedProducts = products;
}

+(NSArray<IAPProduct *> *)products {
    return savedProducts;
}

+(IAPProduct *) productForIdentifier:(NSString *)identifier {
    for (IAPProduct *product in savedProducts) {
        if ([product.iapIdentifier isEqualToString:identifier]) {
            return product;
        }
    }
    return nil;
}

@end
