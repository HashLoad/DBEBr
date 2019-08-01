unit ormbr.connection.nexusdb;

interface

uses
  DB,
  Classes,
  nxdb,
  nxllComponent,
  ormbr.component.base,
  ormbr.factory.nexusdb,
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
  TORMBrConnectionNexusDB = class(TORMBrConnectionBase)
  private
    FConnection: TnxDatabase;
  public
    function GetDBConnection: IDBConnection; override;
  published
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Connetion: TnxDatabase read FConnection write FConnection;
  end;

implementation

{ TORMBrConnectionNexusDB }

constructor TORMBrConnectionNexusDB.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

destructor TORMBrConnectionNexusDB.Destroy;
begin

  inherited;
end;

function TORMBrConnectionNexusDB.GetDBConnection: IDBConnection;
begin
  if not Assigned(FDBConnection) then
    FDBConnection := TFactoryNexusDB.Create(FConnection, FDriverName);
  Result := FDBConnection;
end;

end.
