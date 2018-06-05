//
//  IAPManger.h
//  
//
//  Created by Rao, Venkat on 12/23/14.
//
//

#import <Foundation/Foundation.h>
#import <StoreKit/SKPaymentQueue.h>

@class SKProduct;
@class IAPProduct;

@interface IAPManager : NSObject <SKPaymentTransactionObserver>

extern NSString *const ProductsLoadedNotification;

-(BOOL)hasPurchasedFeature:(NSString *) feature;
-(void)purchaseProduct:(SKProduct *)product withCompletion:(void(^)(NSError *))completion;
-(void)restorePurchasesWithCompletion:(void(^)(NSError *))completion;
-(SKProduct *)storeProductForIdentifier:(NSString *)identifier;

-(void)initializeStoreWithProducts:(NSArray<IAPProduct *> *)productsd withSharedSecret:(NSString *)secret;
-(void)teardown;

+(instancetype) sharedManager;

@property (nonatomic, assign) BOOL productsLoaded;

@end
