{$mode objfpc}
{$modeswitch objectivec2}

unit AppDelegate;
interface
uses
	FGL, CocoaAll;

type
  TDropImageView = objcclass (NSImageView, NSDraggingDestinationProtocol)        
    private
      { NSDraggingDestinationProtocol }
      function draggingEntered (sender: NSDraggingInfoProtocol): NSDragOperation; override;
      function performDragOperation (sender: NSDraggingInfoProtocol): objcbool; override;
  end;

type
  TDragImageView = objcclass (NSImageView)        
    private
      procedure mouseDragged(theEvent: NSEvent); override;
  end;


type
	TAppDelegate = objcclass(NSObject, NSApplicationDelegateProtocol, NSTableViewDataSourceProtocol, NSTableViewDelegateProtocol)
    private
      window: NSWindow;
      dropImageView: TDropImageView;
      dragImageview: TDragImageView;
      dropLabel: NSTextField;
  	public
  		procedure applicationDidFinishLaunching(notification: NSNotification); message 'applicationDidFinishLaunching:';
 	end;

implementation
uses
  CocoaUtils, SysUtils, MacOSAll;

procedure TDragImageView.mouseDragged(theEvent: NSEvent);
var
  transparentDragImage: NSImage;
  pasteboard: NSPasteboard;
  dragOrigin: CGPoint;
  dragOffset: CGPoint;
  iconBounds: CGRect;
begin  
  transparentDragImage := image.copy.autorelease;
  transparentDragImage.setSize(CGSizeMake(32, 32));
  transparentDragImage.lockFocus;
  transparentDragImage.drawAtPoint_fromRect_operation_fraction(NSZeroPoint, NSZeroRect, NSCompositeCopy, 0.5);
  transparentDragImage.unlockFocus;
    
  pasteboard := NSPasteboard.pasteboardWithName(NSDragPboard);
  pasteboard.clearContents;

  pasteboard.setString_forType(NSSTR('/'), NSString(kUTTypeFileURL));

  dragOrigin := convertPoint_fromView(theEvent.locationInWindow, nil);
  
  iconBounds := bounds;
  
  dragOffset.x := (dragOrigin.x - CGRectGetMinX(iconBounds));
  dragOffset.y := (dragOrigin.y - CGRectGetMinY(iconBounds));

  dragOrigin.x := dragOrigin.x - dragOffset.x;
  dragOrigin.y := dragOrigin.y - dragOffset.y;

  dragImage_at_offset_event_pasteboard_source_slideBack(transparentDragImage, dragOrigin, NSZeroSize, theEvent, pasteboard, self, true);  
end;

function TDropImageView.draggingEntered (sender: NSDraggingInfoProtocol): NSDragOperation;
begin
  result := NSDragOperationCopy;
end;

function TDropImageView.performDragOperation (sender: NSDraggingInfoProtocol): objcbool;
var
  pasteboardItem: NSPasteboardItem;
  urlString: NSString;
  url: NSURL;
  fileImage: NSImage;
begin
  for pasteboardItem in sender.draggingPasteboard.pasteboardItems do
    begin
      urlString := pasteboardItem.stringForType(NSString(kUTTypeFileURL));
      url := NSURL.URLWithString(urlString);
      fileImage := NSWorkspace.sharedWorkspace.iconForFile(url.path);
      setImage(fileImage);

      TAppDelegate(NSApp.delegate).dropLabel.setStringValue(url.path.lastPathComponent);
    end;
  result := true;
end;

procedure TAppDelegate.applicationDidFinishLaunching(notification : NSNotification);
begin
  dragImageview.setImage(NSWorkspace.sharedWorkspace.iconForFile(NSSTR('/')));

  dropImageView.registerForDraggedTypes(NSArray.arrayWithObjects( NSString(kUTTypeFileURL), 
                                                              nil));
end;

end.