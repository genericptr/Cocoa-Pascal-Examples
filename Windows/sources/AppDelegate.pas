{$mode objfpc}
{$modeswitch objectivec1}
{$modeswitch cblocks}

unit AppDelegate;
interface
uses
	CocoaAll;

type
	TAppDelegate = objcclass(NSObject, NSApplicationDelegateProtocol)
    private
      window: NSWindow;
  	public
  		procedure applicationDidFinishLaunching(notification: NSNotification); message 'applicationDidFinishLaunching:';
      procedure newWindow(sender: id); message 'newWindow:';
 	end;

implementation

type
  TCustomWindowController = objcclass (NSWindowController, NSWindowDelegateProtocol)
    procedure clickedButton(sender: id); message 'clickedButton:';
    procedure windowDidLoad; override;

    { NSWindowDelegateProtocol }
    procedure windowWillClose (notification: NSNotification); message 'windowWillClose:';
  end;

type
  NSAlertCompletionBlock = reference to procedure(response: NSModalResponse); cdecl;

procedure AlertCompleted(response: NSModalResponse);
begin
  writeln('response: ', response);
end;

procedure TCustomWindowController.clickedButton(sender: id);
var
  completionHandler: NSAlertCompletionBlock;
  alert: NSAlert;
begin
  completionHandler := @AlertCompleted;

  alert := NSAlert.alloc.init;
  alert.setMessageText(NSSTR('Clicked!'));
  alert.setInformativeText(NSSTR('more information...'));
  alert.addButtonWithTitle(NSSTR('Ok'));
  alert.beginSheetModalForWindow_completionHandler(window, OpaqueCBlock(completionHandler));
end;

procedure TCustomWindowController.windowWillClose (notification: NSNotification);
begin
  { we get NSWindowDelegate messages because the windows delegate is set to the controller }
  writeln('window will close');
end;

procedure TCustomWindowController.windowDidLoad;
begin
  window.setTitle(NSSTR(HexStr(self)));
end;

procedure TAppDelegate.newWindow(sender: id);
var
  controller: TCustomWindowController;
begin
  controller := TCustomWindowController.alloc.initWithWindowNibName(NSSTR('TCustomWindowController'));
  if assigned(controller) then
    controller.showWindow(nil);
end;

procedure TAppDelegate.applicationDidFinishLaunching(notification : NSNotification);
begin
  newWindow(nil);
end;

end.