unit ormbr.connection.sqldirect;

interface

uses
  DB,
  Classes,
  SDEngine,
  ormbr.component.base,
  ormbr.factory.sqldirect,
  ormbr.factory.interfaces;

type
  {$IF CompilerVersion > 23}
  [ComponentPlatformsAttribute(pidWin32 or
                               pidWin64 or
                               pidOSX32 or
                               pidiOSSimulator or
                               pidiOSDevice or
                               pidAndroid)]
  {$IFEND}
  TORMBrConnectionSQLDirect = class(TORMBrConnectionBase)
  private
    FConnection: TSDDatabase;
  public
    function GetDBConnection: IDBConnection; override;
  published
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Connetion: TSDDatabase read FConnection write FConnection;
  end;

implementation

{ TORMBrConnectionSQLDirect }

constructor TORMBrConnectionSQLDirect.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

destructor TORMBrConnectionSQLDirect.Destroy;
begin

  inherited;
end;

function TORMBrConnectionSQLDirect.GetDBConnection: IDBConnection;
begin
  if not Assigned(FDBConnection) then
    FDBConnection := TFactorySQLDirect.Create(FConnection, FDriverName);
  Result := FDBConnection;
end;

end.
