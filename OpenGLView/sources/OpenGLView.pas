{$mode objfpc}
{$modeswitch objectivec2}

{$linkframework OpenGL}

unit OpenGLView;
interface
uses
  GL, GLExt, MacOSAll, CocoaAll;

type
  TOpenGLView = objcclass (NSView)
    public
      renderDelegate: id;

      function initWithFrame(frameRect: NSRect): id; override;
      function isOpaque: objcbool; override;
    private
      openGLContext: NSOpenGLContext;
      trackingArea: NSTrackingArea;
      displayLink: CVDisplayLinkRef;

      function defaultPixelFormat: NSOpenGLPixelFormat; message 'defaultPixelFormat';

      procedure setupContext; message 'setupContext';
      procedure redraw; message 'redraw';
      procedure viewDidMoveToWindow; override;
      procedure updateTrackingAreas; override;
      procedure keyDown(theEvent: NSEvent); override;

      procedure frameChanged (sender: NSNotification); message 'frameChanged:';
      procedure drawRect(dirtyRect: NSRect); override;
      procedure reshape; message 'reshape';
      procedure dealloc; override;
  end;

type
  TOpenGLViewDelegate = objcprotocol
    required
      procedure redraw(view: TOpenGLView); message 'redraw:';
  end;

implementation
uses
  CocoaUtils;

// note: setValues_forParameter in RTL headers is parsed wrong
type
  NSOpenGLContext_Fixed = objccategory external (NSOpenGLContext)
    procedure setValues_forParameter_fixed (vals: pointer; param: NSOpenGLContextParameter); overload; message 'setValues:forParameter:';
  end;

function DisplayLinkOutputCallback (displayLink: CVDisplayLinkRef; inNow: CVTimeStampPtr; inOutputTime: CVTimeStampPtr; flagsIn: CVOptionFlags; var flagsOut: CVOptionFlags; context: pointer): CVReturn; cdecl;
begin 
  TOpenGLView(context).performSelectorOnMainThread_withObject_waitUntilDone(objcselector('redraw'), nil, true);
  result := 0;
end;

procedure TOpenGLView.updateTrackingAreas;
begin 
  if trackingArea <> nil then
    removeTrackingArea(trackingArea);
  trackingArea := NSTrackingArea.alloc.initWithRect_options_owner_userInfo(bounds, NSTrackingMouseEnteredAndExited + NSTrackingActiveAlways, self, nil).autorelease;
  addTrackingArea(trackingArea);
end;

procedure TOpenGLView.keyDown(theEvent: NSEvent);
begin
end;

procedure TOpenGLView.setupContext;
var
  swapInterval: longint = 1;
  opacity: integer = 0;
  pixelFormat: NSOpenGLPixelFormat;
  vsync: boolean = true;
begin
  pixelFormat := defaultPixelFormat;
  openGLContext := NSOpenGLContext.alloc.initWithFormat_shareContext(pixelFormat, nil);
  if openGLContext = nil then
    writeln('invalid NSOpenGLContext');
  openGLContext.makeCurrentContext;
  openGLContext.setView(self);

  if not isOpaque then
    openGLContext.setValues_forParameter_fixed(@opacity, NSOpenGLCPSurfaceOpacity);

  setWantsBestResolutionOpenGLSurface(true);

  if vsync then
    begin
      CVDisplayLinkCreateWithActiveCGDisplays(displayLink);
      CVDisplayLinkSetOutputCallback(displayLink, CVDisplayLinkOutputCallback(@DisplayLinkOutputCallback), self);
      CVDisplayLinkSetCurrentCGDisplayFromOpenGLContext(displayLink, openGLContext.CGLContextObj, pixelFormat.CGLPixelFormatObj);
      CVDisplayLinkStart(displayLink);
    end;

end;

procedure TOpenGLView.viewDidMoveToWindow;
begin
  inherited viewDidMoveToWindow;
  if openGLContext = nil then
    setupContext;
  if window = nil then
    openGLContext.clearDrawable;
end;

procedure TOpenGLView.frameChanged (sender: NSNotification);
begin
  if openGLContext <> nil then
    reshape;
end;

procedure TOpenGLView.redraw;
begin 
  if renderDelegate <> nil then
    TOpenGLViewDelegate(renderDelegate).redraw(self);
  openGLContext.flushBuffer;
end;

procedure TOpenGLView.drawRect(dirtyRect: NSRect);
begin 
  redraw;
end;

procedure TOpenGLView.reshape;
begin
  openGLContext.update;
  setNeedsDisplay_(true);
end;

function TOpenGLView.isOpaque: objcbool;
begin
  // return false to make the view transparent
  result := window.backgroundColor.alphaComponent = 1.0;
end;

function TOpenGLView.defaultPixelFormat: NSOpenGLPixelFormat;
  function Inc (var i: integer): integer;
  begin
    i += 1;
    result := i;
  end;
const
  NSOpenGLPFAOpenGLProfile = 99 { available in 10_7 };
const
  NSOpenGLProfileVersionLegacy = $1000 { available in 10_7 };
  NSOpenGLProfileVersion3_2Core = $3200 { available in 10_7 };
  NSOpenGLProfileVersion4_1Core = $4100 { available in 10_10 };
var
  attributes: array[0..32] of NSOpenGLPixelFormatAttribute;
  i: integer = -1;

  doubleBuffer: boolean;
  colorSize: integer;
  depthSize: integer;
  stencilSize: integer;
  coreProfile: boolean;
begin
  doubleBuffer := true;
  colorSize := 32;
  depthSize := 24;
  stencilSize := 8;
  coreProfile := false;

  if coreProfile then
    begin
      if not Load_GL_VERSION_4_0 then
      if not Load_GL_VERSION_3_2 then
        Halt(-1);
    end
  else
    begin
      if not Load_GL_VERSION_2_1 then
        Halt(-1);
    end;

  if doubleBuffer then
    attributes[Inc(i)] := NSOpenGLPFADoubleBuffer;

  attributes[Inc(i)] := NSOpenGLPFAColorSize;
  attributes[Inc(i)] := colorSize;

  attributes[Inc(i)] := NSOpenGLPFADepthSize;
  attributes[Inc(i)] := depthSize;

  attributes[Inc(i)] := NSOpenGLPFAStencilSize;
  attributes[Inc(i)] := stencilSize;

  // we can only specify "legacy" or "core" on mac and the system will decide what version we actually get
  attributes[Inc(i)] := NSOpenGLPFAOpenGLProfile;
  if not coreProfile then
    attributes[Inc(i)] := NSOpenGLProfileVersionLegacy
  else
    begin
      //attributes[Inc(i)] := NSOpenGLProfileVersion3_2Core
      attributes[Inc(i)] := NSOpenGLProfileVersion4_1Core
    end;

  // terminate with 0
  attributes[Inc(i)] := 0;

  result := NSOpenGLPixelFormat.alloc.initWithAttributes(@attributes).autorelease;
  if result = nil then
    writeln('invalid NSOpenGLPixelFormat');
end;

procedure TOpenGLView.dealloc;
begin
  if displayLink <> nil then
    CVDisplayLinkRelease(displayLink);

  inherited dealloc;
end;

function TOpenGLView.initWithFrame(frameRect: NSRect): id;
begin
  result := inherited initWithFrame(frameRect);
  if result <> nil then
    NSNotificationCenter(NSNotificationCenter.defaultCenter).addObserver_selector_name_object(result, objcselector('frameChanged:'), NSViewGlobalFrameDidChangeNotification, nil);
end;

end.