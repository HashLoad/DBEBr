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
  @abstract(ORMBr Framework.)
  @created(20 Jul 2016)
  @author(Isaque Pinheiro <https://www.isaquepinheiro.com.br>)
}

unit dbebr.factory.interfaces;

interface

uses
  DB,
  Classes,
  SysUtils,
  Variants;

type
  TMonitorParam = record
    Command: String;
    Params: TParams;
    constructor Create(const ACommand: String; AParams: TParams);
  end;

  TMonitorProc = reference to procedure(const AMonitorCommand: TMonitorParam);

//  {$SCOPEDENUMS ON}
  TDriverName = (dnMSSQL, dnMySQL, dnFirebird, dnSQLite, dnInterbase, dnDB2,
                 dnOracle, dnInformix, dnPostgreSQL, dnADS, dnASA,
                 dnFirebase, dnFirebird3, dnAbsoluteDB, dnMongoDB,
                 dnElevateDB, dnNexusDB, dnMariaDB);
//  {$SCOPEDENUMS OFF}

  TAsField = class abstract
  protected
    FAsFieldName: String;
  public
    function IsNull: Boolean; virtual; abstract;
    function AsBlob: TMemoryStream; virtual; abstract;
    function AsBlobPtr(out iNumBytes: UIntPtr): Pointer; virtual; abstract;
    function AsBlobText: String; virtual; abstract;
    function AsBlobTextDef(const Def: String = ''): String; virtual; abstract;
    function AsDateTime: TDateTime; virtual; abstract;
    function AsDateTimeDef(const Def: TDateTime = 0.0): TDateTime; virtual; abstract;
    function AsDouble: Double; virtual; abstract;
    function AsDoubleDef(const Def: Double = 0.0): Double; virtual; abstract;
    function AsInteger: UInt64; virtual; abstract;
    function AsIntegerDef(const Def: UInt64 = 0): UInt64; virtual; abstract;
    function AsString: String; virtual; abstract;
    function AsStringDef(const Def: String = ''): String; virtual; abstract;
    function AsFloat: Double; virtual; abstract;
    function AsFloatDef(const Def: Double = 0): Double; virtual; abstract;
    function AsCurrency: Currency; virtual; abstract;
    function AsCurrencyDef(const Def: Currency = 0): Currency; virtual; abstract;
    function AsExtended: Extended; virtual; abstract;
    function AsExtendedDef(const Def: Extended = 0): Extended; virtual; abstract;
    function AsVariant: Variant; virtual; abstract;
    function AsVariantDef(const Def: Variant): Variant; virtual; abstract;
    function AsBoolean: Boolean; virtual; abstract;
    function AsBooleanDef(const Def: Boolean = False): Boolean; virtual; abstract;
    function Value: Variant; virtual; abstract;
    function ValueDef(const Def: Variant): Variant; virtual; abstract;
    property AsFieldName: String read FAsFieldName write FAsFieldName;
  end;

  IDBResultSet = interface
    ['{A8ECADF6-A9AF-4610-8429-3B0A5CD0295C}']
    function _GetFetchingAll: Boolean;
    function _GetFilter: String;
    function _GetFiltered: Boolean;
    function _GetFilterOptions: TFilterOptions;
    function _GetActive: Boolean;
    function _GetCommandText: String;
    function _GetAfterCancel: TDataSetNotifyEvent;
    function _GetAfterClose: TDataSetNotifyEvent;
    function _GetAfterDelete: TDataSetNotifyEvent;
    function _GetAfterEdit: TDataSetNotifyEvent;
    function _GetAfterInsert: TDataSetNotifyEvent;
    function _GetAfterOpen: TDataSetNotifyEvent;
    function _GetAfterPost: TDataSetNotifyEvent;
    function _GetAfterRefresh: TDataSetNotifyEvent;
    function _GetAfterScroll: TDataSetNotifyEvent;
    function _GetAutoCalcFields: Boolean;
    function _GetBeforeCancel: TDataSetNotifyEvent;
    function _GetBeforeClose: TDataSetNotifyEvent;
    function _GetBeforeDelete: TDataSetNotifyEvent;
    function _GetBeforeEdit: TDataSetNotifyEvent;
    function _GetBeforeInsert: TDataSetNotifyEvent;
    function _GetBeforeOpen: TDataSetNotifyEvent;
    function _GetBeforePost: TDataSetNotifyEvent;
    function _GetBeforeRefresh: TDataSetNotifyEvent;
    function _GetBeforeScroll: TDataSetNotifyEvent;
    function _GetOnCalcFields: TDataSetNotifyEvent;
    function _GetOnDeleteError: TDataSetErrorEvent;
    function _GetOnEditError: TDataSetErrorEvent;
    function _GetOnFilterRecord: TFilterRecordEvent;
    function _GetOnNewRecord: TDataSetNotifyEvent;
    function _GetOnPostError: TDataSetErrorEvent;
    procedure _SetFetchingAll(const Value: Boolean);
    procedure _SetFilter(const Value: String);
    procedure _SetFiltered(const Value: Boolean);
    procedure _SetFilterOptions(Value: TFilterOptions);
    procedure _SetActive(const Value: Boolean);
    procedure _SetCommandText(const ACommandText: String);
    procedure _SetUniDirectional(const Value: Boolean);
    procedure _SetReadOnly(const Value: Boolean);
    procedure _SetCachedUpdates(const Value: Boolean);
    procedure _SetAfterCancel(const Value: TDataSetNotifyEvent);
    procedure _SetAfterOpen(const Value: TDataSetNotifyEvent);
    procedure _SetAfterClose(const Value: TDataSetNotifyEvent);
    procedure _SetAfterDelete(const Value: TDataSetNotifyEvent);
    procedure _SetAfterEdit(const Value: TDataSetNotifyEvent);
    procedure _SetAfterInsert(const Value: TDataSetNotifyEvent);
    procedure _SetAfterPost(const Value: TDataSetNotifyEvent);
    procedure _SetAfterRefresh(const Value: TDataSetNotifyEvent);
    procedure _SetAfterScroll(const Value: TDataSetNotifyEvent);
    procedure _SetAutoCalcFields(const Value: Boolean);
    procedure _SetBeforeCancel(const Value: TDataSetNotifyEvent);
    procedure _SetBeforeDelete(const Value: TDataSetNotifyEvent);
    procedure _SetBeforeEdit(const Value: TDataSetNotifyEvent);
    procedure _SetBeforeInsert(const Value: TDataSetNotifyEvent);
    procedure _SetBeforeOpen(const Value: TDataSetNotifyEvent);
    procedure _SetBeforeClose(const Value: TDataSetNotifyEvent);
    procedure _SetBeforePost(const Value: TDataSetNotifyEvent);
    procedure _SetBeforeRefresh(const Value: TDataSetNotifyEvent);
    procedure _SetBeforeScroll(const Value: TDataSetNotifyEvent);
    procedure _SetOnFilterRecord(const Value: TFilterRecordEvent);
    procedure _SetOnCalcFields(const Value: TDataSetNotifyEvent);
    procedure _SetOnDeleteError(const Value: TDataSetErrorEvent);
    procedure _SetOnEditError(const Value: TDataSetErrorEvent);
    procedure _SetOnNewRecord(const Value: TDataSetNotifyEvent);
    procedure _SetOnPostError(const Value: TDataSetErrorEvent);
    procedure Close;
    procedure Open;
    procedure Delete;
    procedure Cancel;
    procedure Clear;
    procedure DisableControls;
    procedure EnableControls;
    procedure Next;
    procedure Prior;
    procedure Append;
    procedure Insert;
    procedure Edit;
    procedure Post;
    procedure First;
    procedure Last;
    procedure FreeBookmark(Bookmark: TBookmark);
    procedure ClearFields;
    procedure ApplyUpdates;
    procedure CancelUpdates;
    function Locate(const KeyFields: String; const KeyValues: Variant;
      Options: TLocateOptions): Boolean;
    function Lookup(const KeyFields: String; const KeyValues: Variant;
      const ResultFields: String): Variant;
    function GetBookmark: TBookmark;
    function FieldCount: UInt16;
    function State: TDataSetState;
    function NotEof: Boolean;
    function RecordCount: UInt32;
    function RowsAffected: UInt32;
    function FieldDefs: TFieldDefs;
    function Modified: Boolean;
    function GetFieldValue(const AFieldName: String): Variant; overload;
    function GetFieldValue(const AFieldIndex: UInt16): Variant; overload;
    function GetField(const AFieldName: String): TField;
    function GetFieldType(const AFieldName: String): TFieldType;
    function FieldByName(const AFieldName: String): TAsField;
    function AggFields: TFields;
    function UpdateStatus: TUpdateStatus;
    function CanModify: Boolean;
    function IsEmpty: Boolean;
    function IsUniDirectional: Boolean;
    function IsReadOnly: Boolean;
    function IsCachedUpdates: Boolean;
    function DataSource: TDataSource;
    {$MESSAGE WARN 'Instead, use the direct methods. IDBResultSet.Insert, IDBResultSet.Post, IDBResultSet.etc...'}
    function DataSet: TDataSet;
    // Propertys
    property FetchingAll: Boolean read _GetFetchingAll write _SetFetchingAll;
    property Filter: String read _GetFilter write _SetFilter;
    property FilterOptions: TFilterOptions read _GetFilterOptions write _SetFilterOptions;
    property Filtered: Boolean read _GetFiltered write _SetFiltered;
    property Active: Boolean read _GetActive write _SetActive;
    property CommandText: String read _GetCommandText write _SetCommandText;
    property UniDirectional: Boolean write _SetUniDirectional;
    property ReadOnly: Boolean write _SetReadOnly;
    property CachedUpdates: Boolean write _SetCachedUpdates;
    property AutoCalcFields: Boolean read _GetAutoCalcFields write _SetAutoCalcFields;
    property BeforeOpen: TDataSetNotifyEvent read _GetBeforeOpen write _SetBeforeOpen;
    property AfterOpen: TDataSetNotifyEvent read _GetAfterOpen write _SetAfterOpen;
    property BeforeClose: TDataSetNotifyEvent read _GetBeforeClose write _SetBeforeClose;
    property AfterClose: TDataSetNotifyEvent read _GetAfterClose write _SetAfterClose;
    property BeforeInsert: TDataSetNotifyEvent read _GetBeforeInsert write _SetBeforeInsert;
    property AfterInsert: TDataSetNotifyEvent read _GetAfterInsert write _SetAfterInsert;
    property BeforeEdit: TDataSetNotifyEvent read _GetBeforeEdit write _SetBeforeEdit;
    property AfterEdit: TDataSetNotifyEvent read _GetAfterEdit write _SetAfterEdit;
    property BeforePost: TDataSetNotifyEvent read _GetBeforePost write _SetBeforePost;
    property AfterPost: TDataSetNotifyEvent read _GetAfterPost write _SetAfterPost;
    property BeforeCancel: TDataSetNotifyEvent read _GetBeforeCancel write _SetBeforeCancel;
    property AfterCancel: TDataSetNotifyEvent read _GetAfterCancel write _SetAfterCancel;
    property BeforeDelete: TDataSetNotifyEvent read _GetBeforeDelete write _SetBeforeDelete;
    property AfterDelete: TDataSetNotifyEvent read _GetAfterDelete write _SetAfterDelete;
    property BeforeScroll: TDataSetNotifyEvent read _GetBeforeScroll write _SetBeforeScroll;
    property AfterScroll: TDataSetNotifyEvent read _GetAfterScroll write _SetAfterScroll;
    property BeforeRefresh: TDataSetNotifyEvent read _GetBeforeRefresh write _SetBeforeRefresh;
    property AfterRefresh: TDataSetNotifyEvent read _GetAfterRefresh write _SetAfterRefresh;
    property OnCalcFields: TDataSetNotifyEvent read _GetOnCalcFields write _SetOnCalcFields;
    property OnDeleteError: TDataSetErrorEvent read _GetOnDeleteError write _SetOnDeleteError;
    property OnEditError: TDataSetErrorEvent read _GetOnEditError write _SetOnEditError;
    property OnFilterRecord: TFilterRecordEvent read _GetOnFilterRecord write _SetOnFilterRecord;
    property OnNewRecord: TDataSetNotifyEvent read _GetOnNewRecord write _SetOnNewRecord;
    property OnPostError: TDataSetErrorEvent read _GetOnPostError write _SetOnPostError;
  end;

  IDBQuery = interface
    ['{0588C65B-2571-48BB-BE03-BD51ABB6897F}']
    procedure _SetCommandText(const ACommandText: String);
    function _GetCommandText: String;
    procedure ExecuteDirect;
    function ExecuteQuery: IDBResultSet;
    function RowsAffected: UInt32;
    property CommandText: String read _GetCommandText write _SetCommandText;
  end;

  ICommandMonitor = interface
    ['{9AEB5A47-0205-4648-8C8A-F9DA8D88EB64}']
    procedure Command(const ASQL: String; AParams: TParams);
    procedure Show;
  end;

  IOptions = interface
    ['{A3C489B1-F2D8-4E4D-9EC2-152C730ED33D}']
    function StoreGUIDAsOctet(const AValue: Boolean): IOptions; overload;
    function StoreGUIDAsOctet: Boolean; overload;
  end;

  IDBTransaction = interface
    ['{EB46599C-A021-40E4-94E2-C7507781562B}']
    function _GetTransaction(const AKey: String): TComponent;
    procedure StartTransaction;
    procedure Commit;
    procedure Rollback;
    procedure AddTransaction(const AKey: String; const ATransaction: TComponent);
    procedure UseTransaction(const AKey: String);
    function TransactionActive: TComponent;
    function InTransaction: Boolean;
    property Transaction[const AKey: String]: TComponent read _GetTransaction;
  end;

  IDBConnection = interface(IDBTransaction)
    ['{4520C97F-8777-4D14-9C14-C79EF86957DB}']
    procedure Connect;
    procedure Disconnect;
    procedure ExecuteDirect(const ASQL: String); overload;
    procedure ExecuteDirect(const ASQL: String; const AParams: TParams); overload;
    procedure ExecuteScript(const AScript: String);
    procedure AddScript(const AScript: String);
    procedure ExecuteScripts;
    procedure SetCommandMonitor(AMonitor: ICommandMonitor);
    procedure ApplyUpdates(const ADataSets: array of IDBResultSet);
    function IsConnected: Boolean;
    function GetDriverName: TDriverName;
    function CreateQuery: IDBQuery;
    function CreateResultSet(const ASQL: String = ''): IDBResultSet;
    function CommandMonitor: ICommandMonitor;
    function MonitorCallback: TMonitorProc;
    function Options: IOptions;
    function RowsAffected: UInt32;
  end;

const
  TStrDriverName: array[TDriverName.dnMSSQL..TDriverName.dnMariaDB] of
                  String = ('MSSQL','MySQL','Firebird','SQLite','Interbase',
                            'DB2','Oracle','Informix','PostgreSQL','ADS','ASA',
                            'dnFirebase', 'dnFirebird3','AbsoluteDB','MongoDB',
                            'ElevateDB','NexusDB','MariaDB');

implementation

{ TMonitorParam }

constructor TMonitorParam.Create(const ACommand: String; AParams: TParams);
begin
  Command := ACommand;
  Params := AParams;
end;

end.
