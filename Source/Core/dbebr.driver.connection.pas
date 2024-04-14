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
  Generics.Collections,
  // DBEBr
  dbebr.factory.interfaces;

type
  TDriverTransaction = class;

  // Classe de conexões abstract
  TDriverConnection = class abstract
  protected
    FDriverTransaction: TDriverTransaction;
    FCommandMonitor: ICommandMonitor;
    FMonitorCallback: TMonitorProc;
    FDriverName: TDriverName;
    FRowsAffected: UInt32;
    procedure _SetMonitorLog(const ASQL: String; const ATransactionName: String;
      const AParams: TParams);
  public
    constructor Create(const AConnection: TComponent;
      const ADriverTransaction: TDriverTransaction;
      const ADriverName: TDriverName;
      const AMonitor: ICommandMonitor;
      const AMonitorCallback: TMonitorProc); virtual; abstract;
    procedure Connect; virtual; abstract;
    procedure Disconnect; virtual; abstract;
    procedure ExecuteDirect(const ASQL: String); overload; virtual; abstract;
    procedure ExecuteDirect(const ASQL: String;
      const AParams: TParams); overload; virtual; abstract;
    procedure ExecuteScript(const AScript: String); virtual; abstract;
    procedure AddScript(const AScript: String); virtual; abstract;
    procedure ExecuteScripts; virtual; abstract;
    function IsConnected: Boolean; virtual; abstract;
    function CreateQuery: IDBQuery; virtual; abstract;
    function CreateResultSet(const ASQL: String): IDBResultSet; virtual; abstract;
    function GetDriverName: TDriverName; virtual;
    // Concrete class methods implementation
    function GetSQLScripts: String; virtual;
    function RowsAffected: UInt32; virtual;
    procedure ApplyUpdates(const ADataSets: array of IDBResultSet); virtual;
  end;

  // Classe de trasações abstract
  TDriverTransaction = class abstract(TInterfacedObject, IDBTransaction)
  protected
    FTransactionList: TDictionary<String, TComponent>;
    FTransactionActive: TComponent;
    function _GetTransaction(const AKey: String): TComponent; virtual;
  public
    constructor Create(const AConnection: TComponent); virtual; abstract;
    procedure StartTransaction; virtual; abstract;
    procedure Commit; virtual; abstract;
    procedure Rollback; virtual; abstract;
    procedure AddTransaction(const AKey: String; const ATransaction: TComponent); virtual;
    procedure UseTransaction(const AKey: String); virtual;
    function TransactionActive: TComponent; virtual;
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
    FDriverTransaction: TDriverTransaction;
    FCommandMonitor: ICommandMonitor;
    FMonitorCallback: TMonitorProc;
    FRowsAffected: UInt32;
    procedure _SetMonitorLog(const ASQL: String; const ATransactionName: String;
      const AParams: TParams);
    // Concrete class methods implementation
    procedure _SetCommandText(const ACommandText: String); virtual;
    function _GetCommandText: String; virtual;
  public
    procedure ExecuteDirect; virtual; abstract;
    function ExecuteQuery: IDBResultSet; virtual; abstract;
    // Concrete class methods implementation
    function RowsAffected: UInt32; virtual;
  end;

  TDriverResultSetBase = class(TInterfacedObject, IDBResultSet)
  private
    function _GetFetchingAll: Boolean;
    procedure _SetFetchingAll(const Value: Boolean);
  protected
    FField: TAsField;
    FFieldNameInternal: String;
    FRecordCount: UInt32;
    FFetchingAll: Boolean;
    FFirstNext: Boolean;
    FCommandMonitor: ICommandMonitor;
    FMonitorCallback: TMonitorProc;
    function _GetFilter: String; virtual; abstract;
    function _GetFiltered: Boolean; virtual; abstract;
    function _GetFilterOptions: TFilterOptions; virtual; abstract;
    function _GetActive: Boolean; virtual; abstract;
    function _GetAfterCancel: TDataSetNotifyEvent; virtual; abstract;
    function _GetAfterClose: TDataSetNotifyEvent; virtual; abstract;
    function _GetAfterDelete: TDataSetNotifyEvent; virtual; abstract;
    function _GetAfterEdit: TDataSetNotifyEvent; virtual; abstract;
    function _GetAfterInsert: TDataSetNotifyEvent; virtual; abstract;
    function _GetAfterOpen: TDataSetNotifyEvent; virtual; abstract;
    function _GetAfterPost: TDataSetNotifyEvent; virtual; abstract;
    function _GetAfterRefresh: TDataSetNotifyEvent; virtual; abstract;
    function _GetAfterScroll: TDataSetNotifyEvent; virtual; abstract;
    function _GetAutoCalcFields: Boolean; virtual; abstract;
    function _GetBeforeCancel: TDataSetNotifyEvent; virtual; abstract;
    function _GetBeforeClose: TDataSetNotifyEvent; virtual; abstract;
    function _GetBeforeDelete: TDataSetNotifyEvent; virtual; abstract;
    function _GetBeforeEdit: TDataSetNotifyEvent; virtual; abstract;
    function _GetBeforeInsert: TDataSetNotifyEvent; virtual; abstract;
    function _GetBeforeOpen: TDataSetNotifyEvent; virtual; abstract;
    function _GetBeforePost: TDataSetNotifyEvent; virtual; abstract;
    function _GetBeforeRefresh: TDataSetNotifyEvent; virtual; abstract;
    function _GetBeforeScroll: TDataSetNotifyEvent; virtual; abstract;
    function _GetOnCalcFields: TDataSetNotifyEvent; virtual; abstract;
    function _GetOnDeleteError: TDataSetErrorEvent; virtual; abstract;
    function _GetOnEditError: TDataSetErrorEvent; virtual; abstract;
    function _GetOnFilterRecord: TFilterRecordEvent; virtual; abstract;
    function _GetOnNewRecord: TDataSetNotifyEvent; virtual; abstract;
    function _GetOnPostError: TDataSetErrorEvent; virtual; abstract;
    procedure _SetFilter(const Value: String); virtual; abstract;
    procedure _SetFiltered(const Value: Boolean); virtual; abstract;
    procedure _SetFilterOptions(Value: TFilterOptions); virtual; abstract;
    procedure _SetActive(const Value: Boolean); virtual; abstract;
    procedure _SetAfterCancel(const Value: TDataSetNotifyEvent); virtual; abstract;
    procedure _SetAfterOpen(const Value: TDataSetNotifyEvent); virtual; abstract;
    procedure _SetAfterClose(const Value: TDataSetNotifyEvent); virtual; abstract;
    procedure _SetAfterDelete(const Value: TDataSetNotifyEvent); virtual; abstract;
    procedure _SetAfterEdit(const Value: TDataSetNotifyEvent); virtual; abstract;
    procedure _SetAfterInsert(const Value: TDataSetNotifyEvent); virtual; abstract;
    procedure _SetAfterPost(const Value: TDataSetNotifyEvent); virtual; abstract;
    procedure _SetAfterRefresh(const Value: TDataSetNotifyEvent); virtual; abstract;
    procedure _SetAfterScroll(const Value: TDataSetNotifyEvent); virtual; abstract;
    procedure _SetAutoCalcFields(const Value: Boolean); virtual; abstract;
    procedure _SetBeforeCancel(const Value: TDataSetNotifyEvent); virtual; abstract;
    procedure _SetBeforeDelete(const Value: TDataSetNotifyEvent); virtual; abstract;
    procedure _SetBeforeEdit(const Value: TDataSetNotifyEvent); virtual; abstract;
    procedure _SetBeforeInsert(const Value: TDataSetNotifyEvent); virtual; abstract;
    procedure _SetBeforeOpen(const Value: TDataSetNotifyEvent); virtual; abstract;
    procedure _SetBeforeClose(const Value: TDataSetNotifyEvent); virtual; abstract;
    procedure _SetBeforePost(const Value: TDataSetNotifyEvent); virtual; abstract;
    procedure _SetBeforeRefresh(const Value: TDataSetNotifyEvent); virtual; abstract;
    procedure _SetBeforeScroll(const Value: TDataSetNotifyEvent); virtual; abstract;
    procedure _SetOnFilterRecord(const Value: TFilterRecordEvent); virtual; abstract;
    procedure _SetOnCalcFields(const Value: TDataSetNotifyEvent); virtual; abstract;
    procedure _SetOnDeleteError(const Value: TDataSetErrorEvent); virtual; abstract;
    procedure _SetOnEditError(const Value: TDataSetErrorEvent); virtual; abstract;
    procedure _SetOnNewRecord(const Value: TDataSetNotifyEvent); virtual; abstract;
    procedure _SetOnPostError(const Value: TDataSetErrorEvent); virtual; abstract;
    // Concrete class methods implementation
    procedure _SetCommandText(const ACommandText: String); virtual;
    function _GetCommandText: String; virtual;
    procedure _SetUniDirectional(const Value: Boolean); virtual;
    procedure _SetReadOnly(const Value: Boolean); virtual;
    procedure _SetCachedUpdates(const Value: Boolean); virtual;
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
    procedure ClearFields; virtual; abstract;
    procedure GotoBookmark(Bookmark: TBookmark); virtual; abstract;
    procedure FreeBookmark(Bookmark: TBookmark); virtual; abstract;
    function Locate(const KeyFields: String; const KeyValues: Variant;
      Options: TLocateOptions): Boolean; virtual; abstract;
    function Lookup(const KeyFields: String; const KeyValues: Variant;
      const ResultFields: String): Variant; virtual; abstract;
    function GetBookmark: TBookmark; virtual; abstract;
    function FieldCount: UInt16; virtual; abstract;
    function State: TDataSetState; virtual; abstract;
    function Modified: Boolean; virtual; abstract;
    function NotEof: Boolean; virtual; abstract;
    function GetFieldValue(const AFieldName: String): Variant; overload; virtual; abstract;
    function GetFieldValue(const AFieldIndex: UInt16): Variant; overload; virtual; abstract;
    function GetFieldType(const AFieldName: String): TFieldType; overload; virtual; abstract;
    function GetField(const AFieldName: String): TField; virtual; abstract;
    function FieldByName(const AFieldName: String): TAsField; virtual;
    function RecordCount: UInt32; virtual;
    function FieldDefs: TFieldDefs; virtual; abstract;
    function AggFields: TFields; virtual; abstract;
    function UpdateStatus: TUpdateStatus; virtual; abstract;
    function CanModify: Boolean; virtual; abstract;
    function IsEmpty: Boolean; virtual; abstract;
    function DataSource: TDataSource; virtual; abstract;
    function DataSet: TDataSet; virtual; abstract;
    // Concrete class methods implementation
    procedure ApplyUpdates; virtual;
    procedure CancelUpdates; virtual;
    function IsUniDirectional: Boolean; virtual;
    function IsReadOnly: Boolean; virtual;
    function IsCachedUpdates: Boolean; virtual;
    function RowsAffected: UInt32; virtual;
  end;

  TDriverResultSet<T: TDataSet> = class abstract(TDriverResultSetBase)
  protected
    FDataSet: T;
    procedure _SetMonitorLog(const ASQL: String; ATransactionName: String; AParams: TParams);
    function _GetFilter: String; override;
    function _GetFiltered: Boolean; override;
    function _GetFilterOptions: TFilterOptions; override;
    function _GetActive: Boolean; override;
    procedure _SetFilter(const Value: String); override;
    procedure _SetFiltered(const Value: Boolean); override;
    procedure _SetFilterOptions(Value: TFilterOptions); override;
    procedure _SetActive(const Value: Boolean); override;
  protected
    function _GetAfterCancel: TDataSetNotifyEvent; override;
    function _GetAfterClose: TDataSetNotifyEvent; override;
    function _GetAfterDelete: TDataSetNotifyEvent; override;
    function _GetAfterEdit: TDataSetNotifyEvent; override;
    function _GetAfterInsert: TDataSetNotifyEvent; override;
    function _GetAfterOpen: TDataSetNotifyEvent; override;
    function _GetAfterPost: TDataSetNotifyEvent; override;
    function _GetAfterRefresh: TDataSetNotifyEvent; override;
    function _GetAfterScroll: TDataSetNotifyEvent; override;
    function _GetAutoCalcFields: Boolean; override;
    function _GetBeforeCancel: TDataSetNotifyEvent; override;
    function _GetBeforeClose: TDataSetNotifyEvent; override;
    function _GetBeforeDelete: TDataSetNotifyEvent; override;
    function _GetBeforeEdit: TDataSetNotifyEvent; override;
    function _GetBeforeInsert: TDataSetNotifyEvent; override;
    function _GetBeforeOpen: TDataSetNotifyEvent; override;
    function _GetBeforePost: TDataSetNotifyEvent; override;
    function _GetBeforeRefresh: TDataSetNotifyEvent; override;
    function _GetBeforeScroll: TDataSetNotifyEvent; override;
    function _GetOnCalcFields: TDataSetNotifyEvent; override;
    function _GetOnDeleteError: TDataSetErrorEvent; override;
    function _GetOnEditError: TDataSetErrorEvent; override;
    function _GetOnFilterRecord: TFilterRecordEvent; override;
    function _GetOnNewRecord: TDataSetNotifyEvent; override;
    function _GetOnPostError: TDataSetErrorEvent; override;
    procedure _SetAfterCancel(const Value: TDataSetNotifyEvent); override;
    procedure _SetAfterOpen(const Value: TDataSetNotifyEvent); override;
    procedure _SetAfterClose(const Value: TDataSetNotifyEvent); override;
    procedure _SetAfterDelete(const Value: TDataSetNotifyEvent); override;
    procedure _SetAfterEdit(const Value: TDataSetNotifyEvent); override;
    procedure _SetAfterInsert(const Value: TDataSetNotifyEvent); override;
    procedure _SetAfterPost(const Value: TDataSetNotifyEvent); override;
    procedure _SetAfterRefresh(const Value: TDataSetNotifyEvent); override;
    procedure _SetAfterScroll(const Value: TDataSetNotifyEvent); override;
    procedure _SetAutoCalcFields(const Value: Boolean); override;
    procedure _SetBeforeCancel(const Value: TDataSetNotifyEvent); override;
    procedure _SetBeforeDelete(const Value: TDataSetNotifyEvent); override;
    procedure _SetBeforeEdit(const Value: TDataSetNotifyEvent); override;
    procedure _SetBeforeInsert(const Value: TDataSetNotifyEvent); override;
    procedure _SetBeforeOpen(const Value: TDataSetNotifyEvent); override;
    procedure _SetBeforeClose(const Value: TDataSetNotifyEvent); override;
    procedure _SetBeforePost(const Value: TDataSetNotifyEvent); override;
    procedure _SetBeforeRefresh(const Value: TDataSetNotifyEvent); override;
    procedure _SetBeforeScroll(const Value: TDataSetNotifyEvent); override;
    procedure _SetOnFilterRecord(const Value: TFilterRecordEvent); override;
    procedure _SetOnCalcFields(const Value: TDataSetNotifyEvent); override;
    procedure _SetOnDeleteError(const Value: TDataSetErrorEvent); override;
    procedure _SetOnEditError(const Value: TDataSetErrorEvent); override;
    procedure _SetOnNewRecord(const Value: TDataSetNotifyEvent); override;
    procedure _SetOnPostError(const Value: TDataSetErrorEvent); override;
  public
    constructor Create(const ADataSet: T; const AMonitor: ICommandMonitor;
      const AMonitorCallback: TMonitorProc); overload; virtual;
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
    procedure ClearFields; override;
    procedure GotoBookmark(Bookmark: TBookmark); override;
    procedure FreeBookmark(Bookmark: TBookmark); override;
    function Locate(const KeyFields: String; const KeyValues: Variant;
      Options: TLocateOptions): Boolean; override;
    function Lookup(const KeyFields: String; const KeyValues: Variant;
      const ResultFields: String): Variant; override;
    function IsEmpty: Boolean; override;
    function GetBookmark: TBookmark; override;
    function FieldCount: UInt16; override;
    function State: TDataSetState; override;
    function Modified: Boolean; override;
    function FieldDefs: TFieldDefs; override;
    function AggFields: TFields; override;
    function UpdateStatus: TUpdateStatus; override;
    function CanModify: Boolean; override;
    function DataSource: TDataSource; override;
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
    function AsBlobPtr(out iNumBytes: UIntPtr): Pointer; override;
    function AsBlobText: String; override;
    function AsBlobTextDef(const Def: String = ''): String; override;
    function AsDateTime: TDateTime; override;
    function AsDateTimeDef(const Def: TDateTime = 0.0): TDateTime; override;
    function AsDouble: Double; override;
    function AsDoubleDef(const Def: Double = 0.0): Double; override;
    function AsInteger: UInt64; override;
    function AsIntegerDef(const Def: UInt64 = 0): UInt64; override;
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

constructor TDriverResultSet<T>.Create(const ADataSet: T; const AMonitor: ICommandMonitor;
      const AMonitorCallback: TMonitorProc);
begin
  FCommandMonitor := AMonitor;
  FMonitorCallback := AMonitorCallback;
  FDataSet := ADataSet;
  inherited Create;
  // Stores the RecordCount of the last SELECT executed in the IDBResultSet.
  try FRecordCount := FDataSet.RecordCount; except end;
end;

function TDriverResultSet<T>.DataSet: TDataSet;
begin
  Result := FDataSet;
end;

function TDriverResultSet<T>.DataSource: TDataSource;
begin
  Result := FDataSet.DataSource;
end;

function TDriverResultSet<T>.AggFields: TFields;
begin
  Result := FDataSet.AggFields;
end;

procedure TDriverResultSet<T>.Append;
begin
  FDataSet.Append;
end;

procedure TDriverResultSet<T>.Cancel;
begin
  FDataSet.Cancel;
end;

function TDriverResultSet<T>.CanModify: Boolean;
begin
  Result := FDataSet.CanModify;
end;

procedure TDriverResultSet<T>.Delete;
begin
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
  if FDataSet.IsEmpty then
    Exit;
  FDataSet.DisableControls;
  try
    FDataSet.First;
    while not FDataSet.Eof do
      FDataSet.Delete;
  finally
    FDataSet.EnableControls;
  end;
end;

procedure TDriverResultSet<T>.ClearFields;
begin
  FDataSet.ClearFields;
end;

procedure TDriverResultSet<T>.Close;
begin
  _GetCommandText;
  FDataSet.Close;
end;

function TDriverResultSet<T>.FieldCount: UInt16;
begin
  Result := FDataSet.FieldCount;
end;

function TDriverResultSet<T>.FieldDefs: TFieldDefs;
begin
  Result := FDataSet.FieldDefs;
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

procedure TDriverResultSet<T>.GotoBookmark(Bookmark: TBookmark);
begin
  FDataSet.GotoBookmark(Bookmark);
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

function TDriverResultSet<T>.Locate(const KeyFields: String;
  const KeyValues: Variant; Options: TLocateOptions): Boolean;
begin
  Result := FDataSet.Locate(KeyFields, KeyValues, Options);
end;

function TDriverResultSet<T>.Lookup(const KeyFields: String;
  const KeyValues: Variant; const ResultFields: String): Variant;
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

function TDriverResultSet<T>.UpdateStatus: TUpdateStatus;
begin
  Result := FDataSet.UpdateStatus;
end;

function TDriverResultSet<T>._GetActive: Boolean;
begin
  Result := FDataSet.Active;
end;

function TDriverResultSet<T>._GetAfterCancel: TDataSetNotifyEvent;
begin
  Result := FDataSet.AfterCancel;
end;

function TDriverResultSet<T>._GetAfterClose: TDataSetNotifyEvent;
begin
  Result := FDataSet.AfterClose;
end;

function TDriverResultSet<T>._GetAfterDelete: TDataSetNotifyEvent;
begin
  Result := FDataSet.AfterDelete;
end;

function TDriverResultSet<T>._GetAfterEdit: TDataSetNotifyEvent;
begin
  Result := FDataSet.AfterEdit;
end;

function TDriverResultSet<T>._GetAfterInsert: TDataSetNotifyEvent;
begin
  Result := FDataSet.AfterInsert;
end;

function TDriverResultSet<T>._GetAfterOpen: TDataSetNotifyEvent;
begin
  Result := FDataSet.AfterOpen;
end;

function TDriverResultSet<T>._GetAfterPost: TDataSetNotifyEvent;
begin
  Result := FDataSet.AfterPost;
end;

function TDriverResultSet<T>._GetAfterRefresh: TDataSetNotifyEvent;
begin
  Result := FDataSet.AfterRefresh;
end;

function TDriverResultSet<T>._GetAfterScroll: TDataSetNotifyEvent;
begin
  Result := FDataSet.AfterScroll;
end;

function TDriverResultSet<T>._GetAutoCalcFields: Boolean;
begin
  Result := FDataSet.AutoCalcFields;
end;

function TDriverResultSet<T>._GetBeforeCancel: TDataSetNotifyEvent;
begin
  Result := FDataSet.BeforeCancel;
end;

function TDriverResultSet<T>._GetBeforeClose: TDataSetNotifyEvent;
begin
  Result := FDataSet.BeforeClose;
end;

function TDriverResultSet<T>._GetBeforeDelete: TDataSetNotifyEvent;
begin
  Result := FDataSet.BeforeDelete;
end;

function TDriverResultSet<T>._GetBeforeEdit: TDataSetNotifyEvent;
begin
  Result := FDataSet.BeforeEdit;
end;

function TDriverResultSet<T>._GetBeforeInsert: TDataSetNotifyEvent;
begin
  Result := FDataSet.BeforeInsert;
end;

function TDriverResultSet<T>._GetBeforeOpen: TDataSetNotifyEvent;
begin
  Result := FDataSet.BeforeOpen;
end;

function TDriverResultSet<T>._GetBeforePost: TDataSetNotifyEvent;
begin
  Result := FDataSet.BeforePost;
end;

function TDriverResultSet<T>._GetBeforeRefresh: TDataSetNotifyEvent;
begin
  Result := FDataSet.BeforeRefresh;
end;

function TDriverResultSet<T>._GetBeforeScroll: TDataSetNotifyEvent;
begin
  Result := FDataSet.BeforeScroll;
end;

function TDriverResultSet<T>._GetFilter: String;
begin
  Result := FDataSet.Filter;
end;

function TDriverResultSet<T>._GetFiltered: Boolean;
begin
  Result := FDataSet.Filtered;
end;

function TDriverResultSet<T>._GetFilterOptions: TFilterOptions;
begin
  Result := FDataSet.FilterOptions;
end;

function TDriverResultSet<T>._GetOnCalcFields: TDataSetNotifyEvent;
begin
  Result := FDataSet.OnCalcFields;
end;

function TDriverResultSet<T>._GetOnDeleteError: TDataSetErrorEvent;
begin
  Result := FDataSet.OnDeleteError;
end;

function TDriverResultSet<T>._GetOnEditError: TDataSetErrorEvent;
begin
  Result := FDataSet.OnEditError;
end;

function TDriverResultSet<T>._GetOnFilterRecord: TFilterRecordEvent;
begin
  Result := FDataSet.OnFilterRecord;
end;

function TDriverResultSet<T>._GetOnNewRecord: TDataSetNotifyEvent;
begin
  Result := FDataSet.OnNewRecord;
end;

function TDriverResultSet<T>._GetOnPostError: TDataSetErrorEvent;
begin
  Result := FDataSet.OnPostError;
end;

procedure TDriverResultSet<T>._SetActive(const Value: Boolean);
begin
  FDataSet.Active := Value;
end;

procedure TDriverResultSet<T>._SetAfterCancel(const Value: TDataSetNotifyEvent);
begin
  FDataSet.AfterCancel := Value;
end;

procedure TDriverResultSet<T>._SetAfterClose(const Value: TDataSetNotifyEvent);
begin
  FDataSet.AfterClose := Value;
end;

procedure TDriverResultSet<T>._SetAfterDelete(const Value: TDataSetNotifyEvent);
begin
  FDataSet.AfterDelete := Value;
end;

procedure TDriverResultSet<T>._SetAfterEdit(const Value: TDataSetNotifyEvent);
begin
  FDataSet.AfterEdit := Value;
end;

procedure TDriverResultSet<T>._SetAfterInsert(const Value: TDataSetNotifyEvent);
begin
  FDataSet.AfterInsert := Value;
end;

procedure TDriverResultSet<T>._SetAfterOpen(const Value: TDataSetNotifyEvent);
begin
  FDataSet.AfterOpen := Value;
end;

procedure TDriverResultSet<T>._SetAfterPost(const Value: TDataSetNotifyEvent);
begin
  FDataSet.AfterPost := Value;
end;

procedure TDriverResultSet<T>._SetAfterRefresh(const Value: TDataSetNotifyEvent);
begin
  FDataSet.AfterRefresh := Value;
end;

procedure TDriverResultSet<T>._SetAfterScroll(const Value: TDataSetNotifyEvent);
begin
  FDataSet.AfterScroll := Value;
end;

procedure TDriverResultSet<T>._SetAutoCalcFields(const Value: Boolean);
begin
  FDataSet.AutoCalcFields := Value;
end;

procedure TDriverResultSet<T>._SetBeforeCancel(
  const Value: TDataSetNotifyEvent);
begin
  FDataSet.BeforeCancel := Value;
end;

procedure TDriverResultSet<T>._SetBeforeClose(const Value: TDataSetNotifyEvent);
begin
  FDataSet.BeforeClose := Value;
end;

procedure TDriverResultSet<T>._SetBeforeDelete(
  const Value: TDataSetNotifyEvent);
begin
  FDataSet.BeforeDelete := Value;
end;

procedure TDriverResultSet<T>._SetBeforeEdit(const Value: TDataSetNotifyEvent);
begin
  FDataSet.BeforeEdit := Value;
end;

procedure TDriverResultSet<T>._SetBeforeInsert(
  const Value: TDataSetNotifyEvent);
begin
  FDataSet.BeforeInsert := Value;
end;

procedure TDriverResultSet<T>._SetBeforeOpen(const Value: TDataSetNotifyEvent);
begin
  FDataSet.BeforeOpen := Value;
end;

procedure TDriverResultSet<T>._SetBeforePost(const Value: TDataSetNotifyEvent);
begin
  FDataSet.BeforePost := Value;
end;

procedure TDriverResultSet<T>._SetBeforeRefresh(
  const Value: TDataSetNotifyEvent);
begin
  FDataSet.BeforeRefresh := Value;
end;

procedure TDriverResultSet<T>._SetBeforeScroll(
  const Value: TDataSetNotifyEvent);
begin
  FDataSet.BeforeScroll := Value;
end;

procedure TDriverResultSet<T>._SetOnFilterRecord(
  const Value: TFilterRecordEvent);
begin
  FDataSet.OnFilterRecord := Value;
end;

procedure TDriverResultSet<T>._SetFilter(const Value: String);
begin
  FDataSet.Filter := Value;
end;

procedure TDriverResultSet<T>._SetFiltered(const Value: Boolean);
begin
  FDataSet.Filtered := Value;
end;

procedure TDriverResultSet<T>._SetFilterOptions(Value: TFilterOptions);
begin
  FDataSet.FilterOptions := Value;
end;

procedure TDriverResultSet<T>._SetMonitorLog(const ASQL: String; ATransactionName: String;
  AParams: TParams);
begin
  if Assigned(FCommandMonitor) then
    FCommandMonitor.Command('[Transaction: ' + ATransactionName + '] - ' + TrimRight(ASQL), AParams);
  if Assigned(FMonitorCallback) then
    FMonitorCallback(TMonitorParam.Create('[Transaction: ' + ATransactionName + '] - ' + TrimRight(ASQL), AParams));
end;

procedure TDriverResultSet<T>._SetOnCalcFields(
  const Value: TDataSetNotifyEvent);
begin
  FDataSet.OnCalcFields := Value;
end;

procedure TDriverResultSet<T>._SetOnDeleteError(
  const Value: TDataSetErrorEvent);
begin
  FDataSet.OnDeleteError := Value;
end;

procedure TDriverResultSet<T>._SetOnEditError(const Value: TDataSetErrorEvent);
begin
  FDataSet.OnEditError := Value;
end;

procedure TDriverResultSet<T>._SetOnNewRecord(const Value: TDataSetNotifyEvent);
begin
  FDataSet.OnNewRecord := Value;
end;

procedure TDriverResultSet<T>._SetOnPostError(const Value: TDataSetErrorEvent);
begin
  FDataSet.OnPostError := Value;
end;

{ TDriverResultSetBase }

function TDriverResultSetBase.RecordCount: UInt32;
begin
  Result := FRecordCount;
end;

function TDriverResultSetBase.RowsAffected: UInt32;
begin
  raise EAbstractError.Create('The RowsAffected() method must be implemented in the concrete class.');
end;

function TDriverResultSetBase._GetCommandText: String;
begin
  raise EAbstractError.Create('The _GetCommandText() method must be implemented in the concrete class.');
end;

function TDriverResultSetBase._GetFetchingAll: Boolean;
begin
  Result := FFetchingAll;
end;

procedure TDriverResultSetBase._SetCachedUpdates(const Value: Boolean);
begin
  raise EAbstractError.Create('The _SetCachedUpdates() method must be implemented in the concrete class.');
end;

procedure TDriverResultSetBase._SetCommandText(const ACommandText: String);
begin
  raise EAbstractError.Create('The _SetCommandText() method must be implemented in the concrete class.');
end;

procedure TDriverResultSetBase._SetFetchingAll(const Value: Boolean);
begin
  FFetchingAll := Value;
end;

procedure TDriverResultSetBase._SetReadOnly(const Value: Boolean);
begin
  raise EAbstractError.Create('The _SetReadOnly() method must be implemented in the concrete class.');
end;

procedure TDriverResultSetBase._SetUniDirectional(const Value: Boolean);
begin
  raise EAbstractError.Create('The _SetUniDirectional() method must be implemented in the concrete class.');
end;

procedure TDriverResultSetBase.ApplyUpdates;
begin
  raise EAbstractError.Create('The ApplyUpdates() method must be implemented in the concrete class.');
end;

procedure TDriverResultSetBase.CancelUpdates;
begin
  raise EAbstractError.Create('The CancelUpdates() method must be implemented in the concrete class.');
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

function TDriverResultSetBase.IsCachedUpdates: Boolean;
begin
  raise EAbstractError.Create('The IsCachedUpdates() method must be implemented in the concrete class.');
end;

function TDriverResultSetBase.IsReadOnly: Boolean;
begin
  raise EAbstractError.Create('The IsReadOnly() method must be implemented in the concrete class.');
end;

function TDriverResultSetBase.IsUniDirectional: Boolean;
begin
  raise EAbstractError.Create('The IsUniDirectional() method must be implemented in the concrete class.');
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

function TDBEBrField.AsBlobPtr(out iNumBytes: UIntPtr): Pointer;
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

function TDBEBrField.AsInteger: UInt64;
var
  LResult: Variant;
begin
  Result := 0;
  LResult := FOwner.GetFieldValue(FAsFieldName);
  if LResult <> Null then
    Result := LResult;
end;

function TDBEBrField.AsIntegerDef(const Def: UInt64): UInt64;
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

{ TDriverQuery }

function TDriverQuery.RowsAffected: UInt32;
begin
  raise EAbstractError.Create('The RowsAffected() method must be implemented in the concrete class.');
end;

function TDriverQuery._GetCommandText: String;
begin
  raise EAbstractError.Create('The _GetCommandText() method must be implemented in the concrete class.');
end;

procedure TDriverQuery._SetCommandText(const ACommandText: String);
begin
  raise EAbstractError.Create('The _SetCommandText() method must be implemented in the concrete class.');
end;

procedure TDriverQuery._SetMonitorLog(const ASQL, ATransactionName: String; const AParams: TParams);
begin
  if Assigned(FCommandMonitor) then
    FCommandMonitor.Command('[Transaction: ' + ATransactionName + '] - ' + TrimRight(ASQL), AParams);
  if Assigned(FMonitorCallback) then
    FMonitorCallback(TMonitorParam.Create('[Transaction: ' + ATransactionName + '] - ' + TrimRight(ASQL), AParams));
end;

{ TDriverConnection }

procedure TDriverConnection.ApplyUpdates(const ADataSets: array of IDBResultSet);
begin
  raise EAbstractError.Create('The ApplyUpdates() method must be implemented in the concrete class.');
end;

function TDriverConnection.GetDriverName: TDriverName;
begin
  Result := FDriverName;
end;

function TDriverConnection.GetSQLScripts: String;
begin
  raise EAbstractError.Create('The GetSQLScripts() method must be implemented in the concrete class.');
end;

function TDriverConnection.RowsAffected: UInt32;
begin
  Result := FRowsAffected;
end;

procedure TDriverConnection._SetMonitorLog(const ASQL, ATransactionName: String;
  const AParams: TParams);
begin
  if Assigned(FCommandMonitor) then
    FCommandMonitor.Command('[Transaction: ' + ATransactionName + '] - ' + TrimRight(ASQL), AParams);
  if Assigned(FMonitorCallback) then
    FMonitorCallback(TMonitorParam.Create('[Transaction: ' + ATransactionName + '] - ' + TrimRight(ASQL), AParams));
end;

{ TDriverTransaction }

procedure TDriverTransaction.AddTransaction(const AKey: String;
  const ATransaction: TComponent);
var
  LKeyUC: String;
begin
  LKeyUC := UpperCase(AKey);
  if FTransactionList.ContainsKey(LKeyUC) then
    raise Exception.Create('Transaction with the same name already exists.');
  if ATransaction.Name = EmptyStr then
    ATransaction.Name := AKey;
  FTransactionList.Add(LKeyUC, ATransaction);
end;

function TDriverTransaction.TransactionActive: TComponent;
begin
  Result := FTransactionActive;
end;

procedure TDriverTransaction.UseTransaction(const AKey: String);
var
  LKeyUC: String;
begin
  LKeyUC := UpperCase(AKey);
  if not FTransactionList.TryGetValue(LKeyUC, FTransactionActive) then
    raise Exception.Create('Transaction not found.');
end;

function TDriverTransaction._GetTransaction(const AKey: String): TComponent;
var
  LKeyUC: String;
begin
  LKeyUC := UpperCase(AKey);
  if not FTransactionList.TryGetValue(LKeyUC, Result) then
    raise Exception.Create('Transaction not found.');
end;

end.
