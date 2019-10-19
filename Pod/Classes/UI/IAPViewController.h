#import <UIKit/UIKit.h>

@class IAPProduct;

@interface IAPViewController : UIViewController

@property (nonatomic, assign) BOOL showsRestore;

-(instancetype)initWithProduct:(IAPProduct *)product withCompletion:(void(^)(NSError *))completionBlock;

@end
