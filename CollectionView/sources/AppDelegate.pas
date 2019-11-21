{$mode objfpc}
{$modeswitch objectivec2}

unit AppDelegate;
interface
uses
	Classes, FGL, CocoaUtils, CocoaAll;

type
  TFileItem = class
    path: ansistring;
    constructor Create(_path: ansistring);
    function FileName: string;
  end;
  TPathList = specialize TFPGList<ansistring>;

type
  TCustomViewItem = objcclass (NSCollectionViewItem)
    iconView: NSButton;
    labelView: NSTextField;
    item: TFileItem;
    procedure viewWillLayout; override;
    procedure awakeFromNib; override;
    procedure setRepresentedObject(newValue: id); override;
  end;

type
	TAppDelegate = objcclass(NSObject, NSApplicationDelegateProtocol, NSCollectionViewDelegateProtocol)
    private
      window: NSWindow;
      scaleSlider: NSSlider;
      collectionView: NSCollectionView;
      collectionViewItem: TCustomViewItem;
      items: NSMutableArray;
      originalSize: NSSize;
  	public
  		procedure applicationDidFinishLaunching(notification: NSNotification); message 'applicationDidFinishLaunching:';

      function scaleFactor: single; message 'scaleFactor';
      procedure sliderChanged(sender: id); message 'sliderChanged:';
      procedure reloadFolder(path: NSString; appendStack: boolean); message 'reloadFolder:appendStack:';
 	end;

implementation
uses
  BaseUnix, SysUtils, MacOSAll;

var
  App: TAppDelegate;

constructor TFileItem.Create(_path: ansistring);
begin
  path := _path;
end;

function TFileItem.FileName: string;
begin
  result := ExtractFileName(path);
end;

procedure TCustomViewItem.setRepresentedObject(newValue: id);
begin
  if newValue = nil then
    exit;
  item := newValue.obj as TFileItem;
end;

procedure TCustomViewItem.viewWillLayout;
var
  scaleFactor,
  fontSize: single;
begin
  scaleFactor := collectionView.minItemSize.width / 100;
  fontSize := 13 * scaleFactor;
  if fontSize < 9 then
    fontSize := 9
  else if fontSize > 14 then
    fontSize := 14;
  labelView.setFont(NSFont.systemFontOfSize(fontSize));
end;

procedure TCustomViewItem.awakeFromNib;
var
  fileImage: NSImage;
begin
  if assigned(item) then
    begin
      fileImage := NSWorkspace.sharedWorkspace.iconForFile(NSSTR(item.path));
      iconView.setImage(fileImage);
      labelView.setStringValue(NSSTR(item.FileName));
    end;
end;

function LoadFolder(path: ansistring): NSMutableArray; 
var
  handle: PDir;
  entry: PDirent;
  name: pchar;
begin
  result := NSMutableArray.alloc.init;
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
              result.addObject(TFileItem.Create(path+'/'+name));
            end
          else
            break;
        end;
      fpCloseDir(handle);
    end;
end;

function TAppDelegate.scaleFactor: single;
begin
  result := scaleSlider.floatValue / 100;
end;

procedure TAppDelegate.sliderChanged(sender: id);
begin
  collectionView.setMinItemSize(NSMakeSize(originalSize.width * scaleFactor, originalSize.height * scaleFactor));
  collectionView.setMaxItemSize(NSMakeSize(originalSize.width * scaleFactor, originalSize.height * scaleFactor));
end;

procedure TAppDelegate.reloadFolder(path: NSString; appendStack: boolean);
begin
  window.setTitle(path.lastPathComponent);

  items.release;
  items := LoadFolder(path.UTF8String);
  collectionView.setContent(items);
end;

procedure TAppDelegate.applicationDidFinishLaunching(notification : NSNotification);
begin
  App := self;

  collectionViewItem := TCustomViewItem.alloc.initWithNibName_bundle(NSSTR('TCustomViewItem'), nil);
  
  originalSize := collectionViewItem.view.bounds.size;

  collectionView.setMinItemSize(NSMakeSize(originalSize.width * scaleFactor, originalSize.height * scaleFactor));
  collectionView.setMaxItemSize(NSMakeSize(originalSize.width * scaleFactor, originalSize.height * scaleFactor));

  collectionView.setItemPrototype(collectionViewItem);

  reloadFolder(NSSTR('~/Desktop').stringByExpandingTildeInPath, true)
end;

end.