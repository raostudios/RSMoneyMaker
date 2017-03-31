//
//  IAPViewController.m
//  The Big Clock
//
//  Created by Rao, Venkat on 12/22/14.
//  Copyright (c) 2014 Venkat Rao. All rights reserved.
//

#import "IAPViewController.h"
#import "IAPCell.h"
#import "SKProduct+LocalizedPrice.h"
#import "IAPProducts.h"
#import "IAPProduct.h"
#import "IAPMarketingItem.h"
#import "IAPManager.h"

#import <RSInterfaceKit/RSCarouselView.h>
#import <RSInterfaceKit/UIView+LoadingOverlay.h>
#import <RSInterfaceKit/UIView+AutoLayout.h>


@interface IAPViewController () <RSCarouselViewDataSource>

@property (nonatomic, strong) RSCarouselView *carouselView;
@property (nonatomic, copy) void (^completionBlock)(NSError *);
@property (nonatomic, strong) UIBarButtonItem *buttonBuy;
@property (nonatomic, strong) UIBarButtonItem *restoreButton;

@end

@implementation IAPViewController

static NSString *const IAPCellIdentifier = @"IAPCELL";

-(instancetype)initWithCompletion:(void(^)(NSError *))completionBlock {
    self = [super init];
    
    if (self) {
        self.completionBlock = completionBlock;
        self.showsRestore = YES;
    }
    
    return self;
}

-(void)viewDidLoad {
    
    [super viewDidLoad];
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectZero];
    toolbar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:toolbar];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[toolbar]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:@{@"toolbar":toolbar}]];
    
    self.buttonBuy = [[UIBarButtonItem alloc] initWithTitle:@"Buy"
                                                      style:UIBarButtonItemStyleDone
                                                     target:self
                                                     action:@selector(buyPressed:)];
    
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                  target:nil
                                                                                  action:nil];
    
    toolbar.items = @[flexibleItem,
                      self.buttonBuy,
                      flexibleItem];
    
    
    self.carouselView = [[RSCarouselView alloc] initWithAutoLayout];
    [self.carouselView registerClass:[IAPCell class] forCellWithReuseIdentifier:IAPCellIdentifier];
    self.carouselView.dataSource = self;
    [self.view addSubview:self.carouselView];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[carouselView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:@{@"toolbar":toolbar,
                                                                                @"carouselView":self.carouselView,
                                                                                @"topLayoutGuide":self.topLayoutGuide}]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topLayoutGuide][carouselView][toolbar]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:@{@"toolbar":toolbar,
                                                                                @"carouselView":self.carouselView,
                                                                                @"topLayoutGuide":self.topLayoutGuide}]];
    if(self.showsRestore) {
        self.restoreButton = [[UIBarButtonItem alloc] initWithTitle:@"Restore"
                                                                          style:UIBarButtonItemStyleDone
                                                                         target:self
                                                                         action:@selector(restorePressed:)];
        self.navigationItem.rightBarButtonItem = self.restoreButton;
    }

    self.title = [IAPProducts productForIdentifier:self.productIdentifier].buyTitle;
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [self configureBuyAndRestoreButtons];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productsLoaded:) name:ProductsLoadedNotification object:nil];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.carouselView start];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.carouselView stop];
}

-(BOOL)shouldAutorotate {
    return NO;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return NO;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

-(CGSize)preferredContentSize {
    return CGSizeMake(700, 600);
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.carouselView setNeedsLayout];
}

#pragma mark - RSCarouselViewDataSource

-(NSInteger)numberOfItemsInCarouselView:(RSCarouselView *)corouselView {
    IAPProduct *product = [IAPProducts productForIdentifier:self.productIdentifier];
    return [product.images count];
}

- (void) configureCell:(UICollectionViewCell *)cell InCarouselView:(RSCarouselView *)carouselView atIndex:(NSUInteger)index {
    IAPProduct *product = [IAPProducts productForIdentifier:self.productIdentifier];
    [self configureCell:(IAPCell *)cell forMarketingItem:product.images[index]];
    [cell.contentView layoutIfNeeded];
}

-(void) configureCell:(IAPCell *)cell forMarketingItem:(IAPMarketingItem *)item {
    
    cell.labelTitle.text = item.title;
    
    if ([item.items isKindOfClass:[NSArray class]]) {
        cell.imageViewMarketing.animationImages = item.items;
        cell.imageViewMarketing.animationDuration = 2;
        cell.imageViewMarketing.animationRepeatCount = 0;
        [cell.imageViewMarketing startAnimating];
    } else if ([item.items isKindOfClass:[UIImage class]]) {
        cell.imageViewMarketing.image = item.items;
    }
}

#pragma mark - User Actions

-(void) buyPressed:(UIBarButtonItem *) button {
    [self.carouselView stop];
    
    IAPProduct *product = [IAPProducts productForIdentifier:self.productIdentifier];
    [self.view showLoadingOverlayWithText:[NSString stringWithFormat:@"Purchasing %@.", product.storeKitProduct.localizedTitle]];
    
    IAPManager *manager = [IAPManager sharedManager];
    [manager purchaseProduct:[IAPProducts productForIdentifier:self.productIdentifier].storeKitProduct
              withCompletion:^(NSError *error) {
                  
                  if (self.completionBlock) {
                      self.completionBlock(error);
                  }
                  
                  dispatch_async(dispatch_get_main_queue(), ^{
                      [self.view hideLoadingOverlay];
                      
                      if (error) {
                          UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error!"
                                                                                         message:error.localizedDescription
                                                                                  preferredStyle:UIAlertControllerStyleAlert];
                          
                          [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
                          
                          [self presentViewController:alert animated:YES completion:nil];
                          
                          return;
                      }
                      
                      [self.navigationController popViewControllerAnimated:YES];
                  });

              }];
}

-(void) restorePressed:(UIBarButtonItem *)button {
    [self.carouselView stop];
    
    IAPProduct *product = [IAPProducts productForIdentifier:self.productIdentifier];
    [self.view showLoadingOverlayWithText:[NSString stringWithFormat:@"Restoring %@.", product.storeKitProduct.localizedTitle]];
    
    IAPManager *manager = [IAPManager sharedManager];
    [manager restorePurchasesWithCompletion:^(NSError *error) {

        if (self.completionBlock) {
            self.completionBlock(error);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view hideLoadingOverlay];
            
            if (!error) {
                [self.navigationController popViewControllerAnimated:YES];
            }
        });
    }];
}


-(NSString *)buyStringForProduct:(IAPProduct *)product {
    
    NSString *marketingString = @"Waiting to Load";
    
    SKProduct *storeProduct = product.storeKitProduct;
    
    if (storeProduct) {
        NSString *trialString = product.trialLength == TrialLengthMonth ? @"1 Month" : @"1 Week";
        
        marketingString = [NSString stringWithFormat:@"Try for %@ (then %@/%@)",
                           trialString,
                           [storeProduct localizedPrice],
                           (product.subscriptionLength == SubscriptionTypeYearly) ? @"yr" : @"mth"];
    }
    
    return marketingString;
}

-(void)configureBuyAndRestoreButtons {
    IAPProduct *product = [IAPProducts productForIdentifier:self.productIdentifier];
    self.buttonBuy.enabled = product.storeKitProduct != nil;
    self.buttonBuy.title = [self buyStringForProduct:product];
    
    self.restoreButton.enabled = product.storeKitProduct != nil;
}

#pragma mark - Notifications

-(void)productsLoaded:(NSNotification *)notification {
    [self configureBuyAndRestoreButtons];
}

@end
