#import "SKProductSubscriptionPeriod+Helpers.h"

@implementation SKProductSubscriptionPeriod(Helpers)

-(NSString *)subscriptionPeriodString {
    NSString *unitString;
    switch (self.unit) {
        case SKProductPeriodUnitDay:
            unitString = @"Day";
            break;
        case SKProductPeriodUnitWeek:
            unitString = @"Week";
            break;
        case SKProductPeriodUnitMonth:
            unitString = @"Month";
            break;
        case SKProductPeriodUnitYear:
            unitString = @"Year";
            break;
    }

    return self.numberOfUnits == 1 ? unitString :
    [NSString stringWithFormat:@"%ld %@s", self.numberOfUnits, unitString];
}

@end
