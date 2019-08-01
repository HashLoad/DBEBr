unit ormbr.connection.fibplus;

interface

uses
  DB,
  Classes,
  FIBQuery,
  FIBDataSet,
  FIBDatabase,
  ormbr.component.base,
  ormbr.factory.fibplus,
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
  TORMBrConnectionFIBPlus = class(TORMBrConnectionBase)
  private
    FConnection: TFIBDatabase;
  public
    function GetDBConnection: IDBConnection; override;
  published
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Connetion: TFIBDatabase read FConnection write FConnection;
  end;

implementation

{ TORMBrConnectionFIBPlus }

constructor TORMBrConnectionFIBPlus.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

destructor TORMBrConnectionFIBPlus.Destroy;
begin

  inherited;
end;

function TORMBrConnectionFIBPlus.GetDBConnection: IDBConnection;
begin
  if not Assigned(FDBConnection) then
    FDBConnection := TFactoryFIBPlus.Create(FConnection, FDriverName);
  Result := FDBConnection;
end;

end.
