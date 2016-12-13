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
@property (nonatomic, copy) void (^completionBlock)(BOOL);

@end

@implementation IAPViewController

static NSString *const IAPCellIdentifier = @"IAPCELL";

-(instancetype)initWithCompletion:(void(^)(BOOL))completionBlock {
    self = [super init];
    
    if (self) {
        self.completionBlock = completionBlock;
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
    
    SKProduct *product = [IAPProducts productForIdentifier:self.productIdentifier].storeKitProduct;
    NSString *marketingString = [NSString stringWithFormat:@"Buy(%@/yr after 1 month free trial)", [product localizedPrice]];

    if (!product) {
        marketingString = @"Buy(1 month free trial)";
    }
    
    UIBarButtonItem *buttonBuy = [[UIBarButtonItem alloc] initWithTitle:marketingString
                                                                  style:UIBarButtonItemStyleDone
                                                                 target:self
                                                                 action:@selector(buyPressed:)];
    
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                  target:nil
                                                                                  action:nil];
    
    toolbar.items = @[flexibleItem,
                      buttonBuy,
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
    
    UIBarButtonItem *restoreButton = [[UIBarButtonItem alloc] initWithTitle:@"Restore"
                                                                      style:UIBarButtonItemStyleDone
                                                                     target:self
                                                                     action:@selector(restorePressed:)];
    self.navigationItem.rightBarButtonItem = restoreButton;
    self.title = [IAPProducts productForIdentifier:self.productIdentifier].storeKitProduct.localizedTitle;
    
    self.view.backgroundColor = [UIColor blackColor];
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

-(void) buyPressed:(UIBarButtonItem *) button {
    [self.carouselView stop];
    
    IAPProduct *product = [IAPProducts productForIdentifier:self.productIdentifier];
    [self.view showLoadingOverlayWithText:[NSString stringWithFormat:@"Purchasing %@.", product.storeKitProduct.localizedTitle]];
    
    IAPManager *manager = [IAPManager sharedManager];
    [manager purchaseProduct:[IAPProducts productForIdentifier:self.productIdentifier].storeKitProduct
              withCompletion:^(NSError *error) {
                  [self.view hideLoadingOverlay];

                  if (self.completionBlock) {
                      self.completionBlock(error == nil);
                  }
                  
                  if (error) {
                      UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error!"
                                                                                     message:error.localizedDescription
                                                                              preferredStyle:UIAlertControllerStyleAlert];
                      
                      [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
                      
                      [self presentViewController:alert animated:YES completion:nil];
                      
                      return;
                  }
                  
                  [self.navigationController popViewControllerAnimated:YES];
              }];
}

-(void) restorePressed:(UIBarButtonItem *)button {
    [self.carouselView stop];
    
    IAPProduct *product = [IAPProducts productForIdentifier:self.productIdentifier];
    [self.view showLoadingOverlayWithText:[NSString stringWithFormat:@"Restoring %@.", product.storeKitProduct.localizedTitle]];
    
    IAPManager *manager = [IAPManager sharedManager];
    [manager restorePurchasesWithCompletion:^(NSError *error) {
        if (!error) {
            [self.navigationController popViewControllerAnimated:YES];
        }
        [self.view hideLoadingOverlay];
    }];
}

@end
