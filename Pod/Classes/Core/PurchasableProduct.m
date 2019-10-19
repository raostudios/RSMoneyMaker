#import "PurchasableProduct.h"
#import "IAPManager.h"
#import "SKProduct+Helpers.h"
#import "SKProductSubscriptionPeriod+Helpers.h"

@import StoreKit;

@interface PurchasableProduct ()

@property (nonatomic, strong) NSUserDefaults *userDefaults;

@end

@implementation PurchasableProduct

-(instancetype)init {
    self = [super init];
    if (self) {
        self.userDefaults = [NSUserDefaults standardUserDefaults];
    }
    return self;
}

-(SKProduct *)storeKitProduct {
    return [[IAPManager sharedManager] storeProductForIdentifier:self.iapIdentifier];
}

-(NSString *)subscriptionExpiresString {
    NSString * const defaultsExpirationKey = @"%@_feature_experiration_date";
    NSString * const defaultsTrialPeriodKey = @"%@_feature_is_trial_period";

    BOOL isTrialPeriod = [self.userDefaults boolForKey:[NSString stringWithFormat:defaultsTrialPeriodKey, self.iapIdentifier]];
    NSString *stringExpiration = [NSString stringWithFormat:defaultsExpirationKey, self.iapIdentifier];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeStyle = kCFDateFormatterNoStyle;
    dateFormatter.dateStyle = kCFDateFormatterShortStyle;

    return [NSString stringWithFormat:@"%@Subscription Expires: %@", isTrialPeriod ? @"Trial " : @"", [dateFormatter stringFromDate:[self.userDefaults objectForKey:stringExpiration]]];
}

-(NSString *)marketingString {
    NSString *marketingString = @"Waiting to Load";

    if (!self.storeKitProduct) {
        return marketingString;
    }

    marketingString = [NSString stringWithFormat:@"Try for %@ (then %@/%@)",
                       [self.storeKitProduct.introductoryPrice.subscriptionPeriod subscriptionPeriodString],
                       [self.storeKitProduct localizedPrice],
                       [self.storeKitProduct.subscriptionPeriod subscriptionPeriodString]];

    return marketingString;
}

-(BOOL)purchased {
    return YES;
}

@end
