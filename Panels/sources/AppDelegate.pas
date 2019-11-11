{$mode objfpc}
{$modeswitch objectivec1}

unit AppDelegate;
interface
uses
	Classes, CocoaAll;

type
	TAppDelegate = objcclass(NSObject, NSApplicationDelegateProtocol, NSOutlineViewDataSourceProtocol, NSOutlineViewDelegateProtocol)
    private
      window: NSWindow;
      panelView: NSOutlineView;
      panelContainer: NSView;
      panels: TList;
      activePanel: NSViewController;
  	public
  		procedure applicationDidFinishLaunching(notification: NSNotification); message 'applicationDidFinishLaunching:';
      procedure loadPanels; message 'loadPanels';

      { NSOutlineViewDataSourceProtocol }
      function outlineView_numberOfChildrenOfItem (outlineView: NSOutlineView; item: id): NSInteger; message 'outlineView:numberOfChildrenOfItem:';
      function outlineView_child_ofItem (outlineView: NSOutlineView; index: NSInteger; item: id): id; message 'outlineView:child:ofItem:';
      function outlineView_isItemExpandable (outlineView: NSOutlineView; item: id): boolean; message 'outlineView:isItemExpandable:';

      { NSOutlineViewDelegateProtocol }
      function outlineView_viewForTableColumn_item (outlineView: NSOutlineView; tableColumn: NSTableColumn; item: id): NSView; message 'outlineView:viewForTableColumn:item:';
      procedure outlineViewSelectionDidChange (notification: NSNotification); message 'outlineViewSelectionDidChange:';
 	end;

implementation
uses
  CocoaUtils;

type
  TMainViewController = objcclass (NSViewController)
    popupButton: NSPopUpButton;
    procedure viewDidLoad; override;
  end;

type
  TSettingsViewController = objcclass (NSViewController)
    checkButton: NSButton;
    segmentedControl: NSSegmentedControl;
    procedure viewDidLoad; override;
  end;

procedure TMainViewController.viewDidLoad;
begin
  writeln('TMainViewController loaded');
end;

procedure TSettingsViewController.viewDidLoad;
begin
  writeln('TSettingsViewController loaded');
end;

function TAppDelegate.outlineView_numberOfChildrenOfItem (outlineView: NSOutlineView; item: id): NSInteger;
begin
  if panels = nil then
    loadPanels;
  result := panels.Count;
end;

function TAppDelegate.outlineView_child_ofItem (outlineView: NSOutlineView; index: NSInteger; item: id): id;
begin
  result := panels[index];
end;

function TAppDelegate.outlineView_isItemExpandable (outlineView: NSOutlineView; item: id): boolean;
begin
  result := false;
end;

function TAppDelegate.outlineView_viewForTableColumn_item (outlineView: NSOutlineView; tableColumn: NSTableColumn; item: id): NSView;
var
  cellView: NSTableCellView;
  panel: NSViewController;
begin
  cellView := outlineView.makeViewWithIdentifier_owner(NSSTR('DataCell'), self);
  
  panel := NSViewController(item);
  cellView.textField.setStringValue(panel.title);
    
  result := cellView;
end;

procedure TAppDelegate.outlineViewSelectionDidChange (notification: NSNotification);
var
  panel: NSViewController;
begin
  if assigned(activePanel) then
    begin
      activePanel.view.removeFromSuperview;
      activePanel := nil;
    end;

  panel := NSViewController(panels[panelView.selectedRow]);

  panel.view.setFrameOrigin(NSMakePoint(0, 0));
  panelContainer.addSubview(panel.view);

  activePanel := panel;
end;

procedure TAppDelegate.loadPanels; 
var
  controller: NSViewController;
begin
  panels := TList.Create;

  controller := TSettingsViewController.alloc.initWithNibName_bundle(NSSTR('TMainViewController'), nil);
  controller.setTitle(NSSTR('Main'));
  panels.Add(controller);

  controller := TMainViewController.alloc.initWithNibName_bundle(NSSTR('TSettingsViewController'), nil);
  controller.setTitle(NSSTR('Settings'));
  panels.Add(controller);
end;

procedure TAppDelegate.applicationDidFinishLaunching(notification : NSNotification);
begin

end;

end.