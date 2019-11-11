//
//  TSettingsViewController.h
//  BaseUI
//
//  Created by Ryan Joseph on 11/11/19.
//  Copyright © 2019 none. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSettingsViewController : NSViewController
@property (weak) IBOutlet NSButton *checkButton;
@property (weak) IBOutlet NSSegmentedControl *segmentedControl;

@end

NS_ASSUME_NONNULL_END
