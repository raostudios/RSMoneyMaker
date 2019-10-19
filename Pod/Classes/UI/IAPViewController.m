#import "IAPViewController.h"
#import "IAPCell.h"
#import "SKProduct+Helpers.h"
#import "IAPProducts.h"
#import "IAPProduct.h"
#import "IAPMarketingItem.h"
#import "IAPManager.h"
#import "PurchasableProduct.h"

#import <RSInterfaceKit/RSCarouselView.h>
#import <RSInterfaceKit/UIView+LoadingOverlay.h>
#import <RSInterfaceKit/UIView+AutoLayout.h>


@interface IAPViewController () <RSCarouselViewDataSource>

@property (nonatomic, strong) RSCarouselView *carouselView;
@property (nonatomic, copy) void (^completionBlock)(NSError *);
@property (nonatomic, strong) UIBarButtonItem *restoreButton;
@property (nonatomic, strong) UIStackView *buyButtonsView;

@property (nonatomic, strong) IAPProduct *product;

@end

@implementation IAPViewController

static NSString *const IAPCellIdentifier = @"IAPCELL";

-(instancetype)initWithProduct:(IAPProduct *)product withCompletion:(void(^)(NSError *))completionBlock {
    self = [super init];
    
    if (self) {
        self.completionBlock = completionBlock;
        self.product = product;
        self.showsRestore = YES;
    }
    
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];

    self.buyButtonsView = [[UIStackView alloc] initWithFrame:CGRectZero];
    self.buyButtonsView.axis = UILayoutConstraintAxisVertical;
    self.buyButtonsView.backgroundColor = [UIColor greenColor];
    self.buyButtonsView.directionalLayoutMargins = NSDirectionalEdgeInsetsMake(0.0, 10.0, 0.0, 10.0);
    self.buyButtonsView.layoutMarginsRelativeArrangement = YES;
    self.buyButtonsView.spacing = 10.0f;

    UIView *toolBarBackground = [[UIView alloc] initWithAutoLayout];
    [self.view addSubview:toolBarBackground];
    toolBarBackground.backgroundColor = [UIColor lightGrayColor];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[toolBarBackground]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:@{@"toolBarBackground": toolBarBackground}]];

    [[toolBarBackground.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor] setActive:YES];

    self.buyButtonsView.translatesAutoresizingMaskIntoConstraints = NO;
    [toolBarBackground addSubview:self.buyButtonsView];

    [[toolBarBackground.topAnchor constraintEqualToAnchor:self.buyButtonsView.topAnchor
                                                 constant:-10.0f] setActive:YES];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[toolbar]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:@{@"toolbar":self.buyButtonsView}]];

    self.carouselView = [[RSCarouselView alloc] initWithAutoLayout];
    [self.carouselView registerClass:[IAPCell class] forCellWithReuseIdentifier:IAPCellIdentifier];
    self.carouselView.dataSource = self;
    [self.view addSubview:self.carouselView];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[carouselView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:@{@"toolbar":self.buyButtonsView,
                                                                                @"carouselView":self.carouselView}]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[carouselView][toolbar]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:@{@"toolbar":self.buyButtonsView,
                                                                                @"carouselView":self.carouselView}]];

    [self.view.safeAreaLayoutGuide.topAnchor constraintEqualToAnchor:self.carouselView.topAnchor].active = YES;

    [[toolBarBackground.safeAreaLayoutGuide.bottomAnchor constraintEqualToAnchor:self.buyButtonsView.bottomAnchor] setActive:YES];

    if(self.showsRestore) {
        self.restoreButton = [[UIBarButtonItem alloc] initWithTitle:@"Restore"
                                                                          style:UIBarButtonItemStyleDone
                                                                         target:self
                                                                         action:@selector(restorePressed:)];
        self.navigationItem.rightBarButtonItem = self.restoreButton;
    }

    self.title = self.product.buyTitle;
    
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
    return [self.product.images count];
}

- (void) configureCell:(UICollectionViewCell *)cell InCarouselView:(RSCarouselView *)carouselView atIndex:(NSUInteger)index {
    [self configureCell:(IAPCell *)cell forMarketingItem:self.product.images[index]];
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

-(void) buyPressed:(UIBarButtonItem *)button {
    [self.carouselView stop];

    PurchasableProduct *product = self.product.purchasableProducts[button.tag];

    [self.view showLoadingOverlayWithText:[NSString stringWithFormat:@"Purchasing %@.", product.storeKitProduct.localizedTitle]];

    IAPManager *manager = [IAPManager sharedManager];
    [manager purchaseProduct:product.storeKitProduct
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
    
    [self.view showLoadingOverlayWithText:[NSString stringWithFormat:@"Restoring %@.", self.product.buyTitle]];
    
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

-(void) configureBuyAndRestoreButtons {
    UIStackView *stackView = self.buyButtonsView;
    [self.product.purchasableProducts enumerateObjectsUsingBlock:^(PurchasableProduct * _Nonnull product, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *buttonBuy = [UIButton buttonWithType:UIButtonTypeSystem];
        buttonBuy.tag = idx;
        buttonBuy.translatesAutoresizingMaskIntoConstraints = NO;
        [buttonBuy setTitle:[product marketingString] forState:UIControlStateNormal];
        [buttonBuy addTarget:self action:@selector(buyPressed:) forControlEvents:UIControlEventTouchUpInside];
        buttonBuy.backgroundColor = self.view.tintColor;
        buttonBuy.tintColor = [UIColor whiteColor];
        [stackView addArrangedSubview:buttonBuy];
    }];
}

#pragma mark - Notifications

-(void)productsLoaded:(NSNotification *)notification {
    [self configureBuyAndRestoreButtons];
}

@end
