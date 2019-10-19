@import Foundation;

@class SKProduct;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ProductType) {
    ProductTypeSubscription,
    ProductTypeConsumable
};

typedef NS_ENUM(NSUInteger, TrialLength) {
    TrialLengthWeek,
    TrialLengthMonth
};

@interface PurchasableProduct : NSObject

@property (assign, nonatomic) ProductType productType;
@property (assign, nonatomic) TrialLength trialLength;

@property (strong, nonatomic) NSString *iapIdentifier;

@property (strong, nonatomic) SKProduct *storeKitProduct;

@property (assign, nonatomic, readonly) BOOL purchased;

-(NSString *)subscriptionExpiresString;
-(NSString *)marketingString;


@end

NS_ASSUME_NONNULL_END
