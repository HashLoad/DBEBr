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

unit dbebr.driver.zeos.transaction;

interface

uses
  DB,
  Classes,
  SysUtils,
  Generics.Collections,
  ZAbstractConnection,
  ZConnection,
  // DBEBr
  dbebr.driver.connection,
  dbebr.factory.interfaces;

type
  TDriverZeosTransaction = class(TDriverTransaction)
  private
    FConnection: TZConnection;
    {$IFDEF ZEOS80UP}
    FTransaction: TZTransaction;
	{$ENDIF}
  public
    constructor Create(const AConnection: TComponent); override;
    destructor Destroy; override;
    procedure StartTransaction; override;
    procedure Commit; override;
    procedure Rollback; override;
    function InTransaction: Boolean; override;
  end;

implementation

{ TDriverZeosTransaction }

constructor TDriverZeosTransaction.Create(const AConnection: TComponent);
begin
  FTransactionList := TDictionary<String, TComponent>.Create;
  FConnection := AConnection as TZConnection;
  {$IFDEF ZEOS80UP}
  if FConnection.Transaction = nil then
  begin
    FTransaction := TFDTransaction.Create(nil);
    FTransaction.Connection := FConnection;
    FConnection.Transaction := FTransaction;
  end;
  FConnection.Transaction.Name := 'DEFAULT';
  FTransactionList.Add('DEFAULT', FConnection.Transaction);
  FTransactionActive := FConnection.Transaction;
  {$ENDIF}
end;

destructor TDriverZeosTransaction.Destroy;
begin
  {$IFDEF ZEOS80UP}
  if Assigned(FTransaction) then
  begin
    FConnection.Transaction := nil;
    FTransaction.Connection := nil;
    FTransaction.Free;
  end;
  {$ENDIF}
  FTransactionActive := nil;
  FTransactionList.Clear;
  FTransactionList.Free;
  inherited;
end;

procedure TDriverZeosTransaction.StartTransaction;
begin
  {$IFDEF ZEOS80UP}
  (FTransactionActive as TZTransaction).StartTransaction;
  {$ELSE}
  FConnection.StartTransaction;
  {$ENDIF}
end;

procedure TDriverZeosTransaction.Commit;
begin
  {$IFDEF ZEOS80UP}
  (FTransactionActive as TZTransaction).Commit;
  {$ELSE}
  FConnection.Commit;
  {$ENDIF}
end;

procedure TDriverZeosTransaction.Rollback;
begin
  {$IFDEF ZEOS80UP}
  (FTransactionActive as TZTransaction).Rollback;
  {$ELSE}
  FConnection.Rollback;
  {$ENDIF}
end;

function TDriverZeosTransaction.InTransaction: Boolean;
begin
  {$IFDEF ZEOS80UP}
  if not Assigned(FTransactionActive) then
    raise Exception.Create('The active transaction is not defined. Please make sure to start a transaction before checking if it is in progress.');
  Result := (FTransactionActive as TZTransaction).InTransaction;
  {$ELSE}
  Result := FConnection.InTransaction;
  {$ENDIF}
end;

end.
