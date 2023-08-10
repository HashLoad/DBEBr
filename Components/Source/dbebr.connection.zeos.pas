unit dbebr.connection.zeos;

interface

uses
  DB,
  Classes,
  ZConnection,
  dbebr.connection.base,
  dbebr.factory.zeos,
  dbebr.factory.interfaces;

type
  {$IF CompilerVersion > 23}
  [ComponentPlatformsAttribute(pidWin32 or
                               pidWin64 or
                               pidWinArm64 or
                               pidOSX32 or
                               pidOSX64 or
                               pidOSXArm64 or
                               pidLinux32 or
                               pidLinux64 or
                               pidLinuxArm64)]
  {$IFEND}
  TDBEBrConnectionZeos = class(TDBEBrConnectionBase)
  private
    FConnection: TZConnection;
    procedure SetConnection(const Value: TZConnection);
    function GetConnection: TZConnection;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Connection: TZConnection read GetConnection write SetConnection;
  end;

implementation

{ TDBEBrConnectionZeos }

constructor TDBEBrConnectionZeos.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

destructor TDBEBrConnectionZeos.Destroy;
begin

  inherited;
end;

function TDBEBrConnectionZeos.GetConnection: TZConnection;
begin
  Result := FConnection;
end;

procedure TDBEBrConnectionZeos.SetConnection(const Value: TZConnection);
begin
  FConnection := Value;
  if not Assigned(FDBConnection) then
    FDBConnection := TFactoryZeos.Create(FConnection, FDriverName);
end;

end.
