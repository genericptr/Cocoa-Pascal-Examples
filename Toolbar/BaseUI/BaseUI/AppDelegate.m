#import "AppDelegate.h"

@interface TAppDelegate ()
@property (weak) IBOutlet NSTabView *tabView;

@property (weak) IBOutlet NSWindow *window;
@end

@implementation TAppDelegate
- (IBAction)showGeneralPanel:(id)sender {
}
- (IBAction)showAdvancedPanel:(id)sender {
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
	// Insert code here to tear down your application
}


@end
