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

unit dbebr.driver.firedac;

interface

uses
  Classes,
  SysUtils,
  StrUtils,
  Variants,
  DB,
  FireDAC.Comp.Client,
  FireDAC.Comp.Script,
  FireDAC.Comp.ScriptCommands,
  FireDAC.DApt,
  FireDAC.Stan.Param,
  // DBEBr
  dbebr.driver.connection,
  dbebr.factory.interfaces;

type
  TFDQueryHelper = class Helper for TFDQuery
  public
    function AsParams: TParams;
  end;

  // Classe de conexão concreta com FireDAC
  TDriverFireDAC = class(TDriverConnection)
  private
    function _GetTransactionActive: TFDTransaction;
  protected
    FConnection: TFDConnection;
    FSQLScript: TFDScript;
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

  TDriverQueryFireDAC = class(TDriverQuery)
  private
    FFDQuery: TFDQuery;
    function _GetTransactionActive: TFDTransaction;
  protected
    procedure _SetCommandText(const ACommandText: String); override;
    function _GetCommandText: String; override;
  public
    constructor Create(const AConnection: TFDConnection;
      const ADriverTransaction: TDriverTransaction;
      const AMonitor: ICommandMonitor;
      const AMonitorCallback: TMonitorProc);
    destructor Destroy; override;
    procedure ExecuteDirect; override;
    function ExecuteQuery: IDBResultSet; override;
    function RowsAffected: UInt32; override;
  end;

  TDriverResultSetFireDAC = class(TDriverResultSet<TFDQuery>)
  protected
    procedure _SetUniDirectional(const Value: Boolean); override;
    procedure _SetReadOnly(const Value: Boolean); override;
    procedure _SetCachedUpdates(const Value: Boolean); override;
    procedure _SetCommandText(const ACommandText: String); override;
    function _GetCommandText: String; override;
  public
    constructor Create(const ADataSet: TFDQuery; const AMonitor: ICommandMonitor;
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

{ TDriverFireDAC }

constructor TDriverFireDAC.Create(const AConnection: TComponent;
  const ADriverTransaction: TDriverTransaction;
  const ADriverName: TDriverName;
  const AMonitor: ICommandMonitor;
  const AMonitorCallback: TMonitorProc);
begin
  FConnection := AConnection as TFDConnection;
  FDriverTransaction := ADriverTransaction;
  FDriverName := ADriverName;
  FCommandMonitor := AMonitor;
  FMonitorCallback := AMonitorCallback;
  FSQLScript := TFDScript.Create(nil);
  try
    FSQLScript.Connection := FConnection;
    FSQLScript.SQLScripts.Add;
    FSQLScript.ScriptOptions.Reset;
    FSQLScript.ScriptOptions.BreakOnError := True;
    FSQLScript.ScriptOptions.RaisePLSQLErrors := True;
    FSQLScript.ScriptOptions.EchoCommands := ecAll;
    FSQLScript.ScriptOptions.CommandSeparator := ';';
    FSQLScript.ScriptOptions.CommitEachNCommands := 9999999;
    FSQLScript.ScriptOptions.DropNonexistObj := True;
  except
    FSQLScript.Free;
    raise;
  end;
end;

destructor TDriverFireDAC.Destroy;
begin
  FConnection := nil;
  FDriverTransaction := nil;
  FSQLScript.Free;
  inherited;
end;

procedure TDriverFireDAC.Disconnect;
begin
  FConnection.Connected := False;
end;

procedure TDriverFireDAC.ExecuteDirect(const ASQL: String);
var
  LExeSQL: TFDQuery;
  LParams: TParams;
begin
  LExeSQL := TFDQuery.Create(nil);
  try
    LExeSQL.Connection := FConnection;
    LExeSQL.Transaction := _GetTransactionActive;
    LExeSQL.SQL.Text := ASQL;
    if not LExeSQL.Prepared then
      LExeSQL.Prepare;
    LExeSQL.Execute;
    LParams := LExeSQL.AsParams;
  finally
    _SetMonitorLog(LExeSQL.SQL.Text, LExeSQL.Transaction.Name, LParams);
    FRowsAffected := LExeSQL.RowsAffected;
    LExeSQL.Free;
    if Assigned(LParams) then
    begin
      LParams.Clear;
      LParams.Free;
    end;
  end;
end;

procedure TDriverFireDAC.ExecuteDirect(const ASQL: String; const AParams: TParams);
var
  LExeSQL: TFDQuery;
  LParams: TParams;
  LFor: Int16;
begin
  LExeSQL := TFDQuery.Create(nil);
  try
    LExeSQL.Connection := FConnection;
    LExeSQL.Transaction := _GetTransactionActive;
    LExeSQL.SQL.Text := ASQL;
    for LFor := 0 to AParams.Count - 1 do
    begin
      LExeSQL.ParamByName(AParams[LFor].Name).DataType := AParams[LFor].DataType;
      LExeSQL.ParamByName(AParams[LFor].Name).Value := AParams[LFor].Value;
    end;
    if not LExeSQL.Prepared then
      LExeSQL.Prepare;
    LExeSQL.Execute;
    LParams := LExeSQL.AsParams;
  finally
    _SetMonitorLog(LExeSQL.SQL.Text, LExeSQL.Transaction.Name, LParams);
    FRowsAffected := LExeSQL.RowsAffected;
    LExeSQL.Free;
    if Assigned(LParams) then
    begin
      LParams.Clear;
      LParams.Free;
    end;
  end;
end;

procedure TDriverFireDAC.ExecuteScript(const AScript: String);
begin
  AddScript(AScript);
  ExecuteScripts;
end;

procedure TDriverFireDAC.ExecuteScripts;
begin
  if FSQLScript.SQLScripts.Count = 0 then
    Exit;
  try
    FSQLScript.Transaction := _GetTransactionActive;
    if FSQLScript.ValidateAll then
      FSQLScript.ExecuteAll;
  finally
    _SetMonitorLog(FSQLScript.SQLScripts.Items[0].SQL.Text, FSQLScript.Transaction.Name, nil);
    FRowsAffected := 0;
    FSQLScript.SQLScripts[0].SQL.Clear;
  end;
end;

function TDriverFireDAC.GetSQLScripts: String;
begin
  Result := 'Transaction: ' + FSQLScript.Transaction.Name + ' ' +  FSQLScript.SQLScripts.Items[0].SQL.Text;
end;

procedure TDriverFireDAC.AddScript(const AScript: String);
begin
  if Self.GetDriverName in [TDriverName.dnInterbase, TDriverName.dnFirebird, TDriverName.dnFirebird3] then
    if FSQLScript.SQLScripts.Items[0].SQL.Count = 0 then
      FSQLScript.SQLScripts.Items[0].SQL.Add('SET AUTOCOMMIT OFF');
  FSQLScript.SQLScripts[0].SQL.Add(AScript);
end;

procedure TDriverFireDAC.ApplyUpdates(const ADataSets: array of IDBResultSet);
var
  LDataSet: IDBResultSet;
begin
  for LDataset in AdataSets do
    LDataset.ApplyUpdates;
end;

procedure TDriverFireDAC.Connect;
begin
  FConnection.Connected := True;
end;

function TDriverFireDAC.IsConnected: Boolean;
begin
  Result := FConnection.Connected = True;
end;

function TDriverFireDAC._GetTransactionActive: TFDTransaction;
begin
  Result := FDriverTransaction.TransactionActive as TFDTransaction;
end;

function TDriverFireDAC.CreateQuery: IDBQuery;
begin
  Result := TDriverQueryFireDAC.Create(FConnection,
                                       FDriverTransaction,
                                       FCommandMonitor,
                                       FMonitorCallback);
end;

function TDriverFireDAC.CreateResultSet(const ASQL: String): IDBResultSet;
var
  LDBQuery: IDBQuery;
begin
  LDBQuery := TDriverQueryFireDAC.Create(FConnection,
                                         FDriverTransaction,
                                         FCommandMonitor,
                                         FMonitorCallback);
  LDBQuery.CommandText := ASQL;
  Result := LDBQuery.ExecuteQuery;
end;

{ TDriverQueryFireDAC }

constructor TDriverQueryFireDAC.Create(const AConnection: TFDConnection;
  const ADriverTransaction: TDriverTransaction;
  const AMonitor: ICommandMonitor;
  const AMonitorCallback: TMonitorProc);
begin
  if AConnection = nil then
    Exit;
  FDriverTransaction := ADriverTransaction;
  FCommandMonitor := AMonitor;
  FMonitorCallback := AMonitorCallback;
  FFDQuery := TFDQuery.Create(nil);
  try
    FFDQuery.Connection := AConnection;
  except
    FFDQuery.Free;
    raise;
  end;
end;

destructor TDriverQueryFireDAC.Destroy;
begin
  FFDQuery.Free;
  inherited;
end;

function TDriverQueryFireDAC.ExecuteQuery: IDBResultSet;
var
  LResultSet: TFDQuery;
  LParams: TParams;
  LFor : Int16;
begin
  LResultSet := TFDQuery.Create(nil);
  try
    LResultSet.Connection := FFDQuery.Connection;
    LResultSet.Transaction := _GetTransactionActive;
    LResultSet.SQL.Text := FFDQuery.SQL.Text;
    try
      for LFor := 0 to FFDQuery.Params.Count - 1 do
      begin
        LResultSet.Params[LFor].DataType := FFDQuery.Params[LFor].DataType;
        LResultSet.Params[LFor].Value := FFDQuery.Params[LFor].Value;
      end;
      if LResultSet.SQL.Text <> EmptyStr then
      begin
        if not LResultSet.Prepared then
          LResultSet.Prepare;
        LResultSet.Open;
      end;
      Result := TDriverResultSetFireDAC.Create(LResultSet, FCommandMonitor, FMonitorCallback);
      if LResultSet.Active then
      begin
        if LResultSet.RecordCount = 0 then
          Result.FetchingAll := True;
      end;
      LParams := LResultSet.AsParams;
    finally
      if LResultSet.SQL.Text <> EmptyStr then
        _SetMonitorLog(LResultSet.SQL.Text, LResultSet.Transaction.Name, LParams);
      if Assigned(LParams) then
      begin
        LParams.Clear;
        LParams.Free;
      end;
    end;
  except
    if Assigned(LResultSet) then
      LResultSet.Free;
    raise;
  end;
end;

function TDriverQueryFireDAC.RowsAffected: UInt32;
begin
  Result := FRowsAffected;
end;

function TDriverQueryFireDAC._GetCommandText: String;
begin
  Result := FFDQuery.SQL.Text;
end;

function TDriverQueryFireDAC._GetTransactionActive: TFDTransaction;
begin
  Result := FDriverTransaction.TransactionActive as TFDTransaction;
end;

procedure TDriverQueryFireDAC._SetCommandText(const ACommandText: String);
begin
  FFDQuery.SQL.Text := ACommandText;
end;

procedure TDriverQueryFireDAC.ExecuteDirect;
var
  LExeSQL: TFDQuery;
  LParams: TParams;
  LFor: Int16;
begin
  LExeSQL := TFDQuery.Create(nil);
  try
    LExeSQL.Connection := FFDQuery.Connection;
    LExeSQL.Transaction := _GetTransactionActive;
    LExeSQL.SQL.Text := FFDQuery.SQL.Text;
    for LFor := 0 to FFDQuery.Params.Count - 1 do
    begin
      LExeSQL.Params[LFor].DataType := FFDQuery.Params[LFor].DataType;
      LExeSQL.Params[LFor].Value := FFDQuery.Params[LFor].Value;
    end;
    if not LExeSQL.Prepared then
      LExeSQL.Prepare;
    LExeSQL.Execute;
    LParams := LExeSQL.AsParams;
  finally
    _SetMonitorLog(LExeSQL.SQL.Text, LExeSQL.Transaction.Name, LParams);
    FRowsAffected := LExeSQL.RowsAffected;
    LExeSQL.Free;
    if Assigned(LParams) then
    begin
      LParams.Clear;
      LParams.Free;
    end;
  end;
end;

{ TDriverResultSetFireDAC }

procedure TDriverResultSetFireDAC.ApplyUpdates;
begin
  FDataSet.ApplyUpdates;
end;

procedure TDriverResultSetFireDAC.CancelUpdates;
begin
  FDataSet.CancelUpdates;
end;

constructor TDriverResultSetFireDAC.Create(const ADataSet: TFDQuery; const AMonitor: ICommandMonitor;
      const AMonitorCallback: TMonitorProc);
begin
  inherited Create(ADataSet, AMonitor, AMonitorCallback);
end;

destructor TDriverResultSetFireDAC.Destroy;
begin
  FDataSet.Free;
  inherited;
end;

function TDriverResultSetFireDAC.GetFieldValue(const AFieldName: String): Variant;
var
  LField: TField;
begin
  LField := FDataSet.FieldByName(AFieldName);
  Result := GetFieldValue(LField.Index);
end;

function TDriverResultSetFireDAC.GetField(const AFieldName: String): TField;
begin
  Result := FDataSet.FieldByName(AFieldName);
end;

function TDriverResultSetFireDAC.GetFieldType(const AFieldName: String): TFieldType;
begin
  Result := FDataSet.FieldByName(AFieldName).DataType;
end;

function TDriverResultSetFireDAC.GetFieldValue(const AFieldIndex: Uint16): Variant;
begin
  if AFieldIndex > FDataSet.FieldCount - 1 then
    Exit(Variants.Null);

  if FDataSet.Fields[AFieldIndex].IsNull then
    Result := Variants.Null
  else
    Result := FDataSet.Fields[AFieldIndex].Value;
end;

function TDriverResultSetFireDAC.IsCachedUpdates: Boolean;
begin
  Result := FDataSet.CachedUpdates;
end;

function TDriverResultSetFireDAC.IsReadOnly: Boolean;
begin
  Result := False; // FDataSet.ReadOnly;
end;

function TDriverResultSetFireDAC.IsUniDirectional: Boolean;
begin
  Result := FDataSet.IsUniDirectional;
end;

function TDriverResultSetFireDAC.NotEof: Boolean;
begin
  if not FFirstNext then
    FFirstNext := True
  else
    FDataSet.Next;
  Result := not FDataSet.Eof;
end;

procedure TDriverResultSetFireDAC.Open;
var
  LParams: TParams;
begin
  try
    inherited Open;
    LParams := FDataSet.AsParams;
  finally
    _SetMonitorLog(FDataSet.SQL.Text, FDataSet.Transaction.Name, LParams);
    if Assigned(LParams) then
    begin
      LParams.Clear;
      LParams.Free;
    end;
  end;
end;

function TDriverResultSetFireDAC.RowsAffected: UInt32;
begin
  Result := FDataSet.RowsAffected;
end;

function TDriverResultSetFireDAC._GetCommandText: String;
begin
  Result := FDataSet.SQL.Text;
end;

procedure TDriverResultSetFireDAC._SetCachedUpdates(const Value: Boolean);
begin
  FDataSet.CachedUpdates := Value;
end;

procedure TDriverResultSetFireDAC._SetCommandText(const ACommandText: String);
begin
  FDataSet.SQL.Text := ACommandText;
end;

procedure TDriverResultSetFireDAC._SetReadOnly(const Value: Boolean);
begin
  // FDataSet.ReadOnly := Value;
end;

procedure TDriverResultSetFireDAC._SetUniDirectional(const Value: Boolean);
begin
  FDataSet.FetchOptions.Unidirectional := Value;
end;

{ TFDQueryHelper }

function TFDQueryHelper.AsParams: TParams;
var
  LFor: Int16;
begin
  Result := TParams.Create;
  for LFor := 0 to Self.Params.Count - 1 do
  begin
    Result.Add;
    Result[LFor].DataType := Self.Params[LFor].DataType;
    Result[LFor].Value := Self.Params[LFor].Value;
  end;
end;

end.
