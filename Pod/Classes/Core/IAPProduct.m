#import "IAPProduct.h"
#import "IAPManager.h"
#import "PurchasableProduct.h"

@import StoreKit;

@implementation IAPProduct

-(PurchasableProduct *)activePurchasedProduct {
    for (PurchasableProduct *product in self.purchasableProducts) {
        if (product.purchased) {
            return product;
        }
    }
    return nil;
}

@end
