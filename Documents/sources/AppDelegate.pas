{$mode objfpc}
{$modeswitch objectivec1}

unit AppDelegate;
interface
uses
	CocoaAll;

type
  TCustomDocument = objcclass (NSDocument)
    public
      function initWithType_error (typeName: NSString; outError: NSErrorPtr): id; override;
      function writeToURL_ofType_error (url: NSURL; typeName: NSString; outError: NSErrorPtr): objcbool; override;
      function readFromURL_ofType_error (url: NSURL; typeName: NSString; outError: NSErrorPtr): objcbool; override;
      function displayName: NSString; override;
      function windowNibName: NSString; override;
  end;

type
	TAppDelegate = objcclass(NSObject, NSApplicationDelegateProtocol)
  	public
  		procedure applicationDidFinishLaunching(notification: NSNotification); message 'applicationDidFinishLaunching:';
 	end;

implementation

function TCustomDocument.initWithType_error (typeName: NSString; outError: NSErrorPtr): id;
begin
  result := inherited initWithType_error(typeName, outError);
  if result <> nil then
    begin
      self := result;
      { Add your subclass-specific initialization here. }
    end;
end;

function TCustomDocument.writeToURL_ofType_error (url: NSURL; typeName: NSString; outError: NSErrorPtr): objcbool;
begin
  { Insert code here to write your document to data of the specified type. }
  result := true;
end;

function TCustomDocument.readFromURL_ofType_error (url: NSURL; typeName: NSString; outError: NSErrorPtr): objcbool;
begin
  { Insert code here to read your document from the given data of the specified type. }
end;

function TCustomDocument.displayName: NSString;
begin
  result := NSSTR('Custom Document');
end;

{ Using this name, NSDocument creates and instantiates a default instance of 
  NSWindowController to manage the window. If your document has multiple nib files, 
  each with its own single window, or if the default NSWindowController instance is not 
  adequate for your purposes, you should override makeWindowControllers. }
function TCustomDocument.windowNibName: NSString;
begin
  result := NSSTR('Document');
end;

{ The base class implementation creates an NSWindowController object with windowNibName and with the 
  document as the file’s owner if windowNibName returns a name. If you override this method to create 
  your own window controllers, be sure to use addWindowController: to add them to the document after creating them.

  This method is called by the NSDocumentController open... methods, but you might want to call it directly in 
  some circumstances. 

procedure TCustomDocument.makeWindowControllers;
var
  controller: TCustomWindowController;
begin
  controller := TCustomWindowController.alloc.initWithData(data);
  addWindowController(controller);
  controller.release;
end;

}

procedure TAppDelegate.applicationDidFinishLaunching(notification : NSNotification);
begin
end;

end.