unit ormbr.connection.firedac;

interface

uses
  DB,
  Classes,
  FireDAC.Comp.Client,
  ormbr.component.base,
  ormbr.factory.firedac,
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
  TORMBrConnectionFireDAC = class(TORMBrConnectionBase)
  private
    FConnection: TFDConnection;
  public
    function GetDBConnection: IDBConnection; override;
  published
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Connetion: TFDConnection read FConnection write FConnection;
  end;

implementation

{ TORMBrConnectionFireDAC }

constructor TORMBrConnectionFireDAC.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

destructor TORMBrConnectionFireDAC.Destroy;
begin

  inherited;
end;

function TORMBrConnectionFireDAC.GetDBConnection: IDBConnection;
begin
  if not Assigned(FDBConnection) then
    FDBConnection := TFactoryFireDAC.Create(FConnection, FDriverName);
  Result := FDBConnection;
end;

end.
