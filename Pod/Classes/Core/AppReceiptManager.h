#import <Foundation/Foundation.h>

extern NSString * const defaultsExpirationKey;
extern NSString * const initialExpiryUpdateKey;
extern NSString * const defaultsTrialPeriodKey;

/**
 *  AppReceiptManager updates the reciept
 */
@interface AppReceiptManager : NSObject

-(void) updateReceiptWithManualOverride:(BOOL) forced withCompletion:(void (^)(NSError *error)) completion;

+(instancetype) sharedManager;

@property (nonatomic, copy) NSString *sharedSecret;

@end
