unit dbebr.factory.odac;

interface

uses
  DB,
  Classes,
  dbebr.factory.connection,
  dbebr.factory.interfaces;

type

  TFactoryODAC = class(TFactoryConnection)
  public
    constructor Create(const AConnection: TComponent;
      const ADriverName: TDriverName); overload;
    constructor Create(const AConnection: TComponent;
      const ADriverName: TDriverName;
      const AMonitor: ICommandMonitor); overload;
    constructor Create(const AConnection: TComponent;
      const ADriverName: TDriverName;
      const AMonitorCallback: TMonitorProc); overload;
    destructor Destroy; override;
    procedure Connect; override;
    procedure Disconnect; override;
    procedure StartTransaction; override;
    procedure Commit; override;
    procedure Rollback; override;
    procedure ExecuteDirect(const ASQL: string); override;
    procedure ExecuteDirect(const ASQL: string; const AParams: TParams); override;
    procedure ExecuteScript(const AScript: string); override;
    procedure AddScript(const AScript: string); override;
    procedure ExecuteScripts; override;
    function InTransaction: Boolean; override;
    function IsConnected: Boolean; override;
    function GetDriverName: TDriverName; override;
    function CreateQuery: IDBQuery; override;
    function CreateResultSet(const ASQL: String): IDBResultSet; override;
  end;

implementation

uses
  dbebr.driver.odac,
  dbebr.driver.odac.transaction;


{ TFactoryODAC }

procedure TFactoryODAC.AddScript(const AScript: string);
begin
  inherited;
  FDriverConnection.AddScript(AScript);
end;

procedure TFactoryODAC.Commit;
begin
  FDriverTransaction.Commit;
  inherited;
end;

procedure TFactoryODAC.Connect;
begin
  if not IsConnected then
    FDriverConnection.Connect;
end;

constructor TFactoryODAC.Create(const AConnection: TComponent;
  const ADriverName: TDriverName);
begin
  FDriverConnection  := TDriverODAC.Create(AConnection, ADriverName);
  FDriverTransaction := TDriverODACTransaction.Create(AConnection);
  FAutoTransaction := False;
end;

constructor TFactoryODAC.Create(const AConnection: TComponent;
  const ADriverName: TDriverName; const AMonitorCallback: TMonitorProc);
begin
  Create(AConnection, ADrivername);
  FMonitorCallback := AMonitorCallback;
end;

constructor TFactoryODAC.Create(const AConnection: TComponent;
  const ADriverName: TDriverName; const AMonitor: ICommandMonitor);
begin
  Create(AConnection, ADriverName);
  FCommandMonitor := AMonitor;
end;

function TFactoryODAC.CreateQuery: IDBQuery;
begin
  Result := FDriverConnection.CreateQuery;
end;

function TFactoryODAC.CreateResultSet(const ASQL: String): IDBResultSet;
begin
  Result := FDriverConnection.CreateResultSet(ASQL);
end;

destructor TFactoryODAC.Destroy;
begin
  FDriverTransaction.Free;
  FDriverConnection.Free;
  inherited;
end;

procedure TFactoryODAC.Disconnect;
begin
  inherited;
  if IsConnected then
    FDriverConnection.Disconnect;
end;

procedure TFactoryODAC.ExecuteDirect(const ASQL: string;
  const AParams: TParams);
begin
  inherited;
end;

procedure TFactoryODAC.ExecuteDirect(const ASQL: string);
begin
  inherited;
end;

procedure TFactoryODAC.ExecuteScript(const AScript: string);
begin
  inherited;
end;

procedure TFactoryODAC.ExecuteScripts;
begin
  inherited;
end;

function TFactoryODAC.GetDriverName: TDriverName;
begin
  inherited;
  Result := FDriverConnection.DriverName;
end;

function TFactoryODAC.InTransaction: Boolean;
begin
  Result := FDriverTransaction.InTransaction;
end;

function TFactoryODAC.IsConnected: Boolean;
begin
  inherited;
  Result := FDriverConnection.IsConnected;
end;

procedure TFactoryODAC.Rollback;
begin
  FDriverTransaction.Rollback;
  inherited;
end;

procedure TFactoryODAC.StartTransaction;
begin
  inherited;
  FDriverTransaction.StartTransaction;

end;

end.
