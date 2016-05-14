//
//  AppReceiptManagerTests.m
//  RSStoreKit
//
//  Created by Venkat Rao on 4/24/15.
//  Copyright (c) 2015 Venkat S. Rao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "AppReceiptManager.h"


@interface AppReceiptManager ()

-(BOOL) isTodayPastDate:(NSDate *)date;

@end

@interface AppReceiptManagerTests : XCTestCase

@property (strong, nonatomic) AppReceiptManager *manager;

@end

@implementation AppReceiptManagerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.manager = [AppReceiptManager new];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSubscriptionExpired {
    NSDate *yesterday = [[NSDate new] dateByAddingTimeInterval:-60*60*24];
    XCTAssertFalse([self.manager isTodayPastDate:yesterday], "");
}

- (void)testSubscriptionIsCurrent {
    NSDate *tomorrow = [[NSDate new] dateByAddingTimeInterval:60*60*24];
    XCTAssertTrue([self.manager isTodayPastDate:tomorrow], "");
}



@end
