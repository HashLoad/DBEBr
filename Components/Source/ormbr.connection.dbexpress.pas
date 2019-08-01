unit ormbr.connection.dbexpress;

interface

uses
  DB,
  SqlExpr,
  Classes,
  ormbr.component.base,
  ormbr.factory.dbexpress,
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
  TORMBrConnectionDBExpress = class(TORMBrConnectionBase)
  private
    FConnection: TSQLConnection;
  public
    function GetDBConnection: IDBConnection; Override;
  published
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Connetion: TSQLConnection read FConnection write FConnection;
  end;

implementation

{ TORMBrConnectionDBExpress }

constructor TORMBrConnectionDBExpress.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

destructor TORMBrConnectionDBExpress.Destroy;
begin

  inherited;
end;

function TORMBrConnectionDBExpress.GetDBConnection: IDBConnection;
begin
  if not Assigned(FDBConnection) then
    FDBConnection := TFactoryDBExpress.Create(FConnection, FDriverName);
  Result := FDBConnection;
end;

end.
