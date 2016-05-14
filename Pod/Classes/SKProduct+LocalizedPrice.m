//
//  SKProduct+LocalizedPrice.m
//  The Big Clock
//
//  Created by Rao, Venkat on 12/28/14.
//  Copyright (c) 2014 Venkat Rao. All rights reserved.
//

#import "SKProduct+LocalizedPrice.h"

@implementation SKProduct (LocalizedPrice)

-(NSString *)localizedPrice {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [formatter setLocale:self.priceLocale];
    return [formatter stringFromNumber:self.price];
}

@end
