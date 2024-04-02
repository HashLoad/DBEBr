{
  DBE Brasil � um Engine de Conex�o simples e descomplicado for Delphi/Lazarus

                   Copyright (c) 2016, Isaque Pinheiro
                          All rights reserved.

                    GNU Lesser General Public License
                      Vers�o 3, 29 de junho de 2007

       Copyright (C) 2007 Free Software Foundation, Inc. <http://fsf.org/>
       A todos � permitido copiar e distribuir c�pias deste documento de
       licen�a, mas mud�-lo n�o � permitido.

       Esta vers�o da GNU Lesser General Public License incorpora
       os termos e condi��es da vers�o 3 da GNU General Public License
       Licen�a, complementado pelas permiss�es adicionais listadas no
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
  // Classe de conex�o concreta com UniDAC
  TDriverUniDAC = class(TDriverConnection)
  private
    function _GetTransactionActive: TUniTransaction;
  protected
    FConnection: TUniConnection;
    FSQLScript : TUniScript;
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
    function _GetTransactionActive: TUniTransaction;
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
    constructor Create(ADataSet: TUniQuery; const AMonitor: ICommandMonitor;
      const AMonitorCallback: TMonitorProc); reintroduce;
    destructor Destroy; override;
    procedure Open; override;
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
//    if not LExeSQL.Prepared then
//      LExeSQL.Prepare;
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
//    if not LExeSQL.Prepared then
//      LExeSQL.Prepare;
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
  LDataSet: IDBResultSet;
begin
  for LDataset in AdataSets do
    LDataset.ApplyUpdates;
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
      if LResultSet.SQL.Text <> EmptyStr then
      begin
//        if not LResultSet.Prepared then
//          LResultSet.Prepare;
        LResultSet.Open;
      end;
      Result := TDriverResultSetUniDAC.Create(LResultSet, FCommandMonitor, FMonitorCallback);
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

procedure TDriverQueryUniDAC.ExecuteDirect;
var
  LExeSQL: TUniSQL;
  LFor: Int16;
begin
  LExeSQL := TUniSQL.Create(nil);
  try
    LExeSQL.Connection := FSQLQuery.Connection;
    LExeSQL.Transaction := _GetTransactionActive;
    LExeSQL.SQL.Text := FSQLQuery.SQL.Text;
    for LFor := 0 to FSQLQuery.Params.Count - 1 do
    begin
      LExeSQL.Params[LFor].DataType := FSQLQuery.Params[LFor].DataType;
      LExeSQL.Params[LFor].Value := FSQLQuery.Params[LFor].Value;
    end;
//    if not LExeSQL.Prepared then
//      LExeSQL.Prepare;
    LExeSQL.Execute;
  finally
    _SetMonitorLog(LExeSQL.SQL.Text, LExeSQL.Transaction.Name, LExeSQL.Params);
    LExeSQL.Free;
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

constructor TDriverResultSetUniDAC.Create(ADataSet: TUniQuery; const AMonitor: ICommandMonitor;
      const AMonitorCallback: TMonitorProc);
begin
  inherited Create(ADataSet, AMonitor, AMonitorCallback);
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

procedure TDriverResultSetUniDAC.Open;
begin
  try
    inherited Open;
  finally
    _SetMonitorLog(FDataSet.SQL.Text, FDataSet.Transaction.Name, FDataSet.Params);
  end;
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
