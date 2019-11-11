{$mode objfpc}
{$modeswitch advancedrecords}
{$modeswitch objectivec1}
{$modeswitch autoderef}

unit AppDelegate;
interface
uses
	FGL, CocoaAll;

type
  TDataItem = record
    name: string;
    image: NSString;
    details: string;
    class operator = (left: TDataItem; right: TDataItem): boolean;
  end;
  PDataItem = ^TDataItem;
  TDataItemList = specialize TFPGList<TDataItem>;

type
	TAppDelegate = objcclass(NSObject, NSApplicationDelegateProtocol, NSTableViewDataSourceProtocol)
    private
      window: NSWindow;
      dataTableView: NSTableView;
      items: TDataItemList;
  	public
      procedure awakeFromNib; override;
  		procedure applicationDidFinishLaunching(notification: NSNotification); message 'applicationDidFinishLaunching:';

      { NSTableViewDataSourceProtocol }
      function numberOfRowsInTableView (tableView: NSTableView): NSInteger; message 'numberOfRowsInTableView:';
      function tableView_viewForTableColumn_row (tableView: NSTableView; tableColumn: NSTableColumn; row: NSInteger): NSView; message 'tableView:viewForTableColumn:row:';
 	end;

implementation
uses
  CocoaUtils, SysUtils, MacOSAll;

var
  CellDataTag: NSString;

class operator TDataItem.= (left: TDataItem; right: TDataItem): boolean;
begin
  result := (@left = @right);
end;

type
  TCustomCellView = objcclass (NSTableCellView)
    labelView: NSTextField;
  end;

function TAppDelegate.numberOfRowsInTableView (tableView: NSTableView): NSInteger;
begin
  if assigned(items) then
    result := items.Count
  else
    result := 0;
end;

function TAppDelegate.tableView_viewForTableColumn_row (tableView: NSTableView; tableColumn: NSTableColumn; row: NSInteger): NSView;
var
  cellView: TCustomCellView;
  item: TDataItem;
begin
  cellView := tableView.makeViewWithIdentifier_owner(tableColumn.identifier, self);
  
  item := items[row];
  
  cellView.textField.setStringValue(NSSTR(item.name));
  cellView.imageView.setImage(NSImage.imageNamed(item.image));
  cellView.labelView.setStringValue(NSSTR(item.details));
    
  result := cellView;
end;


procedure TAppDelegate.awakeFromNib;
var
  item: TDataItem;
begin
  CellDataTag := NSSTR('CellDataTag').retain;

  writeln(string(dataTableView));
  dataTableView.registerForDraggedTypes(NSArray.arrayWithObjects(CellDataTag, nil));


  items := TDataItemList.Create;

  item.name := 'Data Item 1';
  item.details := 'My Data 1 Item Details';
  item.image := NSImageNameBonjour;
  items.Add(item);

  item.name := 'Data Item 2';
  item.details := 'My Data 2 Item Details';
  item.image := NSImageNameComputer;
  items.Add(item);
end;

procedure TAppDelegate.applicationDidFinishLaunching(notification : NSNotification);
begin
end;

end.