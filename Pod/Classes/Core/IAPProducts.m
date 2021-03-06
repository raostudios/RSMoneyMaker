#import "IAPProducts.h"
#import "IAPProduct.h"
#import "IAPMarketingItem.h"
#import "IAPManager.h"
#import "AppReceiptManager.h"
#import "PurchasableProduct.h"

@import UIKit;
@import StoreKit;

@interface IAPProducts ()

@end

@implementation IAPProducts

static NSArray<IAPProduct *> *savedProducts;

+(void)setProducts:(NSArray<IAPProduct *> *)products {
    savedProducts = products;
}

+(NSArray<IAPProduct *> *)products {
    return savedProducts;
}

+(IAPProduct *) productForIdentifier:(NSString *)identifier {
    for (IAPProduct *product in savedProducts) {
        for (PurchasableProduct *purchasableProduct in product.purchasableProducts) {
            if ([purchasableProduct.iapIdentifier isEqualToString:identifier]) {
                return product;
            }
        }
    }
    return nil;
}

+ (NSArray<IAPProduct *> *)productsForFeature:(NSString *)featureName {
    NSMutableArray *products = [NSMutableArray new];
    
    for (IAPProduct *product in savedProducts) {
        for (PurchasableProduct *purchasableProduct in product.purchasableProducts) {
            if ([purchasableProduct.iapIdentifier isEqualToString:featureName]) {
                [products addObject:product];
            }
        }
    }
    
    return products;
}

+(IAPProduct *)purchasedProductForFeature:(NSString *)featureName {
    NSArray * products = [self productsForFeature: featureName];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    for (IAPProduct *product in products) {
        for (PurchasableProduct *purchasableProduct in product.purchasableProducts) {
            NSDate *expiryDate = [defaults objectForKey:[NSString stringWithFormat:defaultsExpirationKey, purchasableProduct.iapIdentifier]];
            if ([expiryDate compare:[NSDate date]] == NSOrderedDescending) {
                return product;
            }
        }
    }
    
    return nil;
}


@end
