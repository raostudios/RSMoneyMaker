//
//  IAPItem.h
//  TheBigClock
//
//  Created by Rao, Venkat on 2/25/15.
//  Copyright (c) 2015 Venkat Rao. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SKProduct;

typedef NS_ENUM(NSUInteger, ProductType) {
    ProductTypeSubscription,
    ProductTypeConsumable
};

typedef NS_ENUM(NSUInteger, SubscriptionType) {
    SubscriptionTypeMonthly,
    SubscriptionTypeYearly
};

typedef NS_ENUM(NSUInteger, TrialLength) {
    TrialLengthWeek,
    TrialLengthMonth
};

@interface IAPProduct : NSObject

@property (strong, nonatomic) NSString *iapIdentifier;
@property (strong, nonatomic) NSString *productIdentifier;

@property (strong, nonatomic) NSArray *images;
@property (strong, nonatomic) NSDictionary *defaults;
@property (strong, nonatomic) SKProduct *storeKitProduct;

@property (strong, nonatomic) NSString *buyTitle;

@property (assign, nonatomic) ProductType productType;
@property (assign, nonatomic) SubscriptionType subscriptionLength;
@property (assign, nonatomic) TrialLength trialLength;



@end
