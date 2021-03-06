#import "IAPManager.h"
#import "IAPProducts.h"
#import "AppReceiptManager.h"
#import "IAPProduct.h"
#import "PurchasableProduct.h"
#import "GCNetworkReachability.h"

@import StoreKit;

@interface IAPManager ()<SKProductsRequestDelegate>

@property (nonatomic, strong) NSArray<SKProduct *> *products;
@property (nonatomic, strong) SKProductsRequest *request;
@property (nonatomic, strong) SKReceiptRefreshRequest *refreshReceiptRequest;
@property (nonatomic, copy) void (^completion)(NSError *error);
@property (nonatomic, strong) GCNetworkReachability *reachability;

@end

@implementation IAPManager

NSString *const ProductsLoadedNotification = @"ProductsLoadedNotification";

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
    
    NSArray * products = [IAPProducts productsForFeature:feature];
    
    BOOL purchased = NO;
    for (IAPProduct *product in products) {
        for (PurchasableProduct *purchasableProduct in product.purchasableProducts) {
            NSDate *expiryDate = [defaults objectForKey:[NSString stringWithFormat:defaultsExpirationKey, purchasableProduct.iapIdentifier]];
            purchased = purchased || [self hasPurchasedFeature:feature withExpiryDate:expiryDate];
        }
    }
    
    return purchased;
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
    if (!product) {
        completion([NSError errorWithDomain:@"No Product" code:0 userInfo:@{NSLocalizedDescriptionKey: @"Product Not Loaded"}]);
        return;
    }
    
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

-(IAPProduct *)productForIdentifier:(NSString *)identifier {
    for (IAPProduct *product in [IAPProducts products]) {
        if ([product.identifier isEqual:identifier]) {
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
    
    BOOL needUpdateReceipt = NO;
    
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchasing:
                break;
            case SKPaymentTransactionStateRestored:
            case SKPaymentTransactionStatePurchased:
                needUpdateReceipt = YES;
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
    
    if (needUpdateReceipt) {
        [[AppReceiptManager sharedManager] updateReceiptWithManualOverride:YES withCompletion:self.completion];
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

    self.productsLoaded = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:ProductsLoadedNotification object:nil];    
}

// TODO: do some error handling
-(void) request:(SKRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"error: %@", error);
    
    NSNumber *domain = error.userInfo[@"_kCFStreamErrorDomainKey"];
    NSNumber *key = error.userInfo[@"_kCFStreamErrorCodeKey"];

    if ([domain integerValue] == 12 && [key integerValue] == 8) {
        self.reachability = [[GCNetworkReachability alloc] initWithHostName:@"www.google.com"];
        
        [self.reachability startMonitoringNetworkReachabilityWithHandler:^(GCNetworkReachabilityStatus status) {
            switch (status) {
                case GCNetworkReachabilityStatusNotReachable:
                    NSLog(@"No connection");
                    break;
                case GCNetworkReachabilityStatusWWAN:
                case GCNetworkReachabilityStatusWiFi:
                    [self loadProducts];
                    break;
            }
        }];
     }
}

-(void) initializeStoreWithProducts:(NSArray<IAPProduct *> *)products withSharedSecret:(NSString *)secret {
    [IAPProducts setProducts:products];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[AppReceiptManager sharedManager] setSharedSecret:secret];
    
    [self loadProducts];
}

-(void)teardown {
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

-(void)loadProducts {
    NSMutableSet *set = [NSMutableSet new];
    for (IAPProduct *product in [IAPProducts products]) {
        for (PurchasableProduct *purchasableProduct in product.purchasableProducts) {
            [set addObject:purchasableProduct.iapIdentifier];
        }
    }
    
    self.request = [[SKProductsRequest alloc] initWithProductIdentifiers:set];
    self.request.delegate = self;
    [self.request start];
}

@end
