//
//  AppRecieptManager.h
//  TheBigClock
//
//  Created by Rao, Venkat on 2/28/15.
//  Copyright (c) 2015 Venkat Rao. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const defaultsExpirationKey;
extern NSString * const initialExpiryUpdateKey;
extern NSString * const defaultsTrialPeriodKey;

@interface AppReceiptManager : NSObject

-(void) updateReceiptWithManualOverride:(BOOL) forced withCompletion:(void (^)(NSError *error)) completion;

+(instancetype) sharedManager;

@property (nonatomic, copy) NSString *sharedSecret;

@end
