{$mode objfpc}
{$modeswitch objectivec2}

unit AppDelegate;
interface
uses
	FGL, CocoaUtils, CocoaAll;

type
  TDataNode = class;
  TDataNodeList = specialize TFPGList<TDataNode>;

  TDataNode = class
    path: ansistring;
    children: TDataNodeList;
    parent: TDataNode;
    ref: TCocoaObject;
    constructor Create(_path: ansistring);
    destructor Destroy; override;
    function ChildCount: integer;
    function ItemAt(index: integer): id;
    procedure AddChild(child: TDataNode);
    procedure InsertChild(child: TDataNode; index: integer);
    procedure RemoveFromParent;
    function FileName: string;
    function IsFolder: boolean;
    procedure Reload;
  end;

type
	TAppDelegate = objcclass(NSObject, NSApplicationDelegateProtocol, NSOutlineViewDataSourceProtocol, NSOutlineViewDelegateProtocol)
    private
      window: NSWindow;
      dataOutlineView: NSOutlineView;
      root: TDataNode;
  	public
      procedure loadData; message 'loadData';
  		procedure applicationDidFinishLaunching(notification: NSNotification); message 'applicationDidFinishLaunching:';

      { NSOutlineViewDataSourceProtocol }
      function outlineView_numberOfChildrenOfItem (outlineView: NSOutlineView; item: id): NSInteger; message 'outlineView:numberOfChildrenOfItem:';
      function outlineView_child_ofItem (outlineView: NSOutlineView; index: NSInteger; item: id): id; message 'outlineView:child:ofItem:';
      function outlineView_isItemExpandable (outlineView: NSOutlineView; item: id): boolean; message 'outlineView:isItemExpandable:';
      function outlineView_writeItems_toPasteboard(outlineView: NSOutlineView; writeItems: NSArray; pasteboard: NSPasteboard): Boolean; message 'outlineView:writeItems:toPasteboard:';
      function outlineView_validateDrop_proposedItem_proposedChildIndex(outlineView: NSOutlineView; info: id; item: id; index: NSInteger): NSDragOperation; message 'outlineView:validateDrop:proposedItem:proposedChildIndex:';
      function outlineView_acceptDrop_item_childIndex(outlineView: NSOutlineView; info: NSDraggingInfoProtocol; item: id; index: NSInteger): Boolean; message 'outlineView:acceptDrop:item:childIndex:';

      { NSOutlineViewDelegateProtocol }
      function outlineView_viewForTableColumn_item (outlineView: NSOutlineView; tableColumn: NSTableColumn; item: id): NSView; message 'outlineView:viewForTableColumn:item:';
      procedure outlineViewItemWillExpand (notification: NSNotification); message 'outlineViewItemWillExpand:';
      procedure outlineViewItemDidCollapse (notification: NSNotification); message 'outlineViewItemDidCollapse:';

 	end;

implementation
uses
  BaseUnix, SysUtils, MacOSAll;

var
  DataNodeTag: NSString;

type
  TCustomCellView = objcclass (NSTableCellView)
    labelView: NSTextField;
  end;

constructor TDataNode.Create(_path: ansistring);
begin
  path := _path;
  ref := TCocoaObject.alloc.initWithObject(self);
end;

destructor TDataNode.Destroy;
begin
  FreeAndNil(children);
  ref.release;
end;

function TDataNode.ChildCount: integer;
begin
  if assigned(children) then
    result := children.Count
  else
    result := 0;
end;

function TDataNode.FileName: string;
begin
  result := ExtractFileName(path);
end;

function TDataNode.IsFolder: boolean;
var
  info : stat;
begin
  if fpstat(path, info) = 0 then
    result := fpS_ISDIR(info.st_mode)
  else
    result := false;
end;

function TDataNode.ItemAt(index: integer): id;
begin
  result := children[index].ref;
end;

procedure TDataNode.RemoveFromParent;
begin
  if assigned(parent) then
    begin
      parent.children.Remove(self);
      parent := nil;
    end;
end;

procedure TDataNode.AddChild(child: TDataNode);
begin
  child.RemoveFromParent;
  if children = nil then
    Reload;
  children.Add(child);
  child.parent := self;
end;

procedure TDataNode.InsertChild(child: TDataNode; index: integer);
begin
  child.RemoveFromParent;
  if children = nil then
    Reload;
  children.Insert(index, child);
  child.parent := self;
end;


procedure TDataNode.Reload; 
var
  handle: PDir;
  entry: PDirent;
  name: pchar;
begin
  children := TDataNodeList.Create;
  handle := fpOpenDir(path);
  if assigned(handle) then
    begin
      while true do
        begin
          entry := fpReadDir(handle);
          if assigned(entry) then
            begin
              name := pchar(@entry^.d_name[0]);
              if name[0] = '.' then
                continue;
              AddChild(TDataNode.Create(path+'/'+name));
            end
          else
            break;
        end;
      fpCloseDir(handle);
    end;
end;

function TAppDelegate.outlineView_numberOfChildrenOfItem (outlineView: NSOutlineView; item: id): NSInteger;
begin
  if item = nil then
    begin
      if root = nil then
        loadData;
      result := root.ChildCount;
    end
  else
    result := TDataNode(item.obj).ChildCount;
end;

function TAppDelegate.outlineView_child_ofItem (outlineView: NSOutlineView; index: NSInteger; item: id): id;
begin
  if item = nil then
    result := root.ItemAt(index)
  else
    result := TDataNode(item.obj).ItemAt(index);
end;

function TAppDelegate.outlineView_isItemExpandable (outlineView: NSOutlineView; item: id): boolean;
begin
  if item = nil then
    result := false
  else
    result := TDataNode(item.obj).IsFolder;
end;


function TAppDelegate.outlineView_viewForTableColumn_item (outlineView: NSOutlineView; tableColumn: NSTableColumn; item: id): NSView;
var
  node: TDataNode;
  cellView: NSTableCellView;
  customCellView: TCustomCellView;
  fileImage: NSImage;
  formatter: NSDateFormatter;
begin
  if tableColumn.title = 'Name' then
    begin
      customCellView := outlineView.makeViewWithIdentifier_owner(NSSTR('CustomCell'), self);
      
      node := TDataNode(item.obj);

      fileImage := NSWorkspace.sharedWorkspace.iconForFile(NSSTR(node.path));

      customCellView.textField.setStringValue(NSSTR(node.FileName));
      customCellView.imageView.setImage(fileImage);
      customCellView.labelView.setStringValue(NSSTR('Last modified: '+DateTimeToStr(FileDateToDateTime(FileAge(node.path)))));

      result := customCellView;
    end
  else if tableColumn.title = 'Children' then
    begin
      cellView := outlineView.makeViewWithIdentifier_owner(NSSTR('DataCell'), self);

      node := TDataNode(item.obj);

      if node.IsFolder then
        cellView.textField.setStringValue(NSSTR(IntToStr(node.ChildCount)))
      else
        cellView.textField.setStringValue(NSSTR(''));

      result := cellView;
    end
  else
    result := nil;


end;

function TAppDelegate.outlineView_writeItems_toPasteboard(outlineView: NSOutlineView; writeItems: NSArray; pasteboard: NSPasteboard): Boolean;
var
  data: NSData;
  pasteboardItems: NSMutableArray;
  pasteboardItem: NSPasteboardItem;
  item: id;
begin
  pasteboardItems := NSMutableArray.array_;
  
  for item in writeItems do
    begin       
      pasteboardItem := NSPasteboardItem.alloc.init;
      pasteboardItem.setData_forType(NSKeyedArchiver.archivedDataWithRootObject(item), DataNodeTag);
      pasteboardItems.addObject(pasteboardItem);
      pasteboardItem.release;
    end;
  
  pasteboard.writeObjects(pasteboardItems); 
  
  result := true;
end;

function TAppDelegate.outlineView_validateDrop_proposedItem_proposedChildIndex(outlineView: NSOutlineView; info: id; item: id; index: NSInteger): NSDragOperation;
var
  target: TDataNode;
begin
  result := NSDragOperationNone;

  if item <> nil then
    target := TDataNode(item.obj)
  else
    target := root;
  
  if target.IsFolder then
    result := NSDragOperationGeneric;
end;

function TAppDelegate.outlineView_acceptDrop_item_childIndex(outlineView: NSOutlineView; info: NSDraggingInfoProtocol; item: id; index: NSInteger): Boolean;
var
  pasteboard: NSPasteboard;
  pasteboardItem: NSPasteboardItem;
  data: NSData;
  source,
  target: TDataNode;
begin
  pasteboard := info.draggingPasteboard;
  result := false;
  
  if item <> nil then
    target := TDataNode(item.obj)
  else
    target := root;
  
  for pasteboardItem in info.draggingPasteboard.pasteboardItems do
    begin
      data := pasteboardItem.dataForType(DataNodeTag);
      if data <> nil then
        begin
          source := NSKeyedUnarchiver.unarchiveObjectWithData(data).obj as TDataNode;
          
          if info.draggingSource = outlineView then 
            begin
              if index = -1 then
                begin
                  if target.IsFolder then
                    begin
                      target.AddChild(source);
                      result := true;
                    end
                end
              else
                begin
                  target.InsertChild(source, index);
                  result := true;
                end;

              if result then
                outlineView.reloadData;
            end;
          
          continue;
        end;      
    end;
end;

procedure TAppDelegate.outlineViewItemWillExpand (notification: NSNotification);
var
  node: TDataNode;
begin
  node := notification.userInfo.objectForKey(NSSTR('NSObject')).obj as TDataNode;
  if node.children = nil then
    node.Reload;
end;

procedure TAppDelegate.outlineViewItemDidCollapse (notification: NSNotification);
var
  node: TDataNode;
begin
  node := notification.userInfo.objectForKey(NSSTR('NSObject')).obj as TDataNode;
end;

procedure TAppDelegate.loadData;
var
  node: TDataNode;
begin
  root := TDataNode.Create(NSSTR('~/Desktop').stringByExpandingTildeInPath.UTF8String);
  root.Reload;
end;

procedure TAppDelegate.applicationDidFinishLaunching(notification : NSNotification);
begin
  DataNodeTag := NSString.alloc.initWithUTF8String('data.TDataNode');
  dataOutlineView.registerForDraggedTypes(NSArray.arrayWithObject(DataNodeTag));
end;

end.