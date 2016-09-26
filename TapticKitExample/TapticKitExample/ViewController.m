//
//  ViewController.m
//  TapticKitExample
//
//  Created by Tj on 9/25/16.
//  Copyright © 2016 Tj. All rights reserved.
//

#import "ViewController.h"
#import "TapticKit.h"

@interface ViewController ()

@property (nonatomic, weak) IBOutlet UIButton *button; // At least this one works

@property (nonatomic, weak) IBOutlet UITableView *tableview; // NYI
@property (nonatomic, weak) IBOutlet UISlider *slider; // NYI
@property (nonatomic, weak) IBOutlet UIBarButtonItem *item; // NYI
@property (nonatomic, weak) IBOutlet UISwitch *sSwitch; // Cause "switch", ugh.

@property (nonatomic, strong) IBOutletCollection(UIControl) NSArray *tapticControls;

@property (nonatomic, weak) IBOutlet UISegmentedControl *typeControl;
@property (nonatomic, weak) IBOutlet UISegmentedControl *pulseControl;
@property (nonatomic, weak) IBOutlet UISegmentedControl *singleControl;
@property (nonatomic, weak) IBOutlet UISlider *thresholdSlider;
@property (nonatomic, weak) IBOutlet UILabel *thresholdText;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.tapticControls enumerateObjectsUsingBlock:^(UIControl *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj setTapticEnabled:YES];
        [obj setPopEnabled:YES];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)typeChanged:(UISegmentedControl *)sender
{
    if ([sender selectedSegmentIndex]) {
        [self.pulseControl setHidden:NO];
        [self.singleControl setHidden:YES];
    } else {
        [self.pulseControl setHidden:YES];
        [self.singleControl setHidden:NO];
    }
    [self.tapticControls enumerateObjectsUsingBlock:^(UIControl *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj setFeedbackType:sender.selectedSegmentIndex];
    }];
}

- (IBAction)levelChanged:(UISegmentedControl *)sender
{
    [self.tapticControls enumerateObjectsUsingBlock:^(UIControl *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj setFeedbackLevel:sender.selectedSegmentIndex];
    }];
}

- (IBAction)thresholdChanged:(UISlider *)sender
{
    [self.tapticControls enumerateObjectsUsingBlock:^(UIControl *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj setTriggerForce:sender.value];
    }];

    [self.thresholdText setText:[NSString stringWithFormat:@"Trigger Threshold: %.2f", sender.value]];
}

@end
