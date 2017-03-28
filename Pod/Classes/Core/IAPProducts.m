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
#import "AppReceiptManager.h"

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

+ (NSArray<IAPProduct *> *)productsForFeature:(NSString *)featureName {
    NSMutableArray *products = [NSMutableArray new];
    
    for (IAPProduct *product in savedProducts) {
        if ([product.productIdentifier isEqualToString:featureName]) {
            [products addObject: product];
        }
    }
    
    return products;
}

+(IAPProduct *)purchasedProductForFeature:(NSString *)featureName {
    NSArray * products = [self productsForFeature: featureName];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    for (IAPProduct *product in products) {
        NSDate *expiryDate = [defaults objectForKey:[NSString stringWithFormat:defaultsExpirationKey, product.iapIdentifier]];
        if ([expiryDate compare:[NSDate date]] == NSOrderedDescending) {
            return product;
        }
    }
    
    return nil;
}


@end
