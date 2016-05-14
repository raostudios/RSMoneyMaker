//
//  SKProduct+LocalizedPrice.h
//  The Big Clock
//
//  Created by Rao, Venkat on 12/28/14.
//  Copyright (c) 2014 Venkat Rao. All rights reserved.
//

#import <StoreKit/StoreKit.h>

@interface SKProduct (LocalizedPrice)

-(NSString *)localizedPrice;

@end
