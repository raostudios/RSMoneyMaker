//
//  IAPItem.h
//  TheBigClock
//
//  Created by Rao, Venkat on 2/25/15.
//  Copyright (c) 2015 Venkat Rao. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SKProduct;

@interface IAPProduct : NSObject

@property (strong, nonatomic) NSString *iapIdentifier;
@property (strong, nonatomic) NSArray *images;
@property (strong, nonatomic) NSDictionary *defaults;
@property (strong, nonatomic) SKProduct *storeKitProduct;

@property (strong, nonatomic) NSString *buyTitle;

@end
