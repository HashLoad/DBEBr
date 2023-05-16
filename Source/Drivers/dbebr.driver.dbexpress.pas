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

unit dbebr.driver.dbexpress;

interface

uses
  Classes,
  DB,
  SqlExpr,
  Variants,
  SysUtils,
  // DBEBr
  dbebr.driver.connection,
  dbebr.factory.interfaces;

type
  // Classe de conexão concreta com dbExpress
  TDriverDBExpress = class(TDriverConnection)
  protected
    FConnection: TSQLConnection;
    FSQLScript: TSQLQuery;
  public
    constructor Create(const AConnection: TComponent;
      const ADriverName: TDriverName); override;
    destructor Destroy; override;
    procedure Connect; override;
    procedure Disconnect; override;
    procedure ExecuteDirect(const ASQL: string); overload; override;
    procedure ExecuteDirect(const ASQL: string;
      const AParams: TParams); overload; override;
    procedure ExecuteScript(const AScript: string); override;
    procedure AddScript(const AScript: string); override;
    procedure ExecuteScripts; override;
    function IsConnected: Boolean; override;
    function InTransaction: Boolean; override;
    function CreateQuery: IDBQuery; override;
    function CreateResultSet(const ASQL: String): IDBResultSet; override;
  end;

  TDriverQueryDBExpress = class(TDriverQuery)
  private
    FSQLQuery: TSQLQuery;
  protected
    procedure SetCommandText(ACommandText: string); override;
    function GetCommandText: string; override;
  public
    constructor Create(AConnection: TSQLConnection);
    destructor Destroy; override;
    procedure ExecuteDirect; override;
    function ExecuteQuery: IDBResultSet; override;
  end;

  TDriverResultSetDBExpress = class(TDriverResultSet<TSQLQuery>)
  private
    function Iso8601ToDateTime(const AValue: string): TDateTime;
  public
    constructor Create(ADataSet: TSQLQuery); override;
    destructor Destroy; override;
    function NotEof: Boolean; override;
    function GetFieldValue(const AFieldName: string): Variant; overload; override;
    function GetFieldValue(const AFieldIndex: Integer): Variant; overload; override;
    function GetFieldType(const AFieldName: string): TFieldType; overload; override;
    function GetField(const AFieldName: string): TField; override;
  end;

implementation

{ TDriverDBExpress }

constructor TDriverDBExpress.Create(const AConnection: TComponent;
  const ADriverName: TDriverName);
begin
  inherited;
  FConnection := AConnection as TSQLConnection;
  FDriverName := ADriverName;
  FSQLScript := TSQLQuery.Create(nil);
  try
    FSQLScript.SQLConnection := FConnection;
  except
    FSQLScript.Free;
    raise;
  end;
end;

destructor TDriverDBExpress.Destroy;
begin
  FConnection := nil;
  FSQLScript.Free;
  inherited;
end;

procedure TDriverDBExpress.Disconnect;
begin
  inherited;
  FConnection.Connected := False;
end;

procedure TDriverDBExpress.ExecuteDirect(const ASQL: string);
begin
  inherited;
  FConnection.ExecuteDirect(ASQL);
end;

procedure TDriverDBExpress.ExecuteDirect(const ASQL: string; const AParams: TParams);
var
  LExeSQL: TSQLQuery;
  LFor: Integer;
begin
  LExeSQL := TSQLQuery.Create(nil);
  try
    LExeSQL.SQLConnection := FConnection;
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

procedure TDriverDBExpress.ExecuteScript(const AScript: string);
begin
  inherited;
  FSQLScript.SQL.Text := AScript;
  FSQLScript.ExecSQL;
end;

procedure TDriverDBExpress.ExecuteScripts;
begin
  inherited;
  try
    FSQLScript.ExecSQL;
  finally
    FSQLScript.SQL.Clear;
  end;
end;

procedure TDriverDBExpress.AddScript(const AScript: string);
begin
  inherited;
  FSQLScript.SQL.Add(AScript);
end;

procedure TDriverDBExpress.Connect;
begin
  inherited;
  FConnection.Connected := True;
end;

function TDriverDBExpress.InTransaction: Boolean;
begin
  inherited;
  Result := FConnection.InTransaction;
end;

function TDriverDBExpress.IsConnected: Boolean;
begin
  inherited;
  Result := FConnection.Connected;
end;

function TDriverDBExpress.CreateQuery: IDBQuery;
begin
  Result := TDriverQueryDBExpress.Create(FConnection);
end;

function TDriverDBExpress.CreateResultSet(const ASQL: String): IDBResultSet;
var
  LDBQuery: IDBQuery;
begin
  LDBQuery := TDriverQueryDBExpress.Create(FConnection);
  LDBQuery.CommandText := ASQL;
  Result := LDBQuery.ExecuteQuery;
end;

{ TDriverDBExpressQuery }

constructor TDriverQueryDBExpress.Create(AConnection: TSQLConnection);
begin
  if AConnection = nil then
    Exit;

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
  LFor: Integer;
begin
  LResultSet := TSQLQuery.Create(nil);
  try
    LResultSet.SQLConnection := FSQLQuery.SQLConnection;
    LResultSet.SQL.Text := FSQLQuery.CommandText;

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
  Result := TDriverResultSetDBExpress.Create(LResultSet);
  /// <summary>
  /// if LResultSet.RecordCount = 0 then
  /// Ao checar Recordcount no DBXExpress da um erro de Object Inválid para o SQL
  /// select name as name, ' ' as description from sys.sequences
  /// </summary>
  if LResultSet.Eof then
     Result.FetchingAll := True;
end;

function TDriverQueryDBExpress.GetCommandText: string;
begin
  Result := FSQLQuery.CommandText;
end;

procedure TDriverQueryDBExpress.SetCommandText(ACommandText: string);
begin
  inherited;
  FSQLQuery.CommandText := ACommandText;
end;

procedure TDriverQueryDBExpress.ExecuteDirect;
begin
  FSQLQuery.ExecSQL;
end;

{ TDriverResultSetDBExpress }

constructor TDriverResultSetDBExpress.Create(ADataSet: TSQLQuery);
begin
  FDataSet := ADataSet;
  inherited;
end;

destructor TDriverResultSetDBExpress.Destroy;
begin
  FDataSet.Free;
  inherited;
end;

function TDriverResultSetDBExpress.GetFieldValue(const AFieldName: string): Variant;
var
  LField: TField;
begin
  LField := FDataSet.FieldByName(AFieldName);
  Result := GetFieldValue(LField.Index);
end;

function TDriverResultSetDBExpress.GetField(const AFieldName: string): TField;
begin
  inherited;
  Result := FDataSet.FieldByName(AFieldName);
end;

function TDriverResultSetDBExpress.GetFieldType(const AFieldName: string): TFieldType;
begin
  Result := FDataSet.FieldByName(AFieldName).DataType;
end;

function TDriverResultSetDBExpress.GetFieldValue(const AFieldIndex: Integer): Variant;
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
    // formato ISO8601 "yyyy-MM-dd e o DBExpress não converte para dd-MM-yyy,
    // então tive que criar uma alternativa.
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

function TDriverResultSetDBExpress.NotEof: Boolean;
begin
  if not FFirstNext then
     FFirstNext := True
  else
     FDataSet.Next;

  Result := not FDataSet.Eof;
end;


function TDriverResultSetDBExpress.Iso8601ToDateTime(const AValue: string): TDateTime;
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