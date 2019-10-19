#import "SKProduct+Helpers.h"

@implementation SKProduct (Helpers)

-(NSString *)localizedPrice {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [formatter setLocale:self.priceLocale];
    return [formatter stringFromNumber:self.price];
}

-(NSString *)subscriptionPeriod:(SKProduct *)product {
    switch (product.subscriptionPeriod.unit) {
        case SKProductPeriodUnitDay:
            return @"Day";
            break;
        case SKProductPeriodUnitWeek:
            return @"Week";
            break;
        case SKProductPeriodUnitMonth:
            return @"Month";
            break;
        case SKProductPeriodUnitYear:
            return @"Year";
            break;
        default:
            break;
    }
}

@end
