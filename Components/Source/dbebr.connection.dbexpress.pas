unit dbebr.connection.dbexpress;

interface

uses
  DB,
  SqlExpr,
  Classes,
  dbebr.connection.base,
  dbebr.factory.dbexpress,
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
  TDBEBrConnectionDBExpress = class(TDBEBrConnectionBase)
  private
    FConnection: TSQLConnection;
    procedure SetConnection(const Value: TSQLConnection);
    function GetConnection: TSQLConnection;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Connection: TSQLConnection read GetConnection write SetConnection;
  end;

implementation

{ TDBEBrConnectionDBExpress }

constructor TDBEBrConnectionDBExpress.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

destructor TDBEBrConnectionDBExpress.Destroy;
begin

  inherited;
end;

function TDBEBrConnectionDBExpress.GetConnection: TSQLConnection;
begin
  Result := FConnection;
end;

procedure TDBEBrConnectionDBExpress.SetConnection(const Value: TSQLConnection);
begin
  FConnection := Value;
  if not Assigned(FDBConnection) then
    FDBConnection := TFactoryDBExpress.Create(FConnection, FDriverName);
end;

end.
