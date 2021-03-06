#import "AppReceiptManager.h"
#import "IAPProducts.h"
#import "IAPProduct.h"
#import "PurchasableProduct.h"

@import StoreKit;

@interface AppReceiptManager () <SKProductsRequestDelegate>

@property (nonatomic, copy) void (^completion)(NSError *error);

@end

@implementation AppReceiptManager

NSInteger  const inSandboxStatus = 21007;
NSString * const statusKey = @"status";
NSString * const LatestReceiptInfoKey = @"latest_receipt_info";
NSString * const UpdateReceiptDate = @"UpdateReceiptDate";
NSString * const appStoreVerifyURL = @"https://buy.itunes.apple.com/verifyReceipt";
NSString * const sandboxVerifyURL = @"https://sandbox.itunes.apple.com/verifyReceipt";
NSString * const InitialExpiryUpdate = @"InitialExpiryUpdate";
NSString * const initialExpiryUpdateKey = @"initialExpiryUpdate";
NSString * const trialPeriodKey = @"is_trial_period";
NSString * const productIdentifierKey = @"product_id";
NSString * const expiresDateKey = @"expires_date_ms";
NSString * const defaultSetKey = @"%@_defaults_set";
NSString * const defaultsTrialPeriodKey = @"%@_feature_is_trial_period";
NSString * const defaultsExpirationKey = @"%@_feature_experiration_date";

+(instancetype) sharedManager {
    static AppReceiptManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [AppReceiptManager new];
    });
    return manager;
}

-(void) updateReceiptWithManualOverride:(BOOL)forced withCompletion:(void (^)(NSError *error)) completion {
    
    if ([self shouldUpdate] || forced) {
        NSURL *receiptUrl = [[NSBundle mainBundle] appStoreReceiptURL];
        if ([[NSFileManager defaultManager] fileExistsAtPath:[receiptUrl path]]) {
            self.completion = completion;
            NSData *ios7ReceiptData = [NSData dataWithContentsOfURL:receiptUrl];
            [self verifyReceipt:ios7ReceiptData
                        withURL:[NSURL URLWithString:appStoreVerifyURL] withCompletion:^(NSInteger status) {
                            if (status == inSandboxStatus) {
                                NSURL *sandboxURL = [NSURL URLWithString:sandboxVerifyURL];
                                [self verifyReceipt:ios7ReceiptData
                                            withURL:sandboxURL withCompletion:^(NSInteger status) {
                                                NSLog(@"sandbox");
                                            }];
                            }
                        }];
        } else if (forced) {
            SKReceiptRefreshRequest *request = [[SKReceiptRefreshRequest alloc] init];
            request.delegate = self;
            [request start];
        }
    }
    
}

-(BOOL)shouldUpdate {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSTimeInterval ThirtyDays = 60*60*24*30;
    NSDate *lastUpdateDate = [[defaults objectForKey:UpdateReceiptDate] dateByAddingTimeInterval:ThirtyDays];
    
    return (lastUpdateDate && [lastUpdateDate earlierDate:[NSDate date]] == lastUpdateDate);
}

-(void) verifyReceipt:(NSData *)receiptData withURL:(NSURL*)storeURL withCompletion:(void(^)(NSInteger))completion {
    
    NSDictionary *requestContents = @{ @"receipt-data": [receiptData base64EncodedStringWithOptions:0],
                                       @"password": self.sharedSecret };
    NSError *jsonError;
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:requestContents
                                                          options:0
                                                            error:&jsonError];
    
    if (jsonError) {
        NSLog(@"json error: %@", jsonError);
    } else {

        NSMutableURLRequest *storeRequest = [NSMutableURLRequest requestWithURL:storeURL];
        [storeRequest setHTTPMethod:@"POST"];
        [storeRequest setHTTPBody:requestData];

        [[[NSURLSession sharedSession] dataTaskWithRequest:storeRequest
                                         completionHandler:^(NSData * _Nullable data,
                                                             NSURLResponse * _Nullable response,
                                                             NSError * _Nullable error) {
            
            if (error) {
                NSLog(@"error: %@", error);
                completion(0);
                return;
            }
            
            NSError *serializationError;
            NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                         options:0
                                                                           error:&serializationError];
            NSInteger status = [jsonResponse[statusKey] integerValue];
            
            if (status == 0) {
                for (IAPProduct *product in [IAPProducts products]) {
                    [self updateDefaultsForProduct:product
                                       withReceipt:jsonResponse[LatestReceiptInfoKey]];
                }
                [[NSUserDefaults standardUserDefaults] setBool:YES
                                                        forKey:initialExpiryUpdateKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            
            if (completion) {
                completion(status);
            }
        }] resume];
    }
}

-(void) updateDefaultsForProduct:(IAPProduct *)product withReceipt:(NSDictionary *)transactions {

    for (NSDictionary *transaction in transactions) {
        if ([self isCurrentTransaction:transaction]) {
            NSDate *expiresDate = [self dateFromString:transaction[expiresDateKey]];
            if ([expiresDate compare:[NSDate date]] == NSOrderedDescending) {
                [self updateUserDefaultsForProduct:product
                                   withTransaction:transaction];
                break;
            }
        }
    }
    
    if (self.completion) {
        self.completion([NSError errorWithDomain:@"Nothing to Update" code:10 userInfo:nil]);
    }
}

-(BOOL) isCurrentTransaction:(NSDictionary *)transaction {
    return [self isTodayPastDate:[self dateFromString:transaction[expiresDateKey]]];
}

-(NSDate *)dateFromString:(NSString *)dateString {
    return [NSDate dateWithTimeIntervalSince1970:([dateString doubleValue]/1000)];
}

-(BOOL) isTodayPastDate:(NSDate *)date {
    return [date compare:[NSDate date]] == NSOrderedDescending;
}

-(void) updateUserDefaultsForProduct:(IAPProduct *)product withTransaction:(NSDictionary *)transaction {
    NSDate *expiresDate = [self dateFromString:transaction[expiresDateKey]];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSDate date] forKey:UpdateReceiptDate];

    NSString *productIdentifierInTransaction = transaction[productIdentifierKey];

    for (PurchasableProduct *purchasableProduct in product.purchasableProducts) {
        if ([productIdentifierInTransaction isEqualToString:purchasableProduct.iapIdentifier]) {

            NSString *stringExpiration = [NSString stringWithFormat:defaultsExpirationKey, productIdentifierInTransaction];
            [defaults setObject:expiresDate forKey:stringExpiration];

            NSString *stringForIsTrialPeriod = [NSString stringWithFormat:defaultsTrialPeriodKey, productIdentifierInTransaction];
            [defaults setBool:[transaction[trialPeriodKey] boolValue] forKey:stringForIsTrialPeriod];

            NSString *keyForProductDefault = [NSString stringWithFormat:defaultSetKey, productIdentifierInTransaction];

            if (![defaults boolForKey:keyForProductDefault]) {
                [product.defaults enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                    [defaults setObject:obj forKey:key];
                }];
                [defaults setBool:YES forKey:keyForProductDefault];
            }

            [defaults synchronize];
        }
    }

    if (self.completion) {
        self.completion(nil);
    }
    self.completion = nil;
}

-(void) productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    [self updateReceiptWithManualOverride:NO withCompletion:self.completion];
}

@end
