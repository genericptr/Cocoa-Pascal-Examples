#import <Cocoa/Cocoa.h>

@interface TAppDelegate : NSObject <NSApplicationDelegate>
@property (weak) IBOutlet NSImageView *dropImageView;
@property (weak) IBOutlet NSTextField *dropLabel;
@property (weak) IBOutlet TDragImageView *dragImageView;


@end

