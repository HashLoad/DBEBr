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
  @abstract(DBEBr Framework.)
  @created(20 Jul 2016)
  @author(Isaque Pinheiro <https://www.isaquepinheiro.com.br>)
}

unit dbebr.dataset.fields;

interface

uses
  DB,
  Rtti,
  Classes,
  SysUtils;

const
  C_INTERNAL_FIELD = 'InternalField';

type
  TFieldHelper = class helper for TField
  public
    function AsType<T: TField>: T;
  end;

  IFieldSingleton = interface
    ['{F61DC5DB-5300-4C83-AF08-35DB9BB298B6}']
    function AddField(const ADataSet: TDataSet;
                      const AFieldName: String;
                      const AFieldType: TFieldType;
                      const APrecision: UInt16 = 0;
                      const ASize: UInt32 = 0): IFieldSingleton;
    function AddCalcField(const ADataSet: TDataSet;
                           const AFieldName: String;
                           const AFieldType: TFieldType;
                           const ASize: Uint32 = 0): IFieldSingleton;
    function AddAggregateField(const ADataSet: TDataSet;
                                const AFieldName, AExpression: String;
                                const AAlignment: TAlignment = taLeftJustify;
                                const ADisplayFormat: String = ''): IFieldSingleton;
    function AddLookupField(const AFieldName: String;
                             const ADataSet: TDataSet;
                             const AKeyFields: String;
                             const ALookupDataSet: TDataSet;
                             const ALookupKeyFields: String;
                             const ALookupResultField: String;
                             const AFieldType: TFieldType;
                             const ASize: UInt32 = 0;
                             const ADisplayLabel: String = ''): IFieldSingleton;
  end;

  TFieldSingleton = class(TInterfacedObject, IFieldSingleton)
  private
    class var
      FInstance: IFieldSingleton;
  private
    function _GetFieldType(const ADataSet: TDataSet; const AFieldType: TFieldType): TField;
  protected
    constructor Create;
  public
    { Public declarations }
    class function Get: IFieldSingleton;
    function AddField(const ADataSet: TDataSet;
                      const AFieldName: String;
                      const AFieldType: TFieldType;
                      const APrecision: UInt16 = 0;
                      const ASize: UInt32 = 0): IFieldSingleton;
    function AddCalcField(const ADataSet: TDataSet;
                           const AFieldName: String;
                           const AFieldType: TFieldType;
                           const ASize: UInt32 = 0): IFieldSingleton;
    function AddAggregateField(const ADataSet: TDataSet;
                                const AFieldName, AExpression: String;
                                const AAlignment: TAlignment = taLeftJustify;
                                const ADisplayFormat: String = ''): IFieldSingleton;
    function AddLookupField(const AFieldName: String;
                             const ADataSet: TDataSet;
                             const AKeyFields: String;
                             const ALookupDataSet: TDataSet;
                             const ALookupKeyFields: String;
                             const ALookupResultField: String;
                             const AFieldType: TFieldType;
                             const ASize: UInt32 = 0;
                             const ADisplayLabel: String = ''): IFieldSingleton;
  end;

implementation

function TFieldSingleton.AddField(const ADataSet: TDataSet;
  const AFieldName: String;
  const AFieldType: TFieldType;
  const APrecision: UInt16 = 0;
  const ASize: UInt32 = 0): IFieldSingleton;
var
  LField: TField;
begin
  if ADataSet = nil then
    raise Exception.Create('The dataset cannot be null.');

  if ADataSet.FindField(AFieldName) <> nil then
    raise Exception.Create('The field: ' + AFieldName + ' already exists in the dataset.');

  LField := _GetFieldType(ADataSet, AFieldType);
  if LField = nil then
    raise Exception.Create('Unsupported field type.');

  LField.Name         := ADataSet.Name + AFieldName;
  LField.FieldName    := AFieldName;
  LField.DisplayLabel := AFieldName;
  LField.Calculated   := False;
  LField.DataSet      := ADataSet;
  LField.FieldKind    := fkData;
  //
  case AFieldType of
    ftBytes, ftVarBytes, ftFixedChar, ftString, ftFixedWideChar, ftWideString:
      begin
        if ASize > 0 then
          LField.Size := ASize;
      end;
    ftFMTBcd:
      begin
        if APrecision > 0 then
          TFMTBCDField(LField).Precision := APrecision;
        if ASize > 0 then
          LField.Size := ASize;
      end;
  end;
  Result := Self;
end;

function TFieldSingleton.AddLookupField(const AFieldName: String;
  const ADataSet: TDataSet;
  const AKeyFields: String;
  const ALookupDataSet: TDataSet;
  const ALookupKeyFields: String;
  const ALookupResultField: String;
  const AFieldType: TFieldType;
  const ASize: UInt32;
  const ADisplayLabel: String): IFieldSingleton;
var
  LField: TField;
begin
  if ADataSet = nil then
    raise Exception.Create('The dataset cannot be null.');

  if ADataSet.FindField(AFieldName) <> nil then
    raise Exception.Create('The field: ' + AFieldName + ' already exists in the dataset.');

  LField := _GetFieldType(ADataSet, AFieldType);
  if LField = nil then
    raise Exception.Create('Unsupported field type.');

  LField.Name              := ADataSet.Name + '_' + AFieldName;
  LField.FieldName         := AFieldName;
  LField.DataSet           := ADataSet;
  LField.FieldKind         := fkLookup;
  LField.KeyFields         := AKeyFields;
  LField.Lookup            := True;
  LField.LookupDataSet     := ALookupDataSet;
  LField.LookupKeyFields   := ALookupKeyFields;
  LField.LookupResultField := ALookupResultField;
  LField.DisplayLabel      := ADisplayLabel;
  case AFieldType of
    ftLargeint, ftString, ftWideString, ftFixedChar, ftFixedWideChar:
      begin
        if ASize > 0 then
          LField.Size := ASize;
      end;
  end;
  Result := Self;
end;

constructor TFieldSingleton.Create;
begin

end;

function TFieldSingleton._GetFieldType(const ADataSet: TDataSet;
  const AFieldType: TFieldType): TField;
begin
  case AFieldType of
//     ftUnknown:         Result := nil; // 0
     ftString:          Result := TStringField.Create(ADataSet); // 1
     ftSmallint:        Result := TSmallintField.Create(ADataSet); // 2
     ftInteger:         Result := TIntegerField.Create(ADataSet); // 3
     ftWord:            Result := TWordField.Create(ADataSet); // 4
     ftBoolean:         Result := TBooleanField.Create(ADataSet); // 5
     ftFloat:           Result := TFloatField.Create(ADataSet); // 6
     ftCurrency:        Result := TCurrencyField.Create(ADataSet); // 7
     ftBCD:             Result := TBCDField.Create(ADataSet); // 8
     ftDate:            Result := TDateField.Create(ADataSet); // 9
     ftTime:            Result := TTimeField.Create(ADataSet); // 10
     ftDateTime:        Result := TDateTimeField.Create(ADataSet); // 11
     ftBytes:           Result := TBytesField.Create(ADataSet); // 12
     ftVarBytes:        Result := TVarBytesField.Create(ADataSet); // 13
     ftAutoInc:         Result := TIntegerField.Create(ADataSet); // 14
     ftBlob:            Result := TBlobField.Create(ADataSet); // 15
     ftMemo:            Result := TMemoField.Create(ADataSet); // 16
     ftGraphic:         Result := TGraphicField.Create(ADataSet); // 17
//     ftFmtMemo:         Result := nil; // 18
//     ftParadoxOle:      Result := nil; // 19
//     ftDBaseOle:        Result := nil; // 20
     ftTypedBinary:     Result := TBinaryField.Create(ADataSet); // 21
//     ftCursor:          Result := nil; // 22
     ftFixedChar:       Result := TStringField.Create(ADataSet); // 23
     ftWideString:      Result := TWideStringField.Create(ADataSet); // 24
     ftLargeint:        Result := TLargeintField.Create(ADataSet); // 25
     ftADT:             Result := TADTField.Create(ADataSet); // 26
     ftArray:           Result := TArrayField.Create(ADataSet); // 27
     ftReference:       Result := TReferenceField.Create(ADataSet); // 28
     ftDataSet:         Result := TDataSetField.Create(ADataSet); // 29
//     ftOraBlob:         Result := nil; // 30
//     ftOraClob:         Result := nil; // 31
     ftVariant:         Result := TVariantField.Create(ADataSet); // 32
     ftInterface:       Result := TInterfaceField.Create(ADataSet); // 33
     ftIDispatch:       Result := TIDispatchField.Create(ADataSet); // 34
     ftGuid:            Result := TGuidField.Create(ADataSet); // 35
     ftTimeStamp:       Result := TDateTimeField.Create(ADataSet); // 36
     ftFMTBcd:          Result := TFMTBCDField.Create(ADataSet); // 37
     ftFixedWideChar:   Result := TStringField.Create(ADataSet); // 38
     ftWideMemo:        Result := TMemoField.Create(ADataSet); // 39
     ftOraTimeStamp:    Result := TDateTimeField.Create(ADataSet); // 40
//     ftOraInterval:     Result := nil; // 41
     ftLongWord:        Result := TLongWordField.Create(ADataSet); // 42
     ftShortint:        Result := TShortintField.Create(ADataSet); // 43
     ftByte:            Result := TByteField.Create(ADataSet); // 44
     ftExtended:        Result := TExtendedField.Create(ADataSet); // 45
//     ftConnection:      Result := nil; // 46
//     ftParams:          Result := nil; // 47
//     ftStream:          Result := nil; // 48
     ftTimeStampOffset: Result := TStringField.Create(ADataSet); // 49
     ftObject:          Result := TObjectField.Create(ADataSet); // 50
     ftSingle:          Result := TSingleField.Create(ADataSet); // 51
  else
     Result := TVariantField.Create(ADataSet);
  end;
end;

class function TFieldSingleton.Get: IFieldSingleton;
begin
   if not Assigned(FInstance) then
      FInstance := TFieldSingleton.Create;
   Result := FInstance;
end;

function TFieldSingleton.AddCalcField(const ADataSet: TDataSet;
  const AFieldName: String;
  const AFieldType: TFieldType;
  const ASize: UInt32): IFieldSingleton;
var
  LField: TField;
begin
  if ADataSet = nil then
    raise Exception.Create('The dataset cannot be null.');

  if ADataSet.FindField(AFieldName) <> nil then
    raise Exception.Create('The calculated field: ' + AFieldName + ' already exists.');

  LField := _GetFieldType(ADataSet, AFieldType);
  if LField = nil then
    raise Exception.Create('Unsupported field type.');

  LField.Name       := ADataSet.Name + AFieldName;
  LField.FieldName  := AFieldName;
  LField.Calculated := True;
  LField.DataSet    := ADataSet;
  LField.FieldKind  := fkInternalCalc;
  //
  case AFieldType of
     ftLargeint, ftString, ftWideString, ftFixedChar, ftFixedWideChar:
      begin
        if ASize > 0 then
          LField.Size := ASize;
      end;
  end;
  Result := Self;
end;

function TFieldSingleton.AddAggregateField(const ADataSet: TDataSet;
  const AFieldName, AExpression: String;
  const AAlignment: TAlignment;
  const ADisplayFormat: String): IFieldSingleton;
var
  LField: TAggregateField;
begin
  if ADataSet = nil then
    raise Exception.Create('The dataset cannot be null.');

  if ADataSet.FindField(AFieldName) <> nil then
     raise Exception.Create('The aggregated field named: ' + AFieldName + ' already exists.');

  LField := TAggregateField.Create(ADataSet);
  if LField = nil then
    raise Exception.Create('Unsupported field type.');

  LField.Name         := ADataSet.Name + AFieldName;
  LField.FieldKind    := fkAggregate;
  LField.FieldName    := AFieldName;
  LField.DisplayLabel := AFieldName;
  LField.DataSet      := ADataSet;
  LField.Expression   := AExpression;
  LField.Active       := True;
  LField.Alignment    := AAlignment;
  //
  if Length(ADisplayFormat) > 0 then
    LField.DisplayFormat := ADisplayFormat;

  Result := Self;
end;

{ TFieldHelper }

function TFieldHelper.AsType<T>: T;
begin
  Result := T(Self);
end;

end.
