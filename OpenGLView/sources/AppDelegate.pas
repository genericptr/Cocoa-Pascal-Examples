{$mode objfpc}
{$modeswitch objectivec1}

unit AppDelegate;
interface
uses
	GL, OpenGLView, MacOSAll, CocoaAll;

type
	TAppDelegate = objcclass(NSObject, NSApplicationDelegateProtocol)
    private
      window: NSWindow;
  	public
  		procedure applicationDidFinishLaunching(notification: NSNotification); message 'applicationDidFinishLaunching:';
      procedure redraw(view: TOpenGLView); message 'redraw:';
 	end;

implementation

procedure DrawTriangle(width, height: integer); 
var
  ratio: single;
  rotate: double;
begin
  ratio := width / height;
  glViewport(0, 0, width, height);
  glClear(GL_COLOR_BUFFER_BIT);

  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  glOrtho(-ratio, ratio, -1, 1, 1, -1);
  glMatrixMode(GL_MODELVIEW);

  glLoadIdentity;
  rotate := (NSDate.date.timeIntervalSince1970 * 50);
  rotate := rotate - int(rotate / 360) * 360;
  glRotatef(rotate, 0, 0, 1);

  glBegin(GL_TRIANGLES);
    glColor3f(1, 0, 0);
    glVertex3f(-0.6, -0.4, 0);
    glColor3f(0, 1, 0);
    glVertex3f(0.6, -0.4, 0);
    glColor3f(0, 0, 1);
    glVertex3f(0, 0.6, 0);
  glEnd;
end;

procedure TAppDelegate.redraw(view: TOpenGLView);
begin
  DrawTriangle(trunc(view.bounds.size.width), trunc(view.bounds.size.height));
end;

procedure TAppDelegate.applicationDidFinishLaunching(notification : NSNotification);
begin
  TOpenGLView(window.contentView).renderDelegate := self.retain;
end;

end.