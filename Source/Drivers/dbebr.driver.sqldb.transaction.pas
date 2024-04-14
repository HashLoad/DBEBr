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

unit dbebr.driver.sqldb.transaction;

interface

uses
  DB,
  Classes,
  SysUtils,
  Generics.Collections,
  SQLDB,
  // DBEBr
  dbebr.driver.connection,
  dbebr.factory.interfaces;

type
  TDriverSQLdbTransaction = class(TDriverTransaction)
  private
    FConnection: TSQLConnection;
    FTransaction: TSQLTransaction;
  public
    constructor Create(const AConnection: TComponent); override;
    destructor Destroy; override;
    procedure StartTransaction; override;
    procedure Commit; override;
    procedure Rollback; override;
    function InTransaction: Boolean; override;
  end;

implementation

{ TDriverFireDACTransaction }

constructor TDriverSQLdbTransaction.Create(const AConnection: TComponent);
begin
  FTransactionList := TDictionary<String, TComponent>.Create;
  FConnection := AConnection as TSQLConnection;
  if FConnection.Transaction = nil then
  begin
    FTransaction := TSQLTransaction.Create(nil);
    FTransaction.Database := FConnection;
    FConnection.Transaction := FTransaction;
  end;
  FConnection.Transaction.Name := 'DEFAULT';
  FTransactionList.Add('DEFAULT', FConnection.Transaction);
  FTransactionActive := FConnection.Transaction;
end;

destructor TDriverSQLdbTransaction.Destroy;
begin
  if Assigned(FTransaction) then
  begin
    FConnection.Transaction := nil;
    FTransaction.Database := nil;
    FTransaction.Free;
  end;
  FTransactionActive := nil;
  FTransactionList.Clear;
  FTransactionList.Free;
  inherited;
end;

procedure TDriverSQLdbTransaction.StartTransaction;
begin
  (FTransactionActive as TSQLTransaction).StartTransaction;
end;

procedure TDriverSQLdbTransaction.Commit;
begin
  (FTransactionActive as TSQLTransaction).Commit;
end;

procedure TDriverSQLdbTransaction.Rollback;
begin
  (FTransactionActive as TSQLTransaction).Rollback;
end;

function TDriverSQLdbTransaction.InTransaction: Boolean;
begin
  if not Assigned(FTransactionActive) then
    raise Exception.Create('The active transaction is not defined. Please make sure to start a transaction before checking if it is in progress.');
  Result := (FTransactionActive as TSQLTransaction).Active;
end;

end.
