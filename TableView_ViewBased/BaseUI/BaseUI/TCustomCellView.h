//
//  TCustomCellView.h
//  BaseUI
//
//  Created by Ryan Joseph on 11/11/19.
//  Copyright © 2019 none. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface TCustomCellView : NSTableCellView
@property (unsafe_unretained) IBOutlet NSTextField *labelView;

@end

NS_ASSUME_NONNULL_END
