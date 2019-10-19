@import Foundation;
#import "IAPMarketingItem.h"

@class PurchasableProduct;

@interface IAPProduct : NSObject

@property (strong, nonatomic) NSString *identifier;

@property (strong, nonatomic) NSArray<IAPMarketingItem *> *images;
@property (strong, nonatomic) NSDictionary *defaults;

@property (strong, nonatomic) NSArray<NSString *> *features;

@property (strong, nonatomic) NSString *buyTitle;

@property (strong, nonatomic) NSArray<PurchasableProduct *>*purchasableProducts;
@property (strong, nonatomic, readonly) PurchasableProduct *activePurchasedProduct;

@end
