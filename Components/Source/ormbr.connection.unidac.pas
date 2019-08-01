unit ormbr.connection.unidac;

interface

uses
  DB,
  Classes,
  Uni,
  ormbr.component.base,
  ormbr.factory.unidac,
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
  TORMBrConnectionUniDAC = class(TORMBrConnectionBase)
  private
    FConnection: TUniConnection;
  public
    function GetDBConnection: IDBConnection; override;
  published
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Connetion: TUniConnection read FConnection write FConnection;
  end;

implementation

{ TORMBrConnectionUniDAC }

constructor TORMBrConnectionUniDAC.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

destructor TORMBrConnectionUniDAC.Destroy;
begin

  inherited;
end;

function TORMBrConnectionUniDAC.GetDBConnection: IDBConnection;
begin
  if not Assigned(FDBConnection) then
    FDBConnection := TFactoryUniDAC.Create(FConnection, FDriverName);
  Result := FDBConnection;
end;

end.
