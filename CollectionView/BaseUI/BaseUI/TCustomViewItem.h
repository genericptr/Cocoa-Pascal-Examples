//
//  TCustomViewItem.h
//  BaseUI
//
//  Created by Ryan Joseph on 11/18/19.
//  Copyright © 2019 none. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface TCustomViewItem : NSCollectionViewItem
@property (weak) IBOutlet NSButton *iconView;
@property (weak) IBOutlet NSTextField *labelView;

@end

NS_ASSUME_NONNULL_END
