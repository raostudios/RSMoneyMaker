@import Foundation;

@class IAPProduct;

@interface IAPProducts : NSObject

+ (IAPProduct *)productForIdentifier:(NSString *)identifier;
+ (NSArray<IAPProduct *> *)productsForFeature:(NSString *)featureName;

+ (IAPProduct *)purchasedProductForFeature:(NSString *)featureName;

+ (NSArray<IAPProduct *> *)products;
+ (void) setProducts:(NSArray<IAPProduct *> *)products;

@end
