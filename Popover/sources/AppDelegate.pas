{$mode objfpc}
{$modeswitch objectivec1}

unit AppDelegate;
interface
uses
	CocoaAll;

type
  TPopoverViewController = objcclass (NSViewController, NSPopoverDelegateProtocol)
    textField: NSTextField;
    popover: NSPopover;

    { NSPopoverDelegateProtocol }
    procedure popoverDidClose (notification: NSNotification); message 'popoverDidClose:';
  end;

type
	TAppDelegate = objcclass(NSObject, NSApplicationDelegateProtocol)
    private
      window: NSWindow;
  	public
  		procedure applicationDidFinishLaunching(notification: NSNotification); message 'applicationDidFinishLaunching:';
      procedure clickedTopLeft(sender: id); message 'clickedTopLeft:';
      procedure clickedTopRight(sender: id); message 'clickedTopRight:';
      procedure clickedBottomLeft(sender: id); message 'clickedBottomLeft:';
      procedure clickedBottomRight(sender: id); message 'clickedBottomRight:';
 	end;

implementation

function ShowPopover (title: string; positioningRect: NSRect; positioningView: NSView; preferredEdge: NSRectEdge): NSPopover;
var
  popover: NSPopover;
  controller: TPopoverViewController;
begin
  controller := TPopoverViewController.alloc.initWithNibName_bundle(NSSTR('TPopoverViewController'), nil).autorelease;

  popover := NSPopover.alloc.init;
  popover.setDelegate(controller);
  popover.setAnimates(true);
  popover.setBehavior(NSPopoverBehaviorTransient);

  popover.setContentViewController(controller);
  popover.setContentSize(controller.view.frame.size);
  popover.showRelativeToRect_ofView_preferredEdge(positioningRect, positioningView, preferredEdge);  
    
  { keep a reference we can release later }
  controller.popover := popover;
  controller.textField.setStringValue(NSSTR(title));

  result := popover;
end;

procedure TPopoverViewController.popoverDidClose (notification: NSNotification);
begin
  { release the popver controller }
  popover.autorelease;
  popover := nil;
end;


procedure TAppDelegate.clickedTopLeft(sender: id);
begin
  ShowPopover('Top Left Popover', sender.bounds, sender, NSMinXEdge);
end;

procedure TAppDelegate.clickedTopRight(sender: id);
begin
  ShowPopover('Top Right Popover', sender.bounds, sender, NSMaxXEdge);
end;

procedure TAppDelegate.clickedBottomLeft(sender: id);
begin
  ShowPopover('Bottom Left Popover', sender.bounds, sender, NSMinXEdge + NSMinYEdge);
end;

procedure TAppDelegate.clickedBottomRight(sender: id);
begin
  ShowPopover('Bottom Right Popover', sender.bounds, sender, NSMaxXEdge + NSMaxYEdge);
end;

procedure TAppDelegate.applicationDidFinishLaunching(notification : NSNotification);
begin
	// Insert code here to initialize your application 
end;

end.