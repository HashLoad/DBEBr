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

unit dbebr.driver.connection;

{$ifdef fpc}
  {$mode delphi}{$H+}
{$endif}

interface

uses
  DB,
  Math,
  Classes,
  SysUtils,
  Variants,
  // DBEBr
  dbebr.factory.interfaces;

type
  // Classe de conexões abstract
  TDriverConnection = class abstract
  protected
    FDriverName: TDriverName;
  public
    constructor Create(const AConnection: TComponent;
      const ADriverName: TDriverName); virtual; abstract;
    procedure Connect; virtual; abstract;
    procedure Disconnect; virtual; abstract;
    procedure ExecuteDirect(const ASQL: String); overload; virtual; abstract;
    procedure ExecuteDirect(const ASQL: String;
      const AParams: TParams); overload; virtual; abstract;
    procedure ExecuteScript(const AScript: String); virtual; abstract;
    procedure AddScript(const AScript: String); virtual; abstract;
    procedure ExecuteScripts; virtual; abstract;
    function IsConnected: Boolean; virtual; abstract;
    function InTransaction: Boolean; virtual; abstract;
    function CreateQuery: IDBQuery; virtual; abstract;
    function CreateResultSet(const ASQL: String): IDBResultSet; virtual; abstract;
    property DriverName: TDriverName read FDriverName;
  end;

  // Classe de trasações abstract
  TDriverTransaction = class abstract
  public
    constructor Create(AConnection: TComponent); virtual; abstract;
    procedure StartTransaction; virtual; abstract;
    procedure Commit; virtual; abstract;
    procedure Rollback; virtual; abstract;
    function InTransaction: Boolean; virtual; abstract;
  end;

  TOptions = class(TInterfacedObject, IOptions)
  strict private
    FStoreGUIDAsOctet: Boolean;
  public
    constructor Create;
    function StoreGUIDAsOctet(const AValue: Boolean): IOptions; overload;
    function StoreGUIDAsOctet: Boolean; overload;
  end;

  TDriverQuery = class(TInterfacedObject, IDBQuery)
  protected
    procedure SetCommandText(ACommandText: String); virtual; abstract;
    function GetCommandText: String; virtual; abstract;
  public
    procedure ExecuteDirect; virtual; abstract;
    function ExecuteQuery: IDBResultSet; virtual; abstract;
    property CommandText: String read GetCommandText write SetCommandText;
  end;

  TDriverResultSetBase = class(TInterfacedObject, IDBResultSet)
  private
    function _GetFetchingAll: Boolean;
    procedure _SetFetchingAll(const Value: Boolean);
  protected
    FField: TAsField;
    FFieldNameInternal: String;
    FRecordCount: Integer;
    FFetchingAll: Boolean;
    FFirstNext: Boolean;
    function _GetFilter: String; virtual; abstract;
    procedure _SetFilter(const Value: String); virtual; abstract;
    function _GetFilterOptions: TFilterOptions; virtual; abstract;
    procedure _SetFilterOptions(Value: TFilterOptions); virtual; abstract;
    function _GetActive: Boolean; virtual; abstract;
    procedure _SetActive(const Value: Boolean); virtual; abstract;
  public
    constructor Create; overload; virtual;
    destructor Destroy; override;
    procedure Close; virtual; abstract;
    procedure Open; virtual; abstract;
    procedure Delete; virtual; abstract;
    procedure Cancel; virtual; abstract;
    procedure Clear; virtual; abstract;
    procedure DisableControls; virtual; abstract;
    procedure EnableControls; virtual; abstract;
    procedure Next; virtual; abstract;
    procedure Prior; virtual; abstract;
    procedure Append; virtual; abstract;
    procedure Insert; virtual; abstract;
    procedure Edit; virtual; abstract;
    procedure Post; virtual; abstract;
    procedure First; virtual; abstract;
    procedure Last; virtual; abstract;
    procedure FreeBookmark(Bookmark: TBookmark); virtual; abstract;
    function Locate(const KeyFields: string; const KeyValues: Variant;
      Options: TLocateOptions): Boolean; virtual; abstract;
    function Lookup(const KeyFields: string; const KeyValues: Variant;
      const ResultFields: string): Variant; virtual; abstract;
    function IsEmpty: Boolean; virtual; abstract;
    function GetBookmark: TBookmark; virtual; abstract;
    function FieldCount: Integer; virtual; abstract;
    function State: TDataSetState; virtual; abstract;
    function Filtered: Boolean; virtual; abstract;
    function Modified: Boolean; virtual; abstract;
    function NotEof: Boolean; virtual; abstract;
    function GetFieldValue(const AFieldName: String): Variant; overload; virtual; abstract;
    function GetFieldValue(const AFieldIndex: Integer): Variant; overload; virtual; abstract;
    function GetFieldType(const AFieldName: String): TFieldType; overload; virtual; abstract;
    function GetField(const AFieldName: String): TField; virtual; abstract;
    function FieldByName(const AFieldName: String): TAsField; virtual;
    function RecordCount: Integer; virtual;
    function FieldDefs: TFieldDefs; virtual; abstract;
    function DataSet: TDataSet; virtual; abstract;
  end;

  TDriverResultSet<T: TDataSet> = class abstract(TDriverResultSetBase)
  protected
    FDataSet: T;
    function _GetFilter: String; override;
    procedure _SetFilter(const Value: String); override;
    function _GetFilterOptions: TFilterOptions; override;
    procedure _SetFilterOptions(Value: TFilterOptions); override;
    function _GetActive: Boolean; override;
    procedure _SetActive(const Value: Boolean); override;
  public
    constructor Create(ADataSet: T); overload; virtual;
    procedure Close; override;
    procedure Open; override;
    procedure Delete; override;
    procedure Cancel; override;
    procedure Clear; override;
    procedure DisableControls; override;
    procedure EnableControls; override;
    procedure Next; override;
    procedure Prior; override;
    procedure Append; override;
    procedure Insert; override;
    procedure Edit; override;
    procedure Post; override;
    procedure First; override;
    procedure Last; override;
    procedure FreeBookmark(Bookmark: TBookmark); override;
    function Locate(const KeyFields: string; const KeyValues: Variant;
      Options: TLocateOptions): Boolean; override;
    function Lookup(const KeyFields: string; const KeyValues: Variant;
      const ResultFields: string): Variant; override;
    function IsEmpty: Boolean; override;
    function GetBookmark: TBookmark; override;
    function FieldCount: Integer; override;
    function State: TDataSetState; override;
    function Filtered: Boolean; override;
    function Modified: Boolean; override;
    function FieldDefs: TFieldDefs; override;
    function DataSet: TDataSet; override;
  end;

  TDBEBrField = class(TAsField)
  private
    FOwner: TDriverResultSetBase;
  public
    constructor Create(AOwner: TDriverResultSetBase);
    destructor Destroy; override;
    function IsNull: Boolean; override;
    function AsBlob: TMemoryStream; override;
    function AsBlobPtr(out iNumBytes: Integer): Pointer; override;
    function AsBlobText: String; override;
    function AsBlobTextDef(const Def: String = ''): String; override;
    function AsDateTime: TDateTime; override;
    function AsDateTimeDef(const Def: TDateTime = 0.0): TDateTime; override;
    function AsDouble: Double; override;
    function AsDoubleDef(const Def: Double = 0.0): Double; override;
    function AsInteger: Int64; override;
    function AsIntegerDef(const Def: Int64 = 0): Int64; override;
    function AsString: String; override;
    function AsStringDef(const Def: String = ''): String; override;
    function AsFloat: Double; override;
    function AsFloatDef(const Def: Double = 0): Double; override;
    function AsCurrency: Currency; override;
    function AsCurrencyDef(const Def: Currency = 0): Currency; override;
    function AsExtended: Extended; override;
    function AsExtendedDef(const Def: Extended = 0): Extended; override;
    function AsVariant: Variant; override;
    function AsVariantDef(const Def: Variant): Variant; override;
    function AsBoolean: Boolean; override;
    function AsBooleanDef(const Def: Boolean = False): Boolean; override;
    function Value: Variant; override;
    function ValueDef(const Def: Variant): Variant; override;
  end;

implementation

{ TDriverResultSet<T> }

constructor TDriverResultSet<T>.Create(ADataSet: T);
begin
  Create;
  // Guarda RecordCount do último SELECT executado no IDBResultSet
  try
  FRecordCount := FDataSet.RecordCount;
  except
  end;
end;

function TDriverResultSet<T>.DataSet: TDataSet;
begin
  Result := FDataSet;
end;

procedure TDriverResultSet<T>.Append;
begin
  FDataSet.Append;
end;

procedure TDriverResultSet<T>.Cancel;
begin
  inherited;
  FDataSet.Cancel;
end;

procedure TDriverResultSet<T>.Delete;
begin
  inherited;
  FDataSet.Delete;
end;

procedure TDriverResultSet<T>.DisableControls;
begin
  FDataSet.DisableControls;
end;

procedure TDriverResultSet<T>.Edit;
begin
  FDataSet.Edit;
end;

procedure TDriverResultSet<T>.EnableControls;
begin
  FDataSet.EnableControls;
end;

procedure TDriverResultSet<T>.Clear;
begin
  inherited;
  FDataSet.DisableControls;
  FDataSet.First;
  try
    repeat
      FDataSet.Delete
    until (not FDataSet.Eof);
  finally
    FDataSet.EnableControls;
  end;
end;

procedure TDriverResultSet<T>.Close;
begin
  inherited;
  FDataSet.Close;
end;

function TDriverResultSet<T>.FieldCount: Integer;
begin
  Result := FDataSet.FieldCount;
end;

function TDriverResultSet<T>.FieldDefs: TFieldDefs;
begin
  inherited;
  Result := FDataSet.FieldDefs;
end;

function TDriverResultSet<T>.Filtered: Boolean;
begin
  Result := FDataSet.Filtered;
end;

procedure TDriverResultSet<T>.First;
begin
  FDataSet.First;
end;

procedure TDriverResultSet<T>.FreeBookmark(Bookmark: TBookmark);
begin
  FDataSet.FreeBookmark(Bookmark);
end;

function TDriverResultSet<T>.GetBookmark: TBookmark;
begin
  Result := FDataSet.GetBookmark;
end;

procedure TDriverResultSet<T>.Insert;
begin
  FDataSet.Insert;
end;

function TDriverResultSet<T>.IsEmpty: Boolean;
begin
  Result := FRecordCount = 0;
end;

procedure TDriverResultSet<T>.Last;
begin
  FDataSet.Last;
end;

function TDriverResultSet<T>.Locate(const KeyFields: string;
  const KeyValues: Variant; Options: TLocateOptions): Boolean;
begin
  Result := FDataSet.Locate(KeyFields, KeyValues, Options);
end;

function TDriverResultSet<T>.Lookup(const KeyFields: string;
  const KeyValues: Variant; const ResultFields: string): Variant;
begin
  Result := FDataSet.Lookup(KeyFields, KeyValues, ResultFields);
end;

function TDriverResultSet<T>.Modified: Boolean;
begin
  Result := FDataSet.Modified;
end;

procedure TDriverResultSet<T>.Next;
begin
  FDataSet.Next;
end;

procedure TDriverResultSet<T>.Open;
begin
  inherited;
  FDataSet.Open;
end;

procedure TDriverResultSet<T>.Post;
begin
  FDataSet.Post;
end;

procedure TDriverResultSet<T>.Prior;
begin
  FDataSet.Prior;
end;

function TDriverResultSet<T>.State: TDataSetState;
begin
  Result := FDataSet.State;
end;

function TDriverResultSet<T>._GetActive: Boolean;
begin
  Result := FDataSet.Active;
end;

function TDriverResultSet<T>._GetFilter: String;
begin
  Result := FDataSet.Filter;
end;

function TDriverResultSet<T>._GetFilterOptions: TFilterOptions;
begin
  Result := FDataSet.FilterOptions;
end;

procedure TDriverResultSet<T>._SetActive(const Value: Boolean);
begin
  FDataSet.Active := Value;
end;

procedure TDriverResultSet<T>._SetFilter(const Value: String);
begin
  FDataSet.Filter := Value;
end;

procedure TDriverResultSet<T>._SetFilterOptions(Value: TFilterOptions);
begin
  FDataSet.FilterOptions := Value;
end;

{ TDriverResultSetBase }

function TDriverResultSetBase.RecordCount: Integer;
begin
  Result := FRecordCount;
end;

constructor TDriverResultSetBase.Create;
begin
  FField := TDBEBrField.Create(Self);
end;

destructor TDriverResultSetBase.Destroy;
begin
  FField.Free;
  inherited;
end;

function TDriverResultSetBase.FieldByName(const AFieldName: String): TAsField;
begin
  FField.AsFieldName := AFieldName;
  Result := FField;
end;

function TDriverResultSetBase._GetFetchingAll: Boolean;
begin
  Result := FFetchingAll;
end;

procedure TDriverResultSetBase._SetFetchingAll(const Value: Boolean);
begin
  FFetchingAll := Value;
end;

{ TAsField }

constructor TDBEBrField.Create(AOwner: TDriverResultSetBase);
begin
  FOwner := AOwner;
end;

destructor TDBEBrField.Destroy;
begin
  FOwner := nil;
  inherited;
end;

function TDBEBrField.AsBlob: TMemoryStream;
begin
//  Result := TMemoryStream( FOwner.GetFieldValue(FAsFieldName) );
  Result := nil;
end;

function TDBEBrField.AsBlobPtr(out iNumBytes: Integer): Pointer;
begin
//  Result := Pointer( FOwner.GetFieldValue(FAsFieldName) );
  Result := nil;
end;

function TDBEBrField.AsBlobText: String;
var
  LResult: Variant;
begin
  Result := '';
  LResult := FOwner.GetFieldValue(FAsFieldName);
  if LResult <> Null then
    Result := String(LResult);
end;

function TDBEBrField.AsBlobTextDef(const Def: String): String;
begin
  try
    Result := String(FOwner.GetFieldValue(FAsFieldName));
  except
    Result := Def;
  end;
end;

function TDBEBrField.AsBoolean: Boolean;
var
  LResult: Variant;
begin
  Result := False;
  LResult := FOwner.GetFieldValue(FAsFieldName);
  if LResult <> Null then
    Result := Boolean(Value);
end;

function TDBEBrField.AsBooleanDef(const Def: Boolean): Boolean;
begin
  try
    Result := Boolean(FOwner.GetFieldValue(FAsFieldName));
  except
    Result := Def;
  end;
end;

function TDBEBrField.AsCurrency: Currency;
var
  LResult: Variant;
begin
  Result := 0;
  LResult := FOwner.GetFieldValue(FAsFieldName);
  if LResult <> Null then
    Result := Currency(LResult);
end;

function TDBEBrField.AsCurrencyDef(const Def: Currency): Currency;
begin
  try
    Result := Currency(FOwner.GetFieldValue(FAsFieldName));
  except
    Result := Def;
  end;
end;

function TDBEBrField.AsDateTime: TDateTime;
var
  LResult: Variant;
begin
  Result := 0;
  LResult := FOwner.GetFieldValue(FAsFieldName);
  if LResult <> Null then
    Result := TDateTime(LResult);
end;

function TDBEBrField.AsDateTimeDef(const Def: TDateTime): TDateTime;
begin
  try
    Result := TDateTime( FOwner.GetFieldValue(FAsFieldName) );
  except
    Result := Def;
  end;
end;

function TDBEBrField.AsDouble: Double;
var
  LResult: Variant;
begin
  Result := 0;
  LResult := FOwner.GetFieldValue(FAsFieldName);
  if LResult <> Null then
    Result := Double(LResult);
end;

function TDBEBrField.AsDoubleDef(const Def: Double): Double;
begin
  try
    Result := Double(FOwner.GetFieldValue(FAsFieldName));
  except
    Result := Def;
  end;
end;

function TDBEBrField.AsExtended: Extended;
var
  LResult: Variant;
begin
  Result := 0;
  LResult := FOwner.GetFieldValue(FAsFieldName);
  if LResult <> Null then
    Result := Extended(LResult);
end;

function TDBEBrField.AsExtendedDef(const Def: Extended): Extended;
begin
  try
    Result := Extended(FOwner.GetFieldValue(FAsFieldName));
  except
    Result := Def;
  end;
end;

function TDBEBrField.AsFloat: Double;
var
  LResult: Variant;
begin
  Result := 0;
  LResult := FOwner.GetFieldValue(FAsFieldName);
  if LResult <> Null then
    Result := Double(LResult);
end;

function TDBEBrField.AsFloatDef(const Def: Double): Double;
begin
  try
    Result := Double(FOwner.GetFieldValue(FAsFieldName));
  except
    Result := Def;
  end;
end;

function TDBEBrField.AsInteger: Int64;
var
  LResult: Variant;
begin
  Result := 0;
  LResult := FOwner.GetFieldValue(FAsFieldName);
  if LResult <> Null then
    Result := LResult;
end;

function TDBEBrField.AsIntegerDef(const Def: Int64): Int64;
begin
  try
    Result := FOwner.GetFieldValue(FAsFieldName);
  except
    Result := Def;
  end;
end;

function TDBEBrField.AsString: String;
var
  LResult: Variant;
begin
  Result := '';
  LResult := FOwner.GetFieldValue(FAsFieldName);
  if LResult <> Null then
    Result := String(LResult);
end;

function TDBEBrField.AsStringDef(const Def: String): String;
begin
  try
    Result := String(FOwner.GetFieldValue(FAsFieldName));
  except
    Result := Def;
  end;
end;

function TDBEBrField.AsVariant: Variant;
begin
  Result := FOwner.GetFieldValue(FAsFieldName);
end;

function TDBEBrField.AsVariantDef(const Def: Variant): Variant;
begin
  try
    Result := FOwner.GetFieldValue(FAsFieldName);
  except
    Result := Def;
  end;
end;

function TDBEBrField.IsNull: Boolean;
begin
  Result := FOwner.GetFieldValue(FAsFieldName) = Null;
end;

function TDBEBrField.Value: Variant;
begin
  Result := FOwner.GetFieldValue(FAsFieldName);
end;

function TDBEBrField.ValueDef(const Def: Variant): Variant;
begin
  try
    Result := FOwner.GetFieldValue(FAsFieldName);
  except
    Result := Def;
  end;
end;

{ TDBDefinition }

function TOptions.StoreGUIDAsOctet(const AValue: Boolean): IOptions;
begin
  Result := Self;
  FStoreGUIDAsOctet := AValue;
end;

constructor TOptions.Create;
begin
  FStoreGUIDAsOctet := False;
end;

function TOptions.StoreGUIDAsOctet: Boolean;
begin
  Result := FStoreGUIDAsOctet;
end;

end.
