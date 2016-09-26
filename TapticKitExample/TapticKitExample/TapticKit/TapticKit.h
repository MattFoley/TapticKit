//
//  TapticKit.h
//  TapticKitExample
//
//  Created by Tj on 9/25/16.
//  Copyright © 2016 Tj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TapticFeedbackType)
{
    kFeedbackLevelSingle,
    kFeedbackLevelPulse,
};

typedef NS_ENUM(NSInteger, TapticFeedbackLevel)
{
    kFeedbackLevelLight,
    kFeedbackLevelMedium,
    kFeedbackLevelStrong,
};

@interface UIControl (TapticKit)

@property (nonatomic, readwrite, setter=setFeedbackType:) TapticFeedbackType feedbackType;
@property (nonatomic, readwrite, setter=setFeedbackLevel:) TapticFeedbackLevel feedbackLevel;

@property (nonatomic, readwrite, getter=isPopEnabled, setter=setPopEnabled:) BOOL popEnabled;
@property (nonatomic, readwrite, setter=setFeedbackLevel:) TapticFeedbackLevel popLevel;

@property (nonatomic, readwrite, setter=setTriggerForce:) CGFloat triggerForce;
@property (nonatomic, readwrite, getter=isTapticEnabled, setter=setTapticEnabled:) BOOL tapticEnabled;

@end
