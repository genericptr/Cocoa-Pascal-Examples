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
    id: integer;
    class operator = (left: TDataItem; right: TDataItem): boolean;
  end;
  PDataItem = ^TDataItem;
  TDataItemList = specialize TFPGList<TDataItem>;

type
	TAppDelegate = objcclass(NSObject, NSApplicationDelegateProtocol, NSTableViewDataSourceProtocol, NSTableViewDelegateProtocol)
    private
      window: NSWindow;
      dataTableView: NSTableView;
      items: TDataItemList;
  	public
      procedure awakeFromNib; override;
  		procedure applicationDidFinishLaunching(notification: NSNotification); message 'applicationDidFinishLaunching:';

      { NSTableViewDataSourceProtocol }
      function numberOfRowsInTableView (tableView: NSTableView): NSInteger; message 'numberOfRowsInTableView:';
      function tableView_objectValueForTableColumn_row (tableView: NSTableView; tableColumn: NSTableColumn; row: NSInteger): id; message 'tableView:objectValueForTableColumn:row:';
      procedure tableView_setObjectValue_forTableColumn_row (tableView: NSTableView; object_: id; tableColumn: NSTableColumn; row: NSInteger); message 'tableView:setObjectValue:forTableColumn:row:';
      function tableView_writeRowsWithIndexes_toPasteboard (tableView: NSTableView; rowIndexes: NSIndexSet; pboard: NSPasteboard): boolean; message 'tableView:writeRowsWithIndexes:toPasteboard:';
      function tableView_acceptDrop_row_dropOperation (tableView: NSTableView; info: NSDraggingInfoProtocol; row: NSInteger; dropOperation: NSTableViewDropOperation): boolean; message 'tableView:acceptDrop:row:dropOperation:';
      function tableView_validateDrop_proposedRow_proposedDropOperation(tableView: NSTableView; info: id; row: NSInteger; dropOperation: NSTableViewDropOperation): NSDragOperation; message 'tableView:validateDrop:proposedRow:proposedDropOperation:';

      { NSTableViewDelegateProtocol }
      function tableView_shouldEditTableColumn_row (tableView: NSTableView; tableColumn: NSTableColumn; row: NSInteger): boolean; message 'tableView:shouldEditTableColumn:row:';
 	end;

implementation
uses
  CocoaUtils, SysUtils, MacOSAll;

var
  CellDataTag: NSString;

class operator TDataItem.= (left: TDataItem; right: TDataItem): boolean;
begin
  result := (left.id = right.id);
end;

function TAppDelegate.numberOfRowsInTableView (tableView: NSTableView): NSInteger;
begin
  if assigned(items) then
    result := items.Count
  else
    result := 0;
end;

procedure TAppDelegate.tableView_setObjectValue_forTableColumn_row (tableView: NSTableView; object_: id; tableColumn: NSTableColumn; row: NSInteger);
var
  item: PDataItem;
begin
  if tableColumn.title = 'Name' then
    begin
      item := TFPSList(items)[row];
      item.name := object_.UTF8String;
    end;
end;

function TAppDelegate.tableView_objectValueForTableColumn_row (tableView: NSTableView; tableColumn: NSTableColumn; row: NSInteger): id;
begin
  if tableColumn.title = 'ID' then
    result := NSSTR(IntToStr(items[row].id))
  else if tableColumn.title = 'Name' then
    result := NSSTR(items[row].name)
  else
    result := nil;
end;

function TAppDelegate.tableView_shouldEditTableColumn_row (tableView: NSTableView; tableColumn: NSTableColumn; row: NSInteger): boolean;
begin
  if tableColumn.title = 'Name' then
    result := true
  else
    result := false;
end;

function TAppDelegate.tableView_validateDrop_proposedRow_proposedDropOperation(tableView: NSTableView; info: id; row: NSInteger; dropOperation: NSTableViewDropOperation): NSDragOperation;
var
  pasteboard: NSPasteboard;
begin
  pasteboard := info.draggingPasteboard;
  result := NSDragOperationNone;

  if (dropOperation = NSTableViewDropAbove) and (pasteboard.dataForType(CellDataTag) <> nil) then
    exit(NSDragOperationEvery);
end;

function TAppDelegate.tableView_acceptDrop_row_dropOperation (tableView: NSTableView; info: NSDraggingInfoProtocol; row: NSInteger; dropOperation: NSTableViewDropOperation): boolean;
var
  pboard: NSPasteboard;
  rowData: NSData;
  rowIndexes: NSIndexSet;
  dragRow: NSInteger;
  pasteboardItem: NSPasteboardItem;
  path: NSString;
begin
  pboard := NSDraggingInfoProtocol(info).draggingPasteboard;
  result := false;
  
  if pboard.dataForType(CellDataTag) <> nil then
    begin
      rowData := pboard.dataForType(CellDataTag);
      rowIndexes := NSKeyedUnarchiver.unarchiveObjectWithData(rowData);
      dragRow := rowIndexes.firstIndex;
      writeln('move ', dragRow, ' to ', row);
      if row > items.Count - 1 then
        row := items.Count - 1;
      items.Exchange(dragRow, row);
      result := true;
    end;
  
end;

function TAppDelegate.tableView_writeRowsWithIndexes_toPasteboard(tableView: NSTableView; rowIndexes: NSIndexSet; pboard: NSPasteboard): Boolean;
var
  data: NSData;
begin
  data := NSKeyedArchiver.archivedDataWithRootObject(rowIndexes);
  pboard.declareTypes_owner(NSArray.arrayWithObject(CellDataTag), self);
  pboard.setData_forType(data, CellDataTag);
  result := true;
end;

procedure TAppDelegate.awakeFromNib;
var
  item: TDataItem;
  i: integer;
begin
  CellDataTag := NSSTR('CellDataTag').retain;

  dataTableView.registerForDraggedTypes(NSArray.arrayWithObjects(CellDataTag, nil));

  items := TDataItemList.Create;

  for i := 0 to 9 do
    begin
      item.name := 'Data Item '+IntToStr(i + 1);
      item.id := (i + 1) * 100;
      items.Add(item);
    end;

end;

procedure TAppDelegate.applicationDidFinishLaunching(notification : NSNotification);
begin
end;

end.