#import <Cocoa/Cocoa.h>

@interface TAppDelegate : NSObject <NSApplicationDelegate>
@property (weak) IBOutlet NSCollectionView *collectionView;
@property (weak) IBOutlet NSSlider *scaleSlider;

@end

