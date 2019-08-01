unit ormbr.component.base;

interface

uses
  DB,
  Classes,
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
  TORMBrConnectionBase = class(TComponent)
  protected
    FDBConnection: IDBConnection;
    FDriverName: TDriverName;
    function GetDBConnection: IDBConnection; virtual; abstract;
  public
    procedure Connect;
    procedure Disconnect;
    procedure StartTransaction;
    procedure Commit;
    procedure Rollback;
    procedure ExecuteDirect(const ASQL: string); overload;
    procedure ExecuteDirect(const ASQL: string; const AParams: TParams); overload;
    procedure ExecuteScript(const ASQL: string);
    procedure AddScript(const ASQL: string);
    procedure ExecuteScripts;
    procedure SetCommandMonitor(AMonitor: ICommandMonitor);
    function InTransaction: Boolean;
    function IsConnected: Boolean;
    function CreateQuery: IDBQuery;
    function CreateResultSet(const ASQL: String): IDBResultSet;
    function ExecuteSQL(const ASQL: string): IDBResultSet;
    function CommandMonitor: ICommandMonitor;
  published
    constructor Create(AOwner: TComponent); virtual;
    destructor Destroy; override;
    property DriverName: TDriverName read FDriverName write FDriverName;
  end;

implementation

{ TORMBrConnectionBase }

constructor TORMBrConnectionBase.Create(AOwner: TComponent);
begin

end;

destructor TORMBrConnectionBase.Destroy;
begin

  inherited;
end;

procedure TORMBrConnectionBase.AddScript(const ASQL: string);
begin
  GetDBConnection.AddScript(ASQL);
end;

function TORMBrConnectionBase.CommandMonitor: ICommandMonitor;
begin
  Result := GetDBConnection.CommandMonitor;
end;

procedure TORMBrConnectionBase.Commit;
begin
  GetDBConnection.Commit;
end;

procedure TORMBrConnectionBase.Connect;
begin
  GetDBConnection.Connect;
end;

function TORMBrConnectionBase.CreateQuery: IDBQuery;
begin
  Result := GetDBConnection.CreateQuery;
end;

function TORMBrConnectionBase.CreateResultSet(
  const ASQL: String): IDBResultSet;
begin
  Result := GetDBConnection.CreateResultSet(ASQL);
end;

procedure TORMBrConnectionBase.Disconnect;
begin
  GetDBConnection.Disconnect;
end;

procedure TORMBrConnectionBase.ExecuteDirect(const ASQL: string);
begin
  GetDBConnection.ExecuteDirect(ASQL);
end;

procedure TORMBrConnectionBase.ExecuteDirect(const ASQL: string;
  const AParams: TParams);
begin
  GetDBConnection.ExecuteDirect(ASQL, AParams);
end;

procedure TORMBrConnectionBase.ExecuteScript(const ASQL: string);
begin
  GetDBConnection.ExecuteScript(ASQL);
end;

procedure TORMBrConnectionBase.ExecuteScripts;
begin
  GetDBConnection.ExecuteScripts;
end;

function TORMBrConnectionBase.ExecuteSQL(const ASQL: string): IDBResultSet;
begin
  Result := GetDBConnection.ExecuteSQL(ASQL);
end;

function TORMBrConnectionBase.InTransaction: Boolean;
begin
  Result := GetDBConnection.InTransaction;
end;

function TORMBrConnectionBase.IsConnected: Boolean;
begin
  Result := GetDBConnection.IsConnected;
end;

procedure TORMBrConnectionBase.Rollback;
begin
  GetDBConnection.Rollback;
end;

procedure TORMBrConnectionBase.SetCommandMonitor(AMonitor: ICommandMonitor);
begin
  GetDBConnection.SetCommandMonitor(AMonitor);
end;

procedure TORMBrConnectionBase.StartTransaction;
begin
  GetDBConnection.StartTransaction;
end;

end.
