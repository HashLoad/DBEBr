{
  DBE Brasil é um Engine de Conexão simples e descomplicado for Delphi/Lazarus

                   Copyright (c) 2016, Isaque Pinheiro
                          All rights reserved.

                    GNU Lesser General Public License
                      Versão 3, 29 de junho de 2007

       Copyright (C) 2007 Free Software Foundation, Inc. <http://fsf.org/>
       A todos é permitido copiar e distribuir cópias deste documento de
       licença, mas mudá-lo não é permitido.

       Esta versão da GNU Lesser General Public License incorpora
       os termos e condições da versão 3 da GNU General Public License
       Licença, complementado pelas permissões adicionais listadas no
       arquivo LICENSE na pasta principal.
}

{ @abstract(DBEBr Framework)
  @created(20 Jul 2016)
  @author(Isaque Pinheiro <https://www.isaquepinheiro.com.br>)
}

unit dbebr.driver.sqldb;

{$ifdef fpc}
  {$mode delphi}{$H+}
{$endif}

interface

uses
  Classes,
  SysUtils,
  DB,
  Variants,
  SQLDB,
  // DBEBr
  dbebr.driver.connection,
  dbebr.factory.interfaces;

type
  // Classe de conexão concreta com SQLdb
  TDriverSQLdb = class(TDriverConnection)
  private
    function _GetTransactionActive: TSQLTransaction;
  protected
    FConnection: TSQLConnection;
    FSQLScript: TSQLScript;
  public
    constructor Create(const AConnection: TComponent;
      const ADriverTransaction: TDriverTransaction;
      const ADriverName: TDriverName;
      const AMonitor: ICommandMonitor;
      const AMonitorCallback: TMonitorProc); override;
    destructor Destroy; override;
    procedure Connect; override;
    procedure Disconnect; override;
    procedure ExecuteDirect(const ASQL: String); override;
    procedure ExecuteDirect(const ASQL: String; const AParams: TParams); override;
    procedure ExecuteScript(const AScript: String); override;
    procedure AddScript(const AScript: String); override;
    procedure ExecuteScripts; override;
    procedure ApplyUpdates(const ADataSets: array of IDBResultSet); override;
    function IsConnected: Boolean; override;
    function CreateQuery: IDBQuery; override;
    function CreateResultSet(const ASQL: String = ''): IDBResultSet; override;
    function GetSQLScripts: String; override;
  end;

  TDriverQuerySQLdb = class(TDriverQuery)
  private
    FSQLQuery: TSQLQuery;
    function _GetTransactionActive: TSQLTransaction;
  protected
    procedure _SetCommandText(const ACommandText: String); override;
    function _GetCommandText: String; override;
  public
    constructor Create(const AConnection: TSQLConnection;
      const ADriverTransaction: TDriverTransaction;
      const AMonitor: ICommandMonitor;
      const AMonitorCallback: TMonitorProc);
    destructor Destroy; override;
    procedure ExecuteDirect; override;
    function ExecuteQuery: IDBResultSet; override;
    function RowsAffected: UInt32; override;
  end;

  TDriverResultSetSQLdb = class(TDriverResultSet<TSQLQuery>)
  protected
    procedure _SetUniDirectional(const Value: Boolean); override;
    procedure _SetReadOnly(const Value: Boolean); override;
    procedure _SetCachedUpdates(const Value: Boolean); override;
    procedure _SetCommandText(const ACommandText: String); override;
    function _GetCommandText: String; override;
  public
    constructor Create(const ADataSet: TSQLQuery; const AMonitor: ICommandMonitor;
      const AMonitorCallback: TMonitorProc); reintroduce;
    destructor Destroy; override;
    procedure Open; override;
    procedure ApplyUpdates; override;
    procedure CancelUpdates; override;
    function NotEof: Boolean; override;
    function GetFieldValue(const AFieldName: String): Variant; overload; override;
    function GetFieldValue(const AFieldIndex: UInt16): Variant; overload; override;
    function GetFieldType(const AFieldName: String): TFieldType; overload; override;
    function GetField(const AFieldName: String): TField; override;
    function RowsAffected: UInt32; override;
    function IsUniDirectional: Boolean; override;
    function IsReadOnly: Boolean; override;
    function IsCachedUpdates: Boolean; override;
  end;

implementation

{ TDriverSQLdb }

constructor TDriverSQLdb.Create(const AConnection: TComponent;
  const ADriverTransaction: TDriverTransaction;
  const ADriverName: TDriverName;
  const AMonitor: ICommandMonitor;
  const AMonitorCallback: TMonitorProc);
begin
  FConnection := AConnection;
  FDriverTransaction := ADriverTransaction;
  FDriverName := ADriverName;
  FCommandMonitor := AMonitor;
  FMonitorCallback := AMonitorCallback;
  FSQLScript := TSQLScript.Create(nil);
  try
    FSQLScript.Database := FConnection;
    FSQLScript.Script.Clear;
  except
    FSQLScript.Free;
    raise;
  end;
end;

destructor TDriverSQLdb.Destroy;
begin
  FDriverTransaction := nil;
  FConnection := nil;
  FSQLScript.Free;
  inherited;
end;

procedure TDriverSQLdb.Disconnect;
begin
  FConnection.Connected := False;
end;

procedure TDriverSQLdb.ExecuteDirect(const ASQL: String);
var
  LExeSQL: TSQLQuery;
begin
  LExeSQL := TSQLQuery.Create(nil);
  try
    LExeSQL.Database := FConnection;
    LExeSQL.Transaction := _GetTransactionActive;
    LExeSQL.SQL.Text := ASQL;
    if not LExeSQL.Prepared then
      LExeSQL.Prepare;
    LExeSQL.ExecSQL;
  finally
    _SetMonitorLog(LExeSQL.SQL.Text, LExeSQL.Transaction.Name, LExeSQL.Params);
    FRowsAffected := LExeSQL.RowsAffected;
    LExeSQL.Free;
  end;
end;

procedure TDriverSQLdb.ExecuteDirect(const ASQL: String; const AParams: TParams);
var
  LExeSQL: TSQLQuery;
  LFor: Int16;
begin
  LExeSQL := TSQLQuery.Create(nil);
  try
    LExeSQL.Database := FConnection;
    LExeSQL.Transaction := _GetTransactionActive;
    LExeSQL.SQL.Text := ASQL;
    for LFor := 0 to AParams.Count - 1 do
    begin
      LExeSQL.ParamByName(AParams[LFor].Name).DataType := AParams[LFor].DataType;
      LExeSQL.ParamByName(AParams[LFor].Name).Value := AParams[LFor].Value;
    end;
    if not LExeSQL.Prepared then
      LExeSQL.Prepare;
    LExeSQL.ExecSQL;
  finally
    _SetMonitorLog(LExeSQL.SQL.Text, LExeSQL.Transaction.Name, LExeSQL.Params);
    FRowsAffected := LExeSQL.RowsAffected;
    LExeSQL.Free;
  end;
end;

procedure TDriverSQLdb.ExecuteScript(const AScript: String);
begin
  FSQLScript.Script.Text := AScript;
  ExecuteScripts;
end;

procedure TDriverSQLdb.ExecuteScripts;
begin
  if FSQLScript.Script.Count = 0 then
    Exit;
  try
    FSQLScript.Transaction := _GetTransactionActive;
    FSQLScript.Execute;
  finally
    _SetMonitorLog(FSQLScript.Script.Text, FSQLScript.Transaction.Name, nil);
    FRowsAffected := 0;
    FSQLScript.Script.Clear;
  end;
end;

function TDriverSQLdb.GetSQLScripts: String;
begin
  Result := 'Transaction: ' + FSQLScript.Transaction.Name + ' ' +  FSQLScript.Script.Text;
end;

procedure TDriverSQLdb.AddScript(const AScript: String);
begin
  if Self.GetDriverName in [dnInterbase, dnFirebird, dnFirebird3] then
    if FSQLScript.Script.Count = 0 then
      FSQLScript.Script.Add('SET AUTOCOMMIT OFF');
  FSQLScript.Script.Add(AScript);
end;

procedure TDriverSQLdb.ApplyUpdates(const ADataSets: array of IDBResultSet);
var
  LDataSet: IDBResultSet;
begin
  for LDataset in AdataSets do
    LDataset.ApplyUpdates;
end;

procedure TDriverSQLdb.Connect;
begin
  FConnection.Connected := True;
end;

function TDriverSQLdb.IsConnected: Boolean;
begin
  Result := FConnection.Connected = True;
end;

function TDriverSQLdb._GetTransactionActive: TSQLTransaction;
begin
  Result := FDriverTransaction.TransactionActive as TSQLTransaction;
end;

function TDriverSQLdb.CreateQuery: IDBQuery;
begin
  Result := TDriverQuerySQLdb.Create(FConnection,
                                    FDriverTransaction,
                                    FCommandMonitor,
                                    FMonitorCallback);
end;

function TDriverSQLdb.CreateResultSet(const ASQL: String): IDBResultSet;
var
  LDBQuery: IDBQuery;
begin
  LDBQuery := TDriverQuerySQLdb.Create(FConnection,
                                      FDriverTransaction,
                                      FCommandMonitor,
                                      FMonitorCallback);
  LDBQuery.CommandText := ASQL;
  Result := LDBQuery.ExecuteQuery;
end;

{ TDriverQuerySQLdb }

constructor TDriverQuerySQLdb.Create(const AConnection: TSQLConnection;
  const ADriverTransaction: TDriverTransaction;
  const AMonitor: ICommandMonitor;
  const AMonitorCallback: TMonitorProc);
begin
  if AConnection = nil then
    Exit;
  FDriverTransaction := ADriverTransaction;
  FCommandMonitor := AMonitor;
  FMonitorCallback := AMonitorCallback;
  FSQLQuery := TSQLQuery.Create(nil);
  try
    FSQLQuery.Database := AConnection;
  except
    FSQLQuery.Free;
    raise;
  end;
end;

destructor TDriverQuerySQLdb.Destroy;
begin
  FSQLQuery.Free;
  inherited;
end;

function TDriverQuerySQLdb.ExecuteQuery: IDBResultSet;
var
  LResultSet: TSQLQuery;
  LFor: Int16;
begin
  LResultSet := TSQLQuery.Create(nil);
  try
    LResultSet.Database := FSQLQuery.Database;
    LResultSet.Transaction := _GetTransactionActive;
    LResultSet.SQL.Text := FSQLQuery.SQL.Text;
    try
      for LFor := 0 to FSQLQuery.Params.Count - 1 do
      begin
        LResultSet.Params[LFor].DataType := FSQLQuery.Params[LFor].DataType;
        LResultSet.Params[LFor].Value := FSQLQuery.Params[LFor].Value;
      end;
      if LResultSet.SQL.Text <> EmptyStr then
      begin
        if not LResultSet.Prepared then
          LResultSet.Prepare;
        LResultSet.Open;
      end;
      Result := TDriverResultSetSQLdb.Create(LResultSet, FCommandMonitor, FMonitorCallback);
      if LResultSet.Active then
      begin
        if LResultSet.RecordCount = 0 then
          Result.FetchingAll := True;
      end;
    finally
      if LResultSet.SQL.Text <> EmptyStr then
        _SetMonitorLog(LResultSet.SQL.Text, LResultSet.Transaction.Name, LResultSet.Params);
    end;
  except
    if Assigned(LResultSet) then
      LResultSet.Free;
    raise;
  end;
end;

function TDriverQuerySQLdb.RowsAffected: UInt32;
begin
  Result := FRowsAffected;
end;

function TDriverQuerySQLdb._GetCommandText: String;
begin
  Result := FSQLQuery.SQL.Text;
end;

function TDriverQuerySQLdb._GetTransactionActive: TUniTransaction;
begin
  Result := FDriverTransaction.TransactionActive as TUniTransaction;
end;

procedure TDriverQuerySQLdb._SetCommandText(const ACommandText: String);
begin
  FSQLQuery.SQL.Text := ACommandText;
end;

procedure TDriverQuerySQLdb.ExecuteDirect;
var
  LExeSQL: TSQLQuery;
  LFor: Int16;
begin
  LExeSQL := TSQLQuery.Create(nil);
  try
    LExeSQL.Database := FSQLQuery.Database;
    LExeSQL.Transaction := _GetTransactionActive;
    LExeSQL.SQL.Text := FSQLQuery.SQL.Text;
    for LFor := 0 to FSQLQuery.Params.Count - 1 do
    begin
      LExeSQL.Params[LFor].DataType := FSQLQuery.Params[LFor].DataType;
      LExeSQL.Params[LFor].Value := FSQLQuery.Params[LFor].Value;
    end;
    if not LExeSQL.Prepared then
      LExeSQL.Prepare;
    LExeSQL.ExecSQL;
  finally
    _SetMonitorLog(LExeSQL.SQL.Text, LExeSQL.Transaction.Name, LExeSQL.Params);
    FRowsAffected := LExeSQL.RowsAffected;
    LExeSQL.Free;
  end;
end;

{ TDriverResultSetSQLdb }

procedure TDriverResultSetSQLdb.ApplyUpdates;
begin
  FDataSet.ApplyUpdates;
end;

procedure TDriverResultSetSQLdb.CancelUpdates;
begin
  FDataSet.CancelUpdates;
end;

constructor TDriverResultSetSQLdb.Create(const ADataSet: TSQLQuery; const AMonitor: ICommandMonitor;
      const AMonitorCallback: TMonitorProc);
begin
  inherited Create(ADataSet, AMonitor, AMonitorCallback);
end;

destructor TDriverResultSetSQLdb.Destroy;
begin
  FDataSet.Free;
  inherited;
end;

function TDriverResultSetSQLdb.GetFieldValue(const AFieldName: String): Variant;
var
  LField: TField;
begin
  LField := FDataSet.FieldByName(AFieldName);
  Result := GetFieldValue(LField.Index);
end;

function TDriverResultSetSQLdb.GetField(const AFieldName: String): TField;
begin
  Result := FDataSet.FieldByName(AFieldName);
end;

function TDriverResultSetSQLdb.GetFieldType(const AFieldName: String): TFieldType;
begin
  Result := FDataSet.FieldByName(AFieldName).DataType;
end;

function TDriverResultSetSQLdb.GetFieldValue(const AFieldIndex: UInt16): Variant;
begin
  if AFieldIndex > FDataSet.FieldCount - 1  then
    Exit(Variants.Null);

  if FDataSet.Fields[AFieldIndex].IsNull then
     Result := Variants.Null
  else
  begin
    case FDataSet.Fields[AFieldIndex].DataType of
      ftString,
      ftWideString: Result := FDataSet.Fields[AFieldIndex].AsString;
    else
      Result := FDataSet.Fields[AFieldIndex].Value;
    end;
  end;
end;

function TDriverResultSetSQLdb.IsCachedUpdates: Boolean;
begin
  Result := FDataSet.CachedUpdates;
end;

function TDriverResultSetSQLdb.IsReadOnly: Boolean;
begin
  Result := FDataSet.ReadOnly;
end;

function TDriverResultSetSQLdb.IsUniDirectional: Boolean;
begin
  Result := FDataSet.IsUniDirectional;
end;

function TDriverResultSetSQLdb.NotEof: Boolean;
begin
  if not FFirstNext then
    FFirstNext := True
  else
    FDataSet.Next;
  Result := not FDataSet.Eof;
end;

procedure TDriverResultSetSQLdb.Open;
begin
  try
    inherited Open;
  finally
    _SetMonitorLog(FDataSet.SQL.Text, FDataSet.Transaction.Name, FDataSet.Params);
  end;
end;

function TDriverResultSetSQLdb.RowsAffected: UInt32;
begin
  Result := FDataSet.RowsAffected;
end;

function TDriverResultSetSQLdb._GetCommandText: String;
begin
  Result := FDataSet.SQL.Text;
end;

procedure TDriverResultSetSQLdb._SetCachedUpdates(const Value: Boolean);
begin
  FDataSet.CachedUpdates := Value;
end;

procedure TDriverResultSetSQLdb._SetCommandText(const ACommandText: String);
begin
  FDataSet.SQL.Text := ACommandText;
end;

procedure TDriverResultSetSQLdb._SetReadOnly(const Value: Boolean);
begin
  FDataSet.ReadOnly := Value;
end;

procedure TDriverResultSetSQLdb._SetUniDirectional(const Value: Boolean);
begin
  FDataSet.UniDirectional := Value;
end;

end.
