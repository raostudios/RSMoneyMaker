//
//  IAPManagerTests.m
//  Pods
//
//  Created by Venkat Rao on 4/24/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "IAPManager.h"


@interface IAPManager ()

-(BOOL) hasPurchasedFeature:(NSString *)feature withExpiryDate:(NSDate *)expiryDate;

@end

@interface IAPManagerTests : XCTestCase

@end

@implementation IAPManagerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSubscriptionExpired {
    NSDate *yesterday = [[NSDate new] dateByAddingTimeInterval:-60*60*24];
    XCTAssertFalse([[IAPManager sharedManager] hasPurchasedFeature:@"FEATURE" withExpiryDate:yesterday], "");
}

- (void)testSubscriptionIsCurrent {
    NSDate *tomorrow = [[NSDate new] dateByAddingTimeInterval:60*60*24];
    XCTAssertTrue([[IAPManager sharedManager] hasPurchasedFeature:@"FEATURE" withExpiryDate:tomorrow], "");
}

@end
