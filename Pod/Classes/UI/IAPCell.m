//
//  IAPCell.m
//  The Big Clock
//
//  Created by Rao, Venkat on 12/26/14.
//  Copyright (c) 2014 Venkat Rao. All rights reserved.
//

#import "IAPCell.h"
#import <RSInterfaceKit/UIView+AutoLayout.h>

@interface IAPCell ()
@property (strong, nonatomic) UIImageView *deviceFrame;

@end

@implementation IAPCell

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.labelTitle = [[UILabel alloc] initWithAutoLayout];
        self.labelTitle.textColor = [UIColor whiteColor];
        self.labelTitle.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.labelTitle];
        
        self.deviceFrame = [[UIImageView alloc] initWithAutoLayout];
        self.deviceFrame.contentMode = UIViewContentModeScaleAspectFit;


        self.deviceFrame.image = [UIImage imageNamed:(([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) ? @"device_ipad" : @"device")
                                            inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:self.traitCollection];

        
        [self.contentView addSubview:self.deviceFrame];
        
        self.imageViewMarketing = [[UIImageView alloc] initWithAutoLayout];
        self.imageViewMarketing.contentMode = UIViewContentModeScaleAspectFit;
        self.imageViewMarketing.clipsToBounds = YES;
        [self.contentView addSubview:self.imageViewMarketing];
                
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[labelTitle(30)]-[deviceFrame]-|"
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:@{@"deviceFrame": self.deviceFrame,
                                                                                           @"labelTitle": self.labelTitle}]];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[labelTitle]-|"
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:@{@"labelTitle": self.labelTitle}]];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[deviceFrame]-|"
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:@{@"deviceFrame": self.deviceFrame,
                                                                                           @"labelTitle": self.labelTitle}]];
        

        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.imageViewMarketing attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.deviceFrame attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
        
        CGFloat iphoneWidth = CGRectGetWidth([[UIScreen mainScreen] bounds]) / 375 * 220;
        if (CGRectGetWidth([[UIScreen mainScreen] bounds]) == 414.0) {
            iphoneWidth = 223;
        } else if (CGRectGetWidth([[UIScreen mainScreen] bounds]) == 375.0) {
            iphoneWidth = 192;
        } else if (CGRectGetWidth([[UIScreen mainScreen] bounds]) == 320.0) {
            if (CGRectGetHeight([[UIScreen mainScreen] bounds]) == 568.00) {
                iphoneWidth = 150;
            } else {
                iphoneWidth = 113;
            }
        }
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.imageViewMarketing
                                                                     attribute:NSLayoutAttributeWidth
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.contentView
                                                                     attribute:NSLayoutAttributeWidth
                                                                    multiplier:0
                                                                      constant:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 525 : iphoneWidth]];
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.imageViewMarketing attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.deviceFrame attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    }
    return self;
}

-(void)prepareForReuse  {
    self.imageViewMarketing.image = nil;
    self.imageViewMarketing.animationImages = nil;
}

@end
