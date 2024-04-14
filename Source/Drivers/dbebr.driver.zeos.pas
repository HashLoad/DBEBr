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

unit dbebr.driver.zeos;

{$ifdef fpc}
  {$mode delphi}{$H+}
{$endif}

interface

uses
  Classes,
  SysUtils,
  DB,
  Variants,
  ZAbstractConnection,
  ZConnection,
  ZAbstractRODataset,
  ZAbstractDataset,
  ZDataset,
  ZSqlProcessor,
  // DBEBr
  dbebr.driver.connection,
  dbebr.factory.interfaces;

type
  TDataSetHacker = class(TDataSet);

  // Classe de conexão concreta com dbExpress
  TDriverZeos = class(TDriverConnection)
  private
    {$IFDEF ZEOS80UP}
    function _GetTransactionActive: TZTransaction;
    {$ENDIF}
  protected
    FConnection: TZConnection;
    FSQLScript: TZSQLProcessor;
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

  TDriverQueryZeos = class(TDriverQuery)
  private
    FSQLQuery: TZQuery;
    {$IFDEF ZEOS80UP}
    function _GetTransactionActive: TZTransaction;
    {$ENDIF}
  protected
    procedure _SetCommandText(const ACommandText: String); override;
    function _GetCommandText: String; override;
  public
    constructor Create(const AConnection: TZConnection;
      const ADriverTransaction: TDriverTransaction;
      const AMonitor: ICommandMonitor;
      const AMonitorCallback: TMonitorProc);
    destructor Destroy; override;
    procedure ExecuteDirect; override;
    function ExecuteQuery: IDBResultSet; override;
    function RowsAffected: UInt32; override;
  end;

  TDriverResultSetZeos = class(TDriverResultSet<TZQuery>)
  protected
    procedure _SetUniDirectional(const Value: Boolean); override;
    procedure _SetReadOnly(const Value: Boolean); override;
    procedure _SetCachedUpdates(const Value: Boolean); override;
    procedure _SetCommandText(const ACommandText: String); override;
    function _GetCommandText: String; override;
  public
    constructor Create(const ADataSet: TZQuery; const AMonitor: ICommandMonitor;
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

{ TDriverZeos }

constructor TDriverZeos.Create(const AConnection: TComponent;
  const ADriverTransaction: TDriverTransaction;
  const ADriverName: TDriverName;
  const AMonitor: ICommandMonitor;
  const AMonitorCallback: TMonitorProc);
begin
  FConnection := AConnection as TZConnection;
  FDriverTransaction := ADriverTransaction;
  FDriverName := ADriverName;
  FCommandMonitor := AMonitor;
  FMonitorCallback := AMonitorCallback;
  FSQLScript := TZSQLProcessor.Create(nil);
  try
    FSQLScript.Connection := FConnection;
    FSQLScript.Script.Clear;
  except
    FSQLScript.Free;
    raise;
  end;
end;

destructor TDriverZeos.Destroy;
begin
  FDriverTransaction := nil;
  FConnection := nil;
  FSQLScript.Free;
  inherited;
end;

procedure TDriverZeos.Disconnect;
begin
  FConnection.Connected := False;
end;

procedure TDriverZeos.ExecuteDirect(const ASQL: String);
var
  LExeSQL: TZQuery;
begin
  LExeSQL := TZQuery.Create(nil);
  try
    LExeSQL.Connection := FConnection;
    {$IFDEF ZEOS80UP}
    LExeSQL.Transaction := _GetTransactionActive;
    {$ENDIF}
    LExeSQL.SQL.Text := ASQL;
    if not LExeSQL.Prepared then
      LExeSQL.Prepare;
    LExeSQL.ExecSQL;
  finally
    {$IFDEF ZEOS80UP}
    _SetMonitorLog(LExeSQL.SQL.Text, LExeSQL.Transaction.Name, LExeSQL.Params);
    {$ELSE}
    _SetMonitorLog(LExeSQL.SQL.Text, 'DEFAULT', LExeSQL.Params);
    {$ENDIF}
    FRowsAffected := LExeSQL.RowsAffected;
    LExeSQL.Free;
  end;
end;

procedure TDriverZeos.ExecuteDirect(const ASQL: String; const AParams: TParams);
var
  LExeSQL: TZQuery;
  LFor: Int16;
begin
  LExeSQL := TZQuery.Create(nil);
  try
    LExeSQL.Connection := FConnection;
    {$IFDEF ZEOS80UP}
    LExeSQL.Transaction := _GetTransactionActive;
    {$ENDIF}
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
    {$IFDEF ZEOS80UP}
    _SetMonitorLog(LExeSQL.SQL.Text, LExeSQL.Transaction.Name, LExeSQL.Params);
    {$ELSE}
    _SetMonitorLog(LExeSQL.SQL.Text, 'DEFAULT', LExeSQL.Params);
    {$ENDIF}
    FRowsAffected := LExeSQL.RowsAffected;
    LExeSQL.Free;
  end;
end;

procedure TDriverZeos.ExecuteScript(const AScript: String);
begin
  FSQLScript.Script.Text := AScript;
  ExecuteScripts;
end;

procedure TDriverZeos.ExecuteScripts;
begin
  if FSQLScript.Script.Count = 0 then
    Exit;
  try
    {$IFDEF ZEOS80UP}
    FSQLScript.Transaction := _GetTransactionActive;
    {$ENDIF}
    FSQLScript.Execute;
  finally
    {$IFDEF ZEOS80UP}
    _SetMonitorLog(FSQLScript.Script.Text, FSQLScript.Transaction.Name, nil);
    {$ELSE}
    _SetMonitorLog(FSQLScript.Script.Text, 'DEFAULT', nil);
    {$ENDIF}
    FRowsAffected := 0;
    FSQLScript.Script.Clear;
  end;
end;

function TDriverZeos.GetSQLScripts: String;
begin
  {$IFDEF ZEOS80UP}
  Result := 'Transaction: ' + FSQLScript.Transaction.Name + ' ' +  FSQLScript.Script.Text;
  {$ELSE}
  Result := 'Transaction: ' + 'DEFAULT' + ' ' +  FSQLScript.Script.Text;
  {$ENDIF}
end;

procedure TDriverZeos.AddScript(const AScript: String);
begin
  if Self.GetDriverName in [dnInterbase, dnFirebird, dnFirebird3] then
    if FSQLScript.Script.Count = 0 then
      FSQLScript.Script.Add('SET AUTOCOMMIT OFF');
  FSQLScript.Script.Add(AScript);
end;

procedure TDriverZeos.ApplyUpdates(const ADataSets: array of IDBResultSet);
var
  LDataSet: IDBResultSet;
begin
  for LDataset in AdataSets do
    LDataset.ApplyUpdates;
end;

procedure TDriverZeos.Connect;
begin
  FConnection.Connected := True;
end;

function TDriverZeos.IsConnected: Boolean;
begin
  Result := FConnection.Connected = True;
end;

{$IFDEF ZEOS80UP}
function TDriverZeos._GetTransactionActive: TZTransaction;
begin
  Result := FDriverTransaction.TransactionActive as TZTransaction;
end;
{$ENDIF}

function TDriverZeos.CreateQuery: IDBQuery;
begin
  Result := TDriverQueryZeos.Create(FConnection,
                                    FDriverTransaction,
                                    FCommandMonitor,
                                    FMonitorCallback);
end;

function TDriverZeos.CreateResultSet(const ASQL: String): IDBResultSet;
var
  LDBQuery: IDBQuery;
begin
  LDBQuery := TDriverQueryZeos.Create(FConnection,
                                      FDriverTransaction,
                                      FCommandMonitor,
                                      FMonitorCallback);
  LDBQuery.CommandText := ASQL;
  Result := LDBQuery.ExecuteQuery;
end;

{ TDriverZeosQuery }

constructor TDriverQueryZeos.Create(const AConnection: TZConnection;
  const ADriverTransaction: TDriverTransaction;
  const AMonitor: ICommandMonitor;
  const AMonitorCallback: TMonitorProc);
begin
  if AConnection = nil then
    Exit;
  {$IFDEF ZEOS80UP}
  FDriverTransaction := ADriverTransaction;
  {$ENDIF}
  FCommandMonitor := AMonitor;
  FMonitorCallback := AMonitorCallback;
  FSQLQuery := TZQuery.Create(nil);
  try
    FSQLQuery.Connection := AConnection;
  except
    FSQLQuery.Free;
    raise;
  end;
end;

destructor TDriverQueryZeos.Destroy;
begin
  FSQLQuery.Free;
  inherited;
end;

function TDriverQueryZeos.ExecuteQuery: IDBResultSet;
var
  LResultSet: TZQuery;
  LFor: Int16;
begin
  LResultSet := TZQuery.Create(nil);
  try
    LResultSet.Connection := FSQLQuery.Connection;
    {$IFDEF ZEOS80UP}
    LResultSet.Transaction := _GetTransactionActive;
    {$ENDIF}
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
      Result := TDriverResultSetZeos.Create(LResultSet, FCommandMonitor, FMonitorCallback);
      if LResultSet.Active then
      begin
        if LResultSet.RecordCount = 0 then
          Result.FetchingAll := True;
      end;
    finally
      if LResultSet.SQL.Text <> EmptyStr then
        {$IFDEF ZEOS80UP}
        _SetMonitorLog(LResultSet.SQL.Text, LResultSet.Transaction.Name, LResultSet.Params);
        {$ELSE}
        _SetMonitorLog(LResultSet.SQL.Text, 'DEFAULT', LResultSet.Params);
        {$ENDIF}
    end;
  except
    if Assigned(LResultSet) then
      LResultSet.Free;
    raise;
  end;
end;

function TDriverQueryZeos.RowsAffected: UInt32;
begin
  Result := FRowsAffected;
end;

function TDriverQueryZeos._GetCommandText: String;
begin
  Result := FSQLQuery.SQL.Text;
end;

{$IFDEF ZEOS80UP}
function TDriverQueryZeos._GetTransactionActive: TUniTransaction;
begin
  Result := FDriverTransaction.TransactionActive as TUniTransaction;
end;
{$ENDIF}

procedure TDriverQueryZeos._SetCommandText(const ACommandText: String);
begin
  FSQLQuery.SQL.Text := ACommandText;
end;

procedure TDriverQueryZeos.ExecuteDirect;
var
  LExeSQL: TZQuery;
  LFor: Int16;
begin
  LExeSQL := TZQuery.Create(nil);
  try
    LExeSQL.Connection := FSQLQuery.Connection;
    {$IFDEF ZEOS80UP}
    LExeSQL.Transaction := _GetTransactionActive;
    {$ENDIF}
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
    {$IFDEF ZEOS80UP}
    _SetMonitorLog(LExeSQL.SQL.Text, LExeSQL.Transaction.Name, LExeSQL.Params);
    {$ELSE}
    _SetMonitorLog(LExeSQL.SQL.Text, 'DEFAULT', LExeSQL.Params);
    {$ENDIF}
    FRowsAffected := LExeSQL.RowsAffected;
    LExeSQL.Free;
  end;
end;

{ TDriverResultSetZeos }

procedure TDriverResultSetZeos.ApplyUpdates;
begin
  FDataSet.ApplyUpdates;
end;

procedure TDriverResultSetZeos.CancelUpdates;
begin
  FDataSet.CancelUpdates;
end;

constructor TDriverResultSetZeos.Create(const ADataSet: TZQuery; const AMonitor: ICommandMonitor;
      const AMonitorCallback: TMonitorProc);
begin
  inherited Create(ADataSet, AMonitor, AMonitorCallback);
end;

destructor TDriverResultSetZeos.Destroy;
begin
  FDataSet.Free;
  inherited;
end;

function TDriverResultSetZeos.GetFieldValue(const AFieldName: String): Variant;
var
  LField: TField;
begin
  LField := FDataSet.FieldByName(AFieldName);
  Result := GetFieldValue(LField.Index);
end;

function TDriverResultSetZeos.GetField(const AFieldName: String): TField;
begin
  Result := FDataSet.FieldByName(AFieldName);
end;

function TDriverResultSetZeos.GetFieldType(const AFieldName: String): TFieldType;
begin
  Result := FDataSet.FieldByName(AFieldName).DataType;
end;

function TDriverResultSetZeos.GetFieldValue(const AFieldIndex: UInt16): Variant;
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

function TDriverResultSetZeos.IsCachedUpdates: Boolean;
begin
  Result := FDataSet.CachedUpdates;
end;

function TDriverResultSetZeos.IsReadOnly: Boolean;
begin
  Result := FDataSet.ReadOnly;
end;

function TDriverResultSetZeos.IsUniDirectional: Boolean;
begin
  Result := FDataSet.IsUniDirectional;
end;

function TDriverResultSetZeos.NotEof: Boolean;
begin
  if not FFirstNext then
    FFirstNext := True
  else
    FDataSet.Next;
  Result := not FDataSet.Eof;
end;

procedure TDriverResultSetZeos.Open;
begin
  try
    inherited Open;
  finally
    {$IFDEF ZEOS80UP}
    _SetMonitorLog(FDataSet.SQL.Text, FDataSet.Transaction.Name, FDataSet.Params);
    {$ELSE}
    _SetMonitorLog(FDataSet.SQL.Text, 'DEFAULT', FDataSet.Params);
    {$ENDIF}
  end;
end;

function TDriverResultSetZeos.RowsAffected: UInt32;
begin
  Result := FDataSet.RowsAffected;
end;

function TDriverResultSetZeos._GetCommandText: String;
begin
  Result := FDataSet.SQL.Text;
end;

procedure TDriverResultSetZeos._SetCachedUpdates(const Value: Boolean);
begin
  FDataSet.CachedUpdates := Value;
end;

procedure TDriverResultSetZeos._SetCommandText(const ACommandText: String);
begin
  FDataSet.SQL.Text := ACommandText;
end;

procedure TDriverResultSetZeos._SetReadOnly(const Value: Boolean);
begin
  FDataSet.ReadOnly := Value;
end;

procedure TDriverResultSetZeos._SetUniDirectional(const Value: Boolean);
begin
  TDataSetHacker(FDataSet).SetUniDirectional(Value);
end;

end.
