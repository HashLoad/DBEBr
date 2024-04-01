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

{
  @abstract(DBEBr Framework)
  @created(25 julho 2017)
  @author(Marcos J O Nielsen <marcos@softniels.com.br>)
  @author(Skype : marcos@softniels.com.br)

  @author(Isaque Pinheiro <https://www.isaquepinheiro.com.br>)
}

unit dbebr.driver.unidac;

interface

uses
  Classes,
  SysUtils,
  StrUtils,
  Variants,
  Data.DB,
  // UniDAC
  Uni,
  DBAccess,
  UniProvider,
  UniScript,
  // DBEBr
  dbebr.driver.connection,
  dbebr.factory.interfaces;

type
  // Classe de conexão concreta com UniDAC
  TDriverUniDAC = class(TDriverConnection)
  private
    function _GetTransactionActive: TUniTransaction;
    procedure _SetMonitorLog(const ASQL: String; ATransactionName: String; AParams: TParams);
  protected
    FConnection: TUniConnection;
    FSQLScript : TUniScript;
    FCommandMonitor: ICommandMonitor;
    FMonitorCallback: TMonitorProc;
  public
    constructor Create(const AConnection: TComponent;
      const ADriverTransaction: TDriverTransaction;
      const ADriverName: TDriverName;
      const AMonitor: ICommandMonitor;
      const AMonitorCallback: TMonitorProc); override;
    destructor Destroy; override;
    procedure Connect; override;
    procedure Disconnect; override;
    procedure ExecuteDirect(const ASQL: string); override;
    procedure ExecuteDirect(const ASQL: string; const AParams: TParams); override;
    procedure ExecuteScript(const AScript: string); override;
    procedure AddScript(const AScript: string); override;
    procedure ExecuteScripts; override;
    procedure ApplyUpdates(const ADataSets: array of IDBResultSet); override;
    function IsConnected: Boolean; override;
    function CreateQuery: IDBQuery; override;
    function CreateResultSet(const ASQL: String = ''): IDBResultSet; override;
    function GetSQLScripts: String; override;
  end;

  TDriverQueryUniDAC = class(TDriverQuery)
  private
    FSQLQuery: TUniSQL;
    FCommandMonitor: ICommandMonitor;
    FMonitorCallback: TMonitorProc;
    function _GetTransactionActive: TUniTransaction;
    procedure _SetMonitorLog(const ASQL: String; ATransactionName: String; AParams: TParams);
  protected
    procedure _SetCommandText(const ACommandText: string); override;
    function _GetCommandText: string; override;
  public
    constructor Create(const AConnection: TUniConnection;
      const ADriverTransaction: TDriverTransaction;
      const AMonitor: ICommandMonitor;
      const AMonitorCallback: TMonitorProc);
    destructor Destroy; override;
    procedure ExecuteDirect; override;
    function ExecuteQuery: IDBResultSet; override;
    function RowsAffected: UInt32; override;
  end;

  TDriverResultSetUniDAC = class(TDriverResultSet<TUniQuery>)
  protected
    procedure _SetUniDirectional(const Value: Boolean); override;
    procedure _SetReadOnly(const Value: Boolean); override;
    procedure _SetCachedUpdates(const Value: Boolean); override;
    procedure _SetCommandText(const ACommandText: string); override;
    function _GetCommandText: string; override;
  public
    constructor Create(ADataSet: TUniQuery); override;
    destructor Destroy; override;
    procedure ApplyUpdates; override;
    procedure CancelUpdates; override;
    function NotEof: Boolean; override;
    function GetFieldValue(const AFieldName: string): Variant; overload; override;
    function GetFieldValue(const AFieldIndex: UInt16): Variant; overload; override;
    function GetFieldType(const AFieldName: string): TFieldType; overload; override;
    function GetField(const AFieldName: string): TField; override;
    function RowsAffected: UInt32; override;
    function IsUniDirectional: Boolean; override;
    function IsReadOnly: Boolean; override;
    function IsCachedUpdates: Boolean; override;
  end;

implementation

{ TDriverUniDAC }

constructor TDriverUniDAC.Create(const AConnection: TComponent;
  const ADriverTransaction: TDriverTransaction;
  const ADriverName: TDriverName;
  const AMonitor: ICommandMonitor;
  const AMonitorCallback: TMonitorProc);
begin
  FConnection := AConnection as TUniConnection;
  FDriverTransaction := ADriverTransaction;
  FDriverName := ADriverName;
  FCommandMonitor := AMonitor;
  FMonitorCallback := AMonitorCallback;
  FSQLScript  := TUniScript.Create(nil);
  try
    FSQLScript.Connection := FConnection;
    FSQLScript.SQL.Clear;
  except
    FSQLScript.Free;
    raise;
  end;
end;

destructor TDriverUniDAC.Destroy;
begin
  FDriverTransaction := nil;
  FConnection := nil;
  FSQLScript.Free;
  inherited;
end;

procedure TDriverUniDAC.Disconnect;
begin
  FConnection.Connected := False;
end;

procedure TDriverUniDAC.ExecuteDirect(const ASQL: string);
var
  LExeSQL: TUniSQL;
begin
  LExeSQL := TUniSQL.Create(nil);
  try
    LExeSQL.Connection := FConnection;
    LExeSQL.Transaction := _GetTransactionActive;
    LExeSQL.SQL.Text := ASQL;
    if not LExeSQL.Prepared then
      LExeSQL.Prepare;
    LExeSQL.Execute;
  finally
    _SetMonitorLog(LExeSQL.SQL.Text, LExeSQL.Transaction.Name, LExeSQL.Params);
    LExeSQL.Free;
  end;
end;

procedure TDriverUniDAC.ExecuteDirect(const ASQL: string; const AParams: TParams);
var
  LExeSQL: TUniSQL;
  LFor: Int16;
begin
  LExeSQL := TUniSQL.Create(nil);
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
  finally
    _SetMonitorLog(LExeSQL.SQL.Text, LExeSQL.Transaction.Name, LExeSQL.Params);
    LExeSQL.Free;
  end;
end;

procedure TDriverUniDAC.ExecuteScript(const AScript: string);
begin
  AddScript(AScript);
  ExecuteScripts;
end;

procedure TDriverUniDAC.ExecuteScripts;
begin
  if FSQLScript.SQL.Count = 0 then
    Exit;
  try
    FSQLScript.Transaction := _GetTransactionActive;
    FSQLScript.Execute;
  finally
    _SetMonitorLog(FSQLScript.SQL.Text, FSQLScript.Transaction.Name, nil);
    FSQLScript.SQL.Clear;
  end;
end;

function TDriverUniDAC.GetSQLScripts: String;
begin
  Result := 'Transaction: ' + FSQLScript.Transaction.Name + ' ' +  FSQLScript.SQL.Text;
end;

procedure TDriverUniDAC.AddScript(const AScript: string);
begin
  if MatchText(FConnection.ProviderName, ['Firebird', 'InterBase']) then // Firebird/Interbase
    FSQLScript.SQL.Add('SET AUTOCOMMIT OFF');
  FSQLScript.SQL.Add(AScript);
end;

procedure TDriverUniDAC.ApplyUpdates(const ADataSets: array of IDBResultSet);
var
  LDataSets: array of TCustomDADataSet;
  LFor: UInt16;
begin
  SetLength(LDataSets, Length(ADataSets));
  for LFor := Low(ADataSets) to High(ADataSets) do
    LDataSets[LFor] := TCustomDADataSet(ADataSets[LFor].DataSet);

  FConnection.ApplyUpdates(LDataSets);
end;

procedure TDriverUniDAC.Connect;
begin
  FConnection.Connected := True;
end;

function TDriverUniDAC.IsConnected: Boolean;
begin
  Result := FConnection.Connected = True;
end;

function TDriverUniDAC._GetTransactionActive: TUniTransaction;
begin
  Result := FDriverTransaction.TransactionActive as TUniTransaction;
end;

procedure TDriverUniDAC._SetMonitorLog(const ASQL: String; ATransactionName: String; AParams: TParams);
begin
  if Assigned(FCommandMonitor) then
    FCommandMonitor.Command('[Transaction: ' + ATransactionName + '] - ' + ASQL, AParams);
  if Assigned(FMonitorCallback) then
    FMonitorCallback(TMonitorParam.Create('[Transaction: ' + ATransactionName + '] - ' + ASQL, AParams));
end;

function TDriverUniDAC.CreateQuery: IDBQuery;
begin
  Result := TDriverQueryUniDAC.Create(FConnection,
                                      FDriverTransaction,
                                      FCommandMonitor,
                                      FMonitorCallback);
end;

function TDriverUniDAC.CreateResultSet(const ASQL: String): IDBResultSet;
var
  LDBQuery: IDBQuery;
begin
  LDBQuery := TDriverQueryUniDAC.Create(FConnection,
                                        FDriverTransaction,
                                        FCommandMonitor,
                                        FMonitorCallback);
  LDBQuery.CommandText := ASQL;
  Result := LDBQuery.ExecuteQuery;
end;

{ TDriverQueryUniDAC }

constructor TDriverQueryUniDAC.Create(const AConnection: TUniConnection;
  const ADriverTransaction: TDriverTransaction;
  const AMonitor: ICommandMonitor;
  const AMonitorCallback: TMonitorProc);
begin
  if AConnection = nil then
    Exit;
  FDriverTransaction := ADriverTransaction;
  FCommandMonitor := AMonitor;
  FMonitorCallback := AMonitorCallback;
  FSQLQuery := TUniSQL.Create(nil);
  try
    FSQLQuery.Connection := AConnection;
  except
    FSQLQuery.Free;
    raise;
  end;
end;

destructor TDriverQueryUniDAC.Destroy;
begin
  FSQLQuery.Free;
  inherited;
end;

function TDriverQueryUniDAC.ExecuteQuery: IDBResultSet;
var
  LResultSet: TUniQuery;
  LFor : Int16;
begin
  LResultSet := TUniQuery.Create(nil);
  try
    LResultSet.Connection := FSQLQuery.Connection;
    LResultSet.Transaction := _GetTransactionActive;
    LResultSet.SQL.Text := FSQLQuery.SQL.Text;
    try
      for LFor := 0 to FSQLQuery.Params.Count - 1 do
      begin
        LResultSet.Params[LFor].DataType := FSQLQuery.Params[LFor].DataType;
        LResultSet.Params[LFor].Value := FSQLQuery.Params[LFor].Value;
      end;
      if LResultSet.SQL.Text <> '' then
      begin
        if not LResultSet.Prepared then
          LResultSet.Prepare;
        LResultSet.Open;
      end;
      Result := TDriverResultSetUniDAC.Create(LResultSet);
      if LResultSet.Active then
      begin
        if LResultSet.RecordCount = 0 then
          Result.FetchingAll := True;
      end;
    finally
      _SetMonitorLog(LResultSet.SQL.Text, LResultSet.Transaction.Name, LResultSet.Params);
    end;
  except
    if Assigned(LResultSet) then
      LResultSet.Free;
    raise;
  end;
end;

function TDriverQueryUniDAC.RowsAffected: UInt32;
begin
  Result := FSQLQuery.RowsAffected;
end;

function TDriverQueryUniDAC._GetCommandText: string;
begin
  Result := FSQLQuery.SQL.Text;
end;

function TDriverQueryUniDAC._GetTransactionActive: TUniTransaction;
begin
  Result := FDriverTransaction.TransactionActive as TUniTransaction;
end;

procedure TDriverQueryUniDAC._SetCommandText(const ACommandText: string);
begin
  FSQLQuery.SQL.Text := ACommandText;
end;

procedure TDriverQueryUniDAC._SetMonitorLog(const ASQL: String; ATransactionName: String;
  AParams: TParams);
begin
  if Assigned(FCommandMonitor) then
    FCommandMonitor.Command('[Transaction: ' + ATransactionName + '] - ' + ASQL, AParams);
  if Assigned(FMonitorCallback) then
    FMonitorCallback(TMonitorParam.Create('[Transaction: ' + ATransactionName + '] - ' + ASQL, AParams));
end;

procedure TDriverQueryUniDAC.ExecuteDirect;
begin
  FSQLQuery.Transaction := _GetTransactionActive;;
  try
    FSQLQuery.Execute;
  finally
    _SetMonitorLog(FSQLQuery.SQL.Text, FSQLQuery.Transaction.Name, FSQLQuery.Params);
  end;
end;

{ TDriverResultSetUniDAC }

procedure TDriverResultSetUniDAC.ApplyUpdates;
begin
  FDataSet.ApplyUpdates;
end;

procedure TDriverResultSetUniDAC.CancelUpdates;
begin
  FDataSet.CancelUpdates;
end;

constructor TDriverResultSetUniDAC.Create(ADataSet: TUniQuery);
begin
  FDataSet := ADataSet;
  inherited;
end;

destructor TDriverResultSetUniDAC.Destroy;
begin
  FDataSet.Free;
  inherited;
end;

function TDriverResultSetUniDAC.GetFieldValue(const AFieldName: string): Variant;
var
  LField: TField;
begin
  LField := FDataSet.FieldByName(AFieldName);
  Result := GetFieldValue(LField.Index);
end;

function TDriverResultSetUniDAC.GetField(const AFieldName: string): TField;
begin
  Result := FDataSet.FieldByName(AFieldName);
end;

function TDriverResultSetUniDAC.GetFieldType(const AFieldName: string): TFieldType;
begin
  Result := FDataSet.FieldByName(AFieldName).DataType;
end;

function TDriverResultSetUniDAC.GetFieldValue(const AFieldIndex: UInt16): Variant;
begin
  if AFieldIndex > FDataSet.FieldCount - 1 then
    Exit(Variants.Null);

  if FDataSet.Fields[AFieldIndex].IsNull then
    Result := Variants.Null
  else
    Result := FDataSet.Fields[AFieldIndex].Value;
end;

function TDriverResultSetUniDAC.IsCachedUpdates: Boolean;
begin
  Result := FDataSet.CachedUpdates;
end;

function TDriverResultSetUniDAC.IsReadOnly: Boolean;
begin
  Result := FDataSet.ReadOnly;
end;

function TDriverResultSetUniDAC.IsUniDirectional: Boolean;
begin
  Result := FDataSet.UniDirectional;
end;

function TDriverResultSetUniDAC.NotEof: Boolean;
begin
  if not FFirstNext then
    FFirstNext := True
  else
    FDataSet.Next;
  Result := not FDataSet.Eof;
end;

function TDriverResultSetUniDAC.RowsAffected: UInt32;
begin
  Result := FDataSet.RowsAffected;
end;

function TDriverResultSetUniDAC._GetCommandText: string;
begin
  Result := FDataSet.SQL.Text;
end;

procedure TDriverResultSetUniDAC._SetCachedUpdates(const Value: Boolean);
begin
  FDataSet.CachedUpdates := Value;
end;

procedure TDriverResultSetUniDAC._SetCommandText(const ACommandText: string);
begin
  FDataSet.SQL.Text := ACommandText;
end;

procedure TDriverResultSetUniDAC._SetReadOnly(const Value: Boolean);
begin
  FDataSet.ReadOnly := Value;
end;

procedure TDriverResultSetUniDAC._SetUniDirectional(const Value: Boolean);
begin
  FDataSet.UniDirectional := Value;
end;

end.
