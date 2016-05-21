 //
//  IAPManger.m
//
//
//  Created by Rao, Venkat on 12/23/14.
//
//

#import <RSMoneyMaker/RSMoneyMaker.h>

@interface IAPManager ()<SKProductsRequestDelegate>

@property (nonatomic, strong) NSArray<SKProduct *> *products;
@property (nonatomic, strong) SKProductsRequest *request;
@property (nonatomic, strong) SKReceiptRefreshRequest *refreshReceiptRequest;
@property (nonatomic, copy) void (^completion)(NSError *error);

@end

@implementation IAPManager

+(instancetype) sharedManager {
    static IAPManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [IAPManager new];
    });
    return manager;
}

-(BOOL) hasPurchasedFeature:(NSString *)feature {

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSDate *expiryDate = [defaults objectForKey:[NSString stringWithFormat:defaultsExpirationKey, [IAPProducts productForIdentifier:feature].iapIdentifier]];
    return [self hasPurchasedFeature:feature withExpiryDate:expiryDate];
}

-(BOOL) hasPurchasedFeature:(NSString *)feature withExpiryDate:(NSDate *)expiryDate {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSDate *today = [NSDate date];
    BOOL updateAfterInitialExpiry = [defaults boolForKey:initialExpiryUpdateKey];
    if (expiryDate && [expiryDate compare:today] == NSOrderedAscending && !updateAfterInitialExpiry) {
        [defaults setBool:YES forKey:initialExpiryUpdateKey];
        [defaults synchronize];
        [[AppReceiptManager sharedManager] updateReceiptWithManualOverride:NO withCompletion:nil];
    }
    
    return ((expiryDate && [expiryDate compare:[NSDate date]] == NSOrderedDescending));
}

-(void) purchaseProduct:(SKProduct *)product withCompletion:(void(^)(NSError *))completion {
    SKPayment * payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    self.completion = completion;
}

-(SKProduct *) storeProductForIdentifier:(NSString *)identifier {
    for (SKProduct *product in self.products) {
        if ([product.productIdentifier isEqualToString:identifier]) {
            return product;
        }
    }
    return nil;
}

-(void) restorePurchasesWithCompletion:(void(^)(NSError *))completion {
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    self.completion = completion;
}

#pragma mark - SKPaymentTransactionObserver

-(void) paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
    
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchasing:
                break;
            case SKPaymentTransactionStateRestored:
            case SKPaymentTransactionStatePurchased:
                [[AppReceiptManager sharedManager] updateReceiptWithManualOverride:YES withCompletion:self.completion];
                [queue finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                if (self.completion) {
                    self.completion(transaction.error);
                    self.completion = nil;
                }
                [queue finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateDeferred:
                if (self.completion) {
                    self.completion(nil);
                    self.completion = nil;
                }
                break;
            default:
                break;
        }
    }
}

-(void) paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
    if (self.completion) {
        self.completion(error);
    }
    self.completion = nil;
}

-(void) productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    self.products = response.products;
}

// TODO: do some error handling
-(void) request:(SKRequest *)request didFailWithError:(NSError *)error {
    
}

-(void) initializeStoreWithProducts:(NSArray<IAPProduct *> *)products withSharedSecret:(NSString *)secret {
    [IAPProducts setProducts:products];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[AppReceiptManager sharedManager] setSharedSecret:secret];
    
    NSMutableSet *set = [NSMutableSet new];
    for (IAPProduct *product in [IAPProducts products]) {
        [set addObject:product.iapIdentifier];
    }
    self.request = [[SKProductsRequest alloc] initWithProductIdentifiers:set];
    self.request.delegate = self;
    [self.request start];
}

@end