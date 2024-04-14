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

{ @abstract(DBEBr Framework)
  @created(20 Jul 2016)
  @author(Isaque Pinheiro <https://www.isaquepinheiro.com.br>)
}

unit dbebr.driver.dbexpress;

interface

uses
  Classes,
  SysUtils,
  StrUtils,
  Variants,
  DB,
  SqlExpr,
  DBXCommon,
  // DBEBr
  dbebr.driver.connection,
  dbebr.factory.interfaces;

type
  // Classe de conex�o concreta com dbExpress
  TDriverDBExpress = class(TDriverConnection)
  private
    function _GetTransactionActive: TDBXTransaction;
  protected
    FConnection: TSQLConnection;
    FSQLScript: TSQLQuery;
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

  TDriverQueryDBExpress = class(TDriverQuery)
  private
    FSQLQuery: TSQLQuery;
    function _GetTransactionActive: TDBXTransaction;
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

  TDriverResultSetDBExpress = class(TDriverResultSet<TSQLQuery>)
  protected
    procedure _SetUniDirectional(const Value: Boolean); override;
    procedure _SetReadOnly(const Value: Boolean); override;
    procedure _SetCachedUpdates(const Value: Boolean); override;
    procedure _SetCommandText(const ACommandText: String); override;
    function _GetCommandText: String; override;
  public
    constructor Create(ADataSet: TSQLQuery; const AMonitor: ICommandMonitor;
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

{ TDriverDBExpress }

constructor TDriverDBExpress.Create(const AConnection: TComponent;
  const ADriverTransaction: TDriverTransaction;
  const ADriverName: TDriverName;
  const AMonitor: ICommandMonitor;
  const AMonitorCallback: TMonitorProc);
begin
  FConnection := AConnection as TSQLConnection;
  FDriverTransaction := ADriverTransaction;
  FDriverName := ADriverName;
  FCommandMonitor := AMonitor;
  FMonitorCallback := AMonitorCallback;
  FSQLScript  := TSQLQuery.Create(nil);
  try
    FSQLScript.SQLConnection := FConnection;
    FSQLScript.SQL.Clear;
  except
    FSQLScript.Free;
    raise;
  end;
end;

destructor TDriverDBExpress.Destroy;
begin
  FDriverTransaction := nil;
  FConnection := nil;
  FSQLScript.Free;
  inherited;
end;

procedure TDriverDBExpress.Disconnect;
begin
  FConnection.Connected := False;
end;

procedure TDriverDBExpress.ExecuteDirect(const ASQL: String);
var
  LExeSQL: TSQLQuery;
begin
  LExeSQL := TSQLQuery.Create(nil);
  try
    LExeSQL.SQLConnection := FConnection;
//    LExeSQL.SQLConnection := _GetTransactionActive;
    LExeSQL.SQL.Text := ASQL;
//    if not LExeSQL.Prepared then
//      LExeSQL.Prepare;
    LExeSQL.ExecSQL;
  finally
//    _SetMonitorLog(LExeSQL.SQL.Text, LExeSQL.sTransaction.Name, LExeSQL.Params);
    FRowsAffected := LExeSQL.RowsAffected;
    LExeSQL.Free;
  end;
end;

procedure TDriverDBExpress.ExecuteDirect(const ASQL: String; const AParams: TParams);
var
  LExeSQL: TSQLQuery;
  LFor: Int16;
begin
  LExeSQL := TSQLQuery.Create(nil);
  try
    LExeSQL.SQLConnection := FConnection;
//    LExeSQL.Transaction := _GetTransactionActive;
    LExeSQL.SQL.Text := ASQL;
    for LFor := 0 to AParams.Count - 1 do
    begin
      LExeSQL.ParamByName(AParams[LFor].Name).DataType := AParams[LFor].DataType;
      LExeSQL.ParamByName(AParams[LFor].Name).Value := AParams[LFor].Value;
    end;
//    if not LExeSQL.Prepared then
//      LExeSQL.Prepare;
    LExeSQL.ExecSQL;
  finally
//    _SetMonitorLog(LExeSQL.SQL.Text, LExeSQL.Transaction.Name, LExeSQL.Params);
    FRowsAffected := LExeSQL.RowsAffected;
    LExeSQL.Free;
  end;
end;

procedure TDriverDBExpress.ExecuteScript(const AScript: String);
begin
  AddScript(AScript);
  ExecuteScripts;
end;

procedure TDriverDBExpress.ExecuteScripts;
begin
  if FSQLScript.SQL.Count = 0 then
    Exit;
  try
//    FSQLScript.Transaction := _GetTransactionActive;
    FSQLScript.ExecSQL;
  finally
//    _SetMonitorLog(FSQLScript.SQL.Text, FSQLScript.Transaction.Name, nil);
    FRowsAffected := FSQLScript.RowsAffected;
    FSQLScript.SQL.Clear;
  end;
end;

function TDriverDBExpress.GetSQLScripts: String;
begin
//  Result := 'Transaction: ' + FSQLScript.Transaction.Name + ' ' +  FSQLScript.SQL.Text;
end;

procedure TDriverDBExpress.AddScript(const AScript: String);
begin
//  if MatchText(FConnection.ProviderName, ['Firebird', 'InterBase']) then // Firebird/Interbase
//    FSQLScript.SQL.Add('SET AUTOCOMMIT OFF');
  FSQLScript.SQL.Add(AScript);
end;

procedure TDriverDBExpress.ApplyUpdates(const ADataSets: array of IDBResultSet);
var
  LDataSet: IDBResultSet;
begin
  for LDataset in AdataSets do
    LDataset.ApplyUpdates;
end;

procedure TDriverDBExpress.Connect;
begin
  FConnection.Connected := True;
end;

function TDriverDBExpress._GetTransactionActive: TDBXTransaction;
begin
  Result := TDBXTransaction(FDriverTransaction.TransactionActive);
end;

function TDriverDBExpress.CreateQuery: IDBQuery;
begin
  Result := TDriverQueryDBExpress.Create(FConnection,
                                         FDriverTransaction,
                                         FCommandMonitor,
                                         FMonitorCallback);
end;

function TDriverDBExpress.CreateResultSet(const ASQL: String): IDBResultSet;
var
  LDBQuery: IDBQuery;
begin
  LDBQuery := TDriverQueryDBExpress.Create(FConnection,
                                           FDriverTransaction,
                                           FCommandMonitor,
                                           FMonitorCallback);
  LDBQuery.CommandText := ASQL;
  Result := LDBQuery.ExecuteQuery;
end;

{ TDriverDBExpressQuery }

constructor TDriverQueryDBExpress.Create(const AConnection: TSQLConnection;
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
    FSQLQuery.SQLConnection := AConnection;
  except
    FSQLQuery.Free;
    raise;
  end;
end;

destructor TDriverQueryDBExpress.Destroy;
begin
  FSQLQuery.Free;
  inherited;
end;

function TDriverQueryDBExpress.ExecuteQuery: IDBResultSet;
var
  LResultSet: TSQLQuery;
  LFor: Int16;
begin
  LResultSet := TSQLQuery.Create(nil);
  try
    LResultSet.SQLConnection := FSQLQuery.SQLConnection;
//    LResultSet.Transaction := _GetTransactionActive;
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
      Result := TDriverResultSetDBExpress.Create(LResultSet, FCommandMonitor, FMonitorCallback);
      if LResultSet.Active then
      begin
        /// <summary>
        /// if LResultSet.RecordCount = 0 then
        /// Ao checar Recordcount no DBXExpress da um erro de Object Inv�lid para o SQL
        /// select name as name, ' ' as description from sys.sequences
        /// </summary>
        if LResultSet.Eof then
          Result.FetchingAll := True;
      end;
    finally
//      if LResultSet.SQL.Text <> EmptyStr then
//        _SetMonitorLog(LResultSet.SQL.Text, LResultSet.Transaction.Name, LResultSet.Params);
    end;
  except
    if Assigned(LResultSet) then
      LResultSet.Free;
    raise;
  end;
end;

function TDriverQueryDBExpress.RowsAffected: UInt32;
begin
  Result := FRowsAffected;
end;

function TDriverQueryDBExpress._GetCommandText: String;
begin
  Result := FSQLQuery.CommandText;
end;

function TDriverQueryDBExpress._GetTransactionActive: TDBXTransaction;
begin
  Result := TDBXTransaction(FDriverTransaction.TransactionActive);
end;

procedure TDriverQueryDBExpress._SetCommandText(const ACommandText: String);
begin
  FSQLQuery.SQL.Text := ACommandText;
end;

procedure TDriverQueryDBExpress.ExecuteDirect;
var
  LExeSQL: TSQLQuery;
  LFor: Int16;
begin
  LExeSQL := TSQLQuery.Create(nil);
  try
    LExeSQL.SQLConnection := FSQLQuery.SQLConnection;
//    LExeSQL.Transaction := _GetTransactionActive;
    LExeSQL.SQL.Text := FSQLQuery.SQL.Text;
    for LFor := 0 to FSQLQuery.Params.Count - 1 do
    begin
      LExeSQL.Params[LFor].DataType := FSQLQuery.Params[LFor].DataType;
      LExeSQL.Params[LFor].Value := FSQLQuery.Params[LFor].Value;
    end;
//    if not LExeSQL.Prepared then
//      LExeSQL.Prepare;
    LExeSQL.ExecSQL;
  finally
//    _SetMonitorLog(LExeSQL.SQL.Text, LExeSQL.Transaction.Name, LExeSQL.Params);
    FRowsAffected := LExeSQL.RowsAffected;
    LExeSQL.Free;
  end;
end;

{ TDriverResultSetDBExpress }

procedure TDriverResultSetDBExpress.ApplyUpdates;
begin
//  FDataSet.ApplyUpdates;
end;

procedure TDriverResultSetDBExpress.CancelUpdates;
begin
//  FDataSet.CancelUpdates;
end;

constructor TDriverResultSetDBExpress.Create(ADataSet: TSQLQuery; const AMonitor: ICommandMonitor;
      const AMonitorCallback: TMonitorProc);
begin
  inherited Create(ADataSet, AMonitor, AMonitorCallback);
end;

destructor TDriverResultSetDBExpress.Destroy;
begin
  FDataSet.Free;
  inherited;
end;

function TDriverResultSetDBExpress.GetFieldValue(const AFieldName: String): Variant;
var
  LField: TField;
begin
  LField := FDataSet.FieldByName(AFieldName);
  Result := GetFieldValue(LField.Index);
end;

function TDriverResultSetDBExpress.GetField(const AFieldName: String): TField;
begin
  Result := FDataSet.FieldByName(AFieldName);
end;

function TDriverResultSetDBExpress.GetFieldType(const AFieldName: String): TFieldType;
begin
  Result := FDataSet.FieldByName(AFieldName).DataType;
end;

function TDriverResultSetDBExpress.GetFieldValue(const AFieldIndex: UInt16): Variant;
var
  LValue: Variant;
begin
  if AFieldIndex > FDataSet.FieldCount -1  then
    Exit(Variants.Null);

  if FDataSet.Fields[AFieldIndex].IsNull then
    Result := Variants.Null
  else
  begin
    LValue := FDataSet.Fields[AFieldIndex].Value;
    // Usando DBExpress para acessar SQLite os campos data retornam no
    // formato ISO8601 "yyyy-MM-dd e o DBExpress n�o converte para dd-MM-yyy,
    // ent�o tive que criar uma alternativa.
    if FDataSet.SQLConnection.DriverName = 'Sqlite' then
    begin
      if (Copy(LValue,5,1) = '-') and (Copy(LValue,8,1) = '-') then
      begin
         Result := Iso8601ToDateTime(LValue);
         Exit;
      end;
    end;
    Result := LValue;
  end;
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

function TDriverResultSetDBExpress.NotEof: Boolean;
begin
  if not FFirstNext then
     FFirstNext := True
  else
     FDataSet.Next;

  Result := not FDataSet.Eof;
end;

procedure TDriverResultSetDBExpress.Open;
begin
  try
    inherited Open;
  finally
//    _SetMonitorLog(FDataSet.SQL.Text, FDataSet.Transaction.Name, FDataSet.Params);
  end;
end;

function TDriverResultSetDBExpress.RowsAffected: UInt32;
begin
  Result := FDataSet.RowsAffected;
end;

function TDriverResultSetDBExpress._GetCommandText: String;
begin
  Result := FDataSet.SQL.Text;
end;

procedure DriverResultSetDBExpress._SetCachedUpdates(const Value: Boolean);
begin
  FDataSet.CachedUpdates := Value;
end;

procedure DriverResultSetDBExpress._SetCommandText(const ACommandText: String);
begin
  FDataSet.SQL.Text := ACommandText;
end;

procedure DriverResultSetDBExpress._SetReadOnly(const Value: Boolean);
begin
  FDataSet.ReadOnly := Value;
end;

procedure DriverResultSetDBExpress._SetUniDirectional(const Value: Boolean);
begin
  FDataSet.UniDirectional := Value;
end;

function TDriverResultSetDBExpress.Iso8601ToDateTime(const AValue: String): TDateTime;
var
  Y, M, D, HH, MI, SS: Cardinal;
begin
  // YYYY-MM-DD   Thh:mm:ss  or  YYYY-MM-DDThh:mm:ss
  // 1234567890   123456789      1234567890123456789
  Result := StrToDateTimeDef(AValue, 0);
  case Length(AValue) of
    9:
      if (AValue[1] = 'T') and (AValue[4] = ':') and (AValue[7] = ':') then
      begin
        HH := Ord(AValue[2]) * 10 + Ord(AValue[3]) - (48 + 480);
        MI := Ord(AValue[5]) * 10 + Ord(AValue[6]) - (48 + 480);
        SS := Ord(AValue[8]) * 10 + Ord(AValue[9]) - (48 + 480);
        if (HH < 24) and (MI < 60) and (SS < 60) then
          Result := EncodeTime(HH, MI, SS, 0);
      end;
    10:
      if (AValue[5] = AValue[8]) and (Ord(AValue[8]) in [Ord('-'), Ord('/')]) then
      begin
        Y := Ord(AValue[1]) * 1000 + Ord(AValue[2]) * 100 + Ord(AValue[3]) * 10 + Ord(AValue[4]) - (48 + 480 + 4800 + 48000);
        M := Ord(AValue[6]) * 10 + Ord(AValue[7]) - (48 + 480);
        D := Ord(AValue[9]) * 10 + Ord(AValue[10]) - (48 + 480);
        if (Y <= 9999) and ((M - 1) < 12) and ((D - 1) < 31) then
          Result := EncodeDate(Y, M, D);
      end;
    19,24:
      if (AValue[5] = AValue[8]) and
         (Ord(AValue[8]) in [Ord('-'), Ord('/')]) and
         (Ord(AValue[11]) in [Ord(' '), Ord('T')]) and
         (AValue[14] = ':') and
         (AValue[17] = ':') then
      begin
        Y := Ord(AValue[1]) * 1000 + Ord(AValue[2]) * 100 + Ord(AValue[3]) * 10 + Ord(AValue[4]) - (48 + 480 + 4800 + 48000);
        M := Ord(AValue[6]) * 10 + Ord(AValue[7]) - (48 + 480);
        D := Ord(AValue[9]) * 10 + Ord(AValue[10]) - (48 + 480);
        HH := Ord(AValue[12]) * 10 + Ord(AValue[13]) - (48 + 480);
        MI := Ord(AValue[15]) * 10 + Ord(AValue[16]) - (48 + 480);
        SS := Ord(AValue[18]) * 10 + Ord(AValue[19]) - (48 + 480);
        if (Y <= 9999) and ((M - 1) < 12) and ((D - 1) < 31) and (HH < 24) and (MI < 60) and (SS < 60) then
          Result := EncodeDate(Y, M, D) + EncodeTime(HH, MI, SS, 0);
      end;
  end;
end;

end.
