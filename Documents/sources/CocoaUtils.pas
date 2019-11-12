{$mode objfpc}
{$modeswitch objectivec1}

unit CocoaUtils;
interface
uses
  SysUtils, CocoaAll;

operator = (left: NSString; right: string): boolean;
operator explicit (right: NSObject): string;

implementation

operator = (left: NSString; right: string): boolean;
begin
  result := (left.UTF8String = right);
end;

operator explicit (right: NSObject): string;
begin
  if assigned(right) then
    result := right.description.UTF8String
  else
    result := 'nil';
end;

end.