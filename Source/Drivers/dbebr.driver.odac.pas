unit dbebr.driver.odac;

interface

uses
  DB,
  System.Classes,
  System.Variants,
  System.SysUtils,
  dbebr.factory.connection,
  System.Generics.Collections,
  dbebr.driver.connection,
  dbebr.factory.interfaces,
  Ora;

type

  TDriverODAC = class(TDriverConnection)
  protected
    FConnection: TOraSession;
    FSQLScript: TOraQuery;
  public
    procedure Connect; override;
    procedure Disconnect; override;
    procedure ExecuteDirect(const ASQL: string); overload; override;
    procedure ExecuteDirect(const ASQL: string; const AParams: TParams); overload; override;
    procedure ExecuteScript(const AScript: string); override;
    procedure AddScript(const AScript: string); override;
    procedure ExecuteScripts; override;
    function IsConnected: Boolean; override;
    function InTransaction: Boolean; override;
    function CreateQuery: IDBQuery; override;
    function CreateResultSet(const ASQL: String): IDBResultSet; override;

    constructor Create(const AConnection: TComponent; const ADriverName: TDriverName); override;
    destructor Destroy; override;
  end;

  TDriverQueryODAC = class(TDriverQuery)
  private
    FSQLQuery: TOraQuery;
  protected
    procedure SetCommandText(ACommandText: string); override;
    function GetCommandText: string; override;
  public
    constructor Create(AConnection: TOraSession);
    destructor Destroy; override;
    procedure ExecuteDirect; override;
    function ExecuteQuery: IDBResultSet; override;
  end;

  TDriverResultSetODAC = class(TDriverResultSet<TOraQuery>)
  public
    constructor Create(ADataSet: TOraQuery); override;
    destructor Destroy; override;
    function NotEof: Boolean; override;
    function GetFieldValue(const AFieldName: string): Variant; overload; override;
    function GetFieldValue(const AFieldIndex: Integer): Variant; overload; override;
    function GetFieldType(const AFieldName: string): TFieldType; overload; override;
    function GetField(const AFieldName: string): TField; override;
  end;


implementation

{ TFactoryODAC }

procedure TDriverODAC.AddScript(const AScript: string);
begin
  inherited;
  FSQLScript.SQL.Add(AScript);
end;

procedure TDriverODAC.Connect;
begin
  inherited;
  FConnection.Connected := True;
end;

constructor TDriverODAC.Create(const AConnection: TComponent;
  const ADriverName: TDriverName);
begin
  inherited;
  FConnection := AConnection as TOraSession;
  FDriverName := ADriverName;
  FSQLScript := TOraQuery.Create(nil);
  try
    FSQLScript.Session := FConnection;
  except
    FSQLScript.Free;
    raise;
  end;
end;

function TDriverODAC.CreateQuery: IDBQuery;
begin
  Result := TDriverQueryODAC.Create(FConnection);
end;

function TDriverODAC.CreateResultSet(const ASQL: String): IDBResultSet;
var
  LDBQuery: IDBQuery;
begin
  LDBQuery := TDriverQueryODAC.Create(FConnection);
  LDBQuery.CommandText := ASQL;
  Result := LDBQuery.ExecuteQuery;
end;

destructor TDriverODAC.Destroy;
begin
  FConnection := nil;
  FSQLScript.Free;
  inherited;
end;

procedure TDriverODAC.Disconnect;
begin
  inherited;
  FConnection.Connected := False;
end;

procedure TDriverODAC.ExecuteDirect(const ASQL: string;
  const AParams: TParams);
var
  LExeSQL: TOraQuery;
  LFor: Integer;
begin
  LExeSQL := TOraQuery.Create(nil);

  try
    LExeSQL.Session := FConnection;
    LExeSQL.SQL.Text := ASQL;

    for LFor := 0 to AParams.Count - 1 do
    begin
      LExeSQL.ParamByName(AParams[LFor].Name).DataType := AParams[LFor].DataType;
      LExeSQL.ParamByName(AParams[LFor].Name).Value    := AParams[LFor].Value;
    end;

    try
      LExeSQL.ExecSQL;
    except
      raise;
    end;

  finally
    LExeSQL.Free;
  end;
end;

procedure TDriverODAC.ExecuteDirect(const ASQL: string);
begin
  FConnection.ExecSQL(ASQL);
end;

procedure TDriverODAC.ExecuteScript(const AScript: string);
begin
  inherited;
  FSQLScript.SQL.Text := AScript;
  FSQLScript.ExecSQL;
end;

procedure TDriverODAC.ExecuteScripts;
begin
  inherited;
  try
    FSQLScript.ExecSQL;
  finally
    FSQLScript.SQL.Clear;
  end;
end;

function TDriverODAC.InTransaction: Boolean;
begin
  Result := FConnection.InTransaction;
end;

function TDriverODAC.IsConnected: Boolean;
begin
  Result := FConnection.Connected;
end;

{ TDriverQueryODAC }

constructor TDriverQueryODAC.Create(AConnection: TOraSession);
begin
  if AConnection = nil then
    Exit;

  FSQLQuery := TOraQuery.Create(nil);
  try
    FSQLQuery.Session := AConnection;
  except
    FSQLQuery.Free;
    raise;
  end;
end;

destructor TDriverQueryODAC.Destroy;
begin
  FSQLQuery.Free;
  inherited;
end;

procedure TDriverQueryODAC.ExecuteDirect;
begin
  FSQLQuery.ExecSQL;
end;

function TDriverQueryODAC.ExecuteQuery: IDBResultSet;
var
  LResultSet: TOraQuery;
  LFor: Integer;
begin
  LResultSet := TOraQuery.Create(nil);
  try
    LResultSet.Session := FSQLQuery.Session;
    LResultSet.SQL.Text := FSQLQuery.SQL.Text;

    for LFor := 0 to FSQLQuery.Params.Count - 1 do
    begin
      LResultSet.Params[LFor].DataType := FSQLQuery.Params[LFor].DataType;
      LResultSet.Params[LFor].Value    := FSQLQuery.Params[LFor].Value;
    end;
    LResultSet.Open;
  except
    LResultSet.Free;
    raise;
  end;
  Result := TDriverResultSetODAC.Create(LResultSet);

  if LResultSet.Eof then
     Result.FetchingAll := True;
end;

function TDriverQueryODAC.GetCommandText: string;
begin
  Result := FSQLQuery.SQL.Text;
end;

procedure TDriverQueryODAC.SetCommandText(ACommandText: string);
begin
  inherited;
  FSQLQuery.SQL.Add(ACommandText);
end;

{ TDriverResultSetODAC }

constructor TDriverResultSetODAC.Create(ADataSet: TOraQuery);
begin
  FDataSet := ADataSet;
  inherited;
end;

destructor TDriverResultSetODAC.Destroy;
begin
  FDataSet.Free;
  inherited;
end;

function TDriverResultSetODAC.GetField(const AFieldName: string): TField;
begin
  Result := FDataSet.FieldByName(AFieldName);
end;

function TDriverResultSetODAC.GetFieldType(
  const AFieldName: string): TFieldType;
begin
  Result := FDataSet.FieldByName(AFieldName).DataType;
end;

function TDriverResultSetODAC.GetFieldValue(
  const AFieldIndex: Integer): Variant;
begin
  if AFieldIndex > FDataSet.FieldCount -1  then
    Exit(Null);

  if FDataSet.Fields[AFieldIndex].IsNull then
    Result := Null
  else
    Result := FDataSet.Fields[AFieldIndex].Value;
end;

function TDriverResultSetODAC.GetFieldValue(const AFieldName: string): Variant;
begin
  Result := GetFieldValue(FDataSet.FieldByName(AFieldName).Index);
end;

function TDriverResultSetODAC.NotEof: Boolean;
begin
  if not FFirstNext then
     FFirstNext := True
  else
     FDataSet.Next;

  Result := not FDataSet.Eof;
end;

end.
