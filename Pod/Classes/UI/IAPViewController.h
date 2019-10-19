#import <UIKit/UIKit.h>

@interface IAPViewController : UIViewController

@property (nonatomic, strong) NSString *productIdentifier;
@property (nonatomic, assign) BOOL showsRestore;

-(instancetype)initWithCompletion:(void(^)(NSError *))completionBlock;

@end
