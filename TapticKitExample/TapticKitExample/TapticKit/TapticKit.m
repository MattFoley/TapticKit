//
//  TapticKit.m
//  TapticKitExample
//
//  Created by Tj on 9/25/16.
//  Copyright © 2016 Tj. All rights reserved.
//

#import "TapticKit.h"
#import <objc/runtime.h>

typedef NS_ENUM(NSInteger, TapticEnabledClass)
{
    kTapticDefault,
    kTapticButton,
};

static const void *TapticEnabledKey = &TapticEnabledKey;
static const void *NotificationGeneratorKey = &NotificationGeneratorKey;
static const void *SelectionGeneratorKey = &SelectionGeneratorKey;
static const void *ImpactGeneratorKey = &ImpactGeneratorKey;

static const void *PopEnabledKey = &PopEnabledKey;
static const void *PopLevelKey = &PopLevelKey;
static const void *ShouldPopKey = &ShouldPopKey;

static const void *TriggerForceKey = &TriggerForceKey;
static const void *CanTapticKey = &CanTapticKey;
static const void *FeedbackLevelKey = &FeedbackLevelKey;
static const void *FeedbackTypeKey = &FeedbackTypeKey;

@interface UIControl (TapticKitPrivate)

@property (nonatomic, readwrite, setter=setNotificationGenerator:) UINotificationFeedbackGenerator *notificationGenerator;
@property (nonatomic, readwrite, setter=setImpactGenerator:) UIImpactFeedbackGenerator *impactGenerator;
@property (nonatomic, readwrite, setter=setSelectionGenerator:) UISelectionFeedbackGenerator *selectionGenerator;

@property (nonatomic, readwrite, setter=setShouldPop:) BOOL shouldPop;

@end

@implementation UIControl (TapticKit)

#pragma mark Public

- (BOOL)isTapticEnabled
{
    return [objc_getAssociatedObject(self, TapticEnabledKey) boolValue];
}

- (void)setTapticEnabled:(BOOL)enabled
{
    if (enabled && ![self isTapticEnabled]) {
        [self installSelf];
    }

    objc_setAssociatedObject(self, TapticEnabledKey, @(enabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark Internal

#pragma mark Setup
- (void)installSelf
{
    switch ([self tapticClass]) {
        case kTapticButton:
        case kTapticDefault:
        default: [self installDefaultTapticControl]; break;
    }
}

- (TapticEnabledClass)tapticClass
{
    if ([self isKindOfClass:[UIButton class]]) {
        return kTapticButton;
    } else {
        return kTapticDefault;
    }
}

#pragma Private Properties

- (void)setCanTaptic:(BOOL)canTaptic
{
    objc_setAssociatedObject(self, CanTapticKey, @(canTaptic), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)canTaptic
{
    return [objc_getAssociatedObject(self, CanTapticKey) boolValue];
}

- (void)setShouldPop:(BOOL)shouldPop
{
    objc_setAssociatedObject(self, ShouldPopKey, @(shouldPop), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)shouldPop
{
    return [objc_getAssociatedObject(self, ShouldPopKey) boolValue];
}


- (void)setPopEnabled:(BOOL)popEnabled
{
    objc_setAssociatedObject(self, PopEnabledKey, @(popEnabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isPopEnabled
{
    return [objc_getAssociatedObject(self, PopEnabledKey) boolValue];
}


- (void)setTriggerForce:(CGFloat)triggerForce
{
    objc_setAssociatedObject(self, TriggerForceKey, @(triggerForce), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)triggerForce
{
    return [objc_getAssociatedObject(self, TriggerForceKey) floatValue];
}

- (void)setPopLevel:(TapticFeedbackLevel)feedbackLevel
{
    objc_setAssociatedObject(self, PopLevelKey, @(feedbackLevel), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (TapticFeedbackLevel)popLevel
{
    return (TapticFeedbackLevel)[objc_getAssociatedObject(self, PopLevelKey) integerValue];
}

- (void)setFeedbackLevel:(TapticFeedbackLevel)feedbackLevel
{
    objc_setAssociatedObject(self, FeedbackLevelKey, @(feedbackLevel), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (TapticFeedbackLevel)feedbackLevel
{
    return (TapticFeedbackLevel)[objc_getAssociatedObject(self, FeedbackLevelKey) integerValue];
}

- (void)setFeedbackType:(TapticFeedbackType)feedbackType
{
    objc_setAssociatedObject(self, FeedbackTypeKey, @(feedbackType), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (TapticFeedbackType)feedbackType
{
    return (TapticFeedbackType)[objc_getAssociatedObject(self, FeedbackTypeKey) integerValue];
}

- (void)setImpactGenerator:(UIImpactFeedbackGenerator *)generator
{
    objc_setAssociatedObject(self, ImpactGeneratorKey, generator, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImpactFeedbackGenerator *)impactGenerator
{
    return objc_getAssociatedObject(self, ImpactGeneratorKey);
}

- (void)setSelectionGenerator:(UISelectionFeedbackGenerator *)generator
{
    objc_setAssociatedObject(self, SelectionGeneratorKey, generator, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UISelectionFeedbackGenerator * )selectionGenerator
{
    return objc_getAssociatedObject(self, SelectionGeneratorKey);
}

- (void)setNotificationGenerator:(UINotificationFeedbackGenerator *)generator
{
    objc_setAssociatedObject(self, NotificationGeneratorKey, generator, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UINotificationFeedbackGenerator *)notificationGenerator
{
    return objc_getAssociatedObject(self, NotificationGeneratorKey);
}


#pragma mark Default Taptic Overrides

- (void)installDefaultTapticControl
{
    //[self addTarget:self action:@selector(prepareTapticEngine) forControlEvents:UIControlEventTouchDown];
    //[self addTarget:self action:@selector(triggerTapticFeedback) forControlEvents:UIControlEventTouchUpInside];
    self.triggerForce = 4;
    Method touchesBegan = class_getInstanceMethod([self class], @selector(touchesBegan:withEvent:));
    Method beginTapticTrackingWithTouch = class_getInstanceMethod([self class], @selector(beginTapticTrackingWithTouch:withEvent:));
    method_exchangeImplementations(touchesBegan, beginTapticTrackingWithTouch);

    Method touchesMoved = class_getInstanceMethod([self class], @selector(touchesMoved:withEvent:));
    Method continueTapticTrackingWithTouch = class_getInstanceMethod([self class], @selector(continueTapticTrackingWithTouch:withEvent:));
    method_exchangeImplementations(touchesMoved, continueTapticTrackingWithTouch);

    Method touchesEnded = class_getInstanceMethod([self class], @selector(touchesEnded:withEvent:));
    Method endTapticTrackingWithTouch = class_getInstanceMethod([self class], @selector(endTapticTrackingWithTouch:withEvent:));
    method_exchangeImplementations(touchesEnded, endTapticTrackingWithTouch);
}

- (void)prepareTapticEngine
{
    switch ([self feedbackType]) {
        case kFeedbackLevelPulse: {
            if (!self.notificationGenerator) {
                self.notificationGenerator = [[UINotificationFeedbackGenerator alloc] init];
            }
            [self.notificationGenerator prepare];
            break;
        }
        case kFeedbackLevelSingle: {
            switch ([self feedbackLevel]) {
                case kFeedbackLevelStrong:
                case kFeedbackLevelMedium: {
                    if (!self.impactGenerator) {
                        self.impactGenerator = [[UIImpactFeedbackGenerator alloc] init];
                    }
                    [self.impactGenerator prepare];
                    break;
                }
                case kFeedbackLevelLight:
                default: {
                    if (!self.selectionGenerator) {
                        self.selectionGenerator = [[UISelectionFeedbackGenerator alloc] init];
                    }
                    [self.selectionGenerator prepare];
                    break;
                }
            }
        }
        default: break;
    }

    //[self triggerTapticFeedback];
}

- (void)triggerTapticFeedback
{
    switch ([self feedbackType]) {
        case kFeedbackLevelPulse: {

            switch ([self feedbackLevel]) {
                case kFeedbackLevelLight: { [self.notificationGenerator notificationOccurred:UINotificationFeedbackTypeSuccess]; NSLog(@"Success occured"); break;}
                case kFeedbackLevelMedium: { [self.notificationGenerator notificationOccurred:UINotificationFeedbackTypeWarning]; NSLog(@"Warning occured"); break;}
                case kFeedbackLevelStrong: { [self.notificationGenerator notificationOccurred:UINotificationFeedbackTypeError]; NSLog(@"Error occured"); break;}
                default: break;
            }
        }
        case kFeedbackLevelSingle: {
            switch ([self feedbackLevel]) {
                case kFeedbackLevelStrong:
                case kFeedbackLevelMedium: {
                    NSLog(@"Impact occured");
                    [self.impactGenerator impactOccurred];
                    break;
                }
                case kFeedbackLevelLight:
                default: {
                    NSLog(@"Selection occured");
                    [self.selectionGenerator selectionChanged];
                    break;
                }
            }
        }
        default: break;
    }
}

- (void)clearEngine
{
    self.notificationGenerator = nil;
    self.selectionGenerator = nil;
    self.impactGenerator = nil;
}

- (void)beginTapticTrackingWithTouch:(nonnull NSSet<UITouch *> *)touches
                           withEvent:(nullable UIEvent *)event
{
    [self beginTapticTrackingWithTouch:touches withEvent:event];
    NSLog(@"Begin tracking touch: %f", [touches anyObject].force);
    if ([touches anyObject].force < self.triggerForce) {
        [self prepareTapticEngine];
    }
}

- (void)continueTapticTrackingWithTouch:(nonnull NSSet<UITouch *> *)touches
                              withEvent:(nullable UIEvent *)event
{
    [self continueTapticTrackingWithTouch:touches withEvent:event];
    NSLog(@"Continue tracking touch: %f", [touches anyObject].force);

    if ([touches anyObject].force > (self.triggerForce / 2) &&
        [touches anyObject].force < self.triggerForce)
    {
        NSLog(@"Prepare feedback");
        [self setCanTaptic:YES];
        [self prepareTapticEngine];
    }

    if ([touches anyObject].force >= self.triggerForce && [self canTaptic]) {
        NSLog(@"Trigger feedback");
        [self setCanTaptic:NO];
        [self setShouldPop:YES];
        [self triggerTapticFeedback];
        [self triggerPop];
    }
}

- (void)triggerPop
{
    [self setShouldPop:NO];
    if ([self isPopEnabled]) {
        switch ([self feedbackLevel]) {
            case kFeedbackLevelStrong:
            {
                self.impactGenerator = [[UIImpactFeedbackGenerator alloc] init];
                [self.impactGenerator prepare];
                [self.impactGenerator impactOccurred];

                break;
            }

            case kFeedbackLevelMedium:
            case kFeedbackLevelLight:
            default: {
                self.selectionGenerator = [[UISelectionFeedbackGenerator alloc] init];
                [self.selectionGenerator prepare];
                [self.selectionGenerator selectionChanged];

                break;
            }
        }

    }
}

- (void)endTapticTrackingWithTouch:(nonnull NSSet<UITouch *> *)touches
                         withEvent:(nullable UIEvent *)event
{
    NSLog(@"End tracking touch: %f", [touches anyObject].force);
    if ([self shouldPop]) {
        NSLog(@"Trigger Pop");
        //[self triggerPop];
        [self clearEngine];
    }

    [self endTapticTrackingWithTouch:touches withEvent:event];
}




@end
