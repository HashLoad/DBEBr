unit dbebr.connection.sqldirect;

interface

uses
  DB,
  Classes,
  SDEngine,
  dbebr.connection.base,
  dbebr.factory.sqldirect,
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
  TDBEBrConnectionSQLDirect = class(TDBEBrConnectionBase)
  private
    FConnection: TSDDatabase;
    procedure SetConnection(const Value: TSDDatabase);
    function GetConnection: TSDDatabase;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Connection: TSDDatabase read GetConnection write SetConnection;
  end;

implementation

{ TDBEBrConnectionSQLDirect }

constructor TDBEBrConnectionSQLDirect.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

destructor TDBEBrConnectionSQLDirect.Destroy;
begin

  inherited;
end;

function TDBEBrConnectionSQLDirect.GetConnection: TSDDatabase;
begin
  Result := FConnection;
end;

procedure TDBEBrConnectionSQLDirect.SetConnection(const Value: TSDDatabase);
begin
  FConnection := Value;
  if not Assigned(FDBConnection) then
    FDBConnection := TFactorySQLDirect.Create(FConnection, FDriverName);
end;

end.
