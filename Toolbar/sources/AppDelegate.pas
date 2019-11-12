{$mode objfpc}
{$modeswitch objectivec2}

unit AppDelegate;
interface
uses
	CocoaAll;

type
	TAppDelegate = objcclass(NSObject, NSApplicationDelegateProtocol, NSTabViewDelegateProtocol)
    private
      window: NSWindow;
      tabView: NSTabView;
  	public 
  		procedure applicationDidFinishLaunching(notification: NSNotification); message 'applicationDidFinishLaunching:';

      procedure showGeneralPanel(sender: id); message 'showGeneralPanel:';
      procedure showAdvancedPanel(sender: id); message 'showAdvancedPanel:';
 	end;

implementation

procedure TAppDelegate.showGeneralPanel(sender: id);
begin
  tabView.selectTabViewItemAtIndex(0);
end;

procedure TAppDelegate.showAdvancedPanel(sender: id);
begin
  tabView.selectTabViewItemAtIndex(1);
end;

procedure TAppDelegate.applicationDidFinishLaunching(notification : NSNotification);
begin
  window.toolbar.setSelectedItemIdentifier(NSSTR('General'));
  tabView.selectTabViewItemAtIndex(0);
end;

end.