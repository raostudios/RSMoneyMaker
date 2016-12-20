//
//  IAPItem.m
//  TheBigClock
//
//  Created by Rao, Venkat on 2/25/15.
//  Copyright (c) 2015 Venkat Rao. All rights reserved.
//

#import "IAPProduct.h"
#import "IAPManager.h"

@import StoreKit;

@implementation IAPProduct

-(SKProduct *)storeKitProduct {
    return [[IAPManager sharedManager] storeProductForIdentifier:self.iapIdentifier];
}

-(NSString *)buyTitle {
    return [_buyTitle length] ? _buyTitle : self.storeKitProduct.localizedTitle;
}

@end
