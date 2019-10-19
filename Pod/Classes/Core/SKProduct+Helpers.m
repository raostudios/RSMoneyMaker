#import "SKProduct+Helpers.h"

@implementation SKProduct (Helpers)

-(NSString *)localizedPrice {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [formatter setLocale:self.priceLocale];
    return [formatter stringFromNumber:self.price];
}

@end
