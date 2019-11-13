{$mode objfpc}
{$modeswitch objectivec2}

unit CocoaUtils;
interface
uses
  SysUtils, CocoaAll;

type
 TCocoaObject = objcclass (NSObject, NSCopyingProtocol)
  public
    m_obj: TObject;
    function initWithObject(_obj: TObject): id; message 'initWithObject:';
    function obj: TObject; message 'obj';
  private
    function copyWithZone(zone_: NSZonePtr): id; message 'copyWithZone:';
    procedure encodeWithCoder(aCoder: NSCoder); message 'encodeWithCoder:';
    function initWithCoder(aDecoder: NSCoder): id; message 'initWithCoder:';
  end;

operator = (left: NSString; right: string): boolean;
operator explicit (right: NSObject): string;

implementation
uses
  CTypes;
  
function TCocoaObject.initWithCoder(aDecoder: NSCoder): id;
begin
  {$if defined(cpux86_64)}
  result := initWithObject(TObject(aDecoder.decodeInt64ForKey(NSSTR('m_obj'))));
  {$else}
  result := initWithObject(TObject(aDecoder.decodeInt32ForKey(NSSTR('m_obj'))));
  {$endif}
end;

procedure TCocoaObject.encodeWithCoder(aCoder: NSCoder);
begin
  {$if defined(cpux86_64)}
  aCoder.encodeInt64_forKey(cint64(m_obj), NSSTR('m_obj'));
  {$else}
  aCoder.encodeInt32_forKey(cint32(m_obj), NSSTR('m_obj'));
  {$endif}
end;

function TCocoaObject.copyWithZone (zone_: NSZonePtr): id;
begin
  result := TCocoaObject.allocWithZone(zone_).initWithObject(m_obj);
end;


function TCocoaObject.initWithObject(_obj: TObject): id;
begin
  result := init;
  if assigned(result) then
    m_obj := _obj;
end;

function TCocoaObject.obj: TObject;
begin
  result := m_obj;
end;

operator = (left: NSString; right: string): boolean;
begin
  result := (left.UTF8String = right);
end;

operator explicit (right: NSObject): string;
begin
  result := right.description.UTF8String;
end;

end.