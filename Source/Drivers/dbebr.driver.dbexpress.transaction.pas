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

unit dbebr.driver.dbexpress.transaction;

interface

uses
  DB,
  Classes,
  SysUtils,
  Generics.Collections,
  SqlExpr,
  DBXCommon,
  // DBEBr
  dbebr.driver.connection,
  dbebr.factory.interfaces;

type
  // Classe de conexão concreta com dbExpress
  TDriverDBExpressTransaction = class(TDriverTransaction)
  protected
    FConnection: TSQLConnection;
    FTransactionLocal: TDBXTransaction;
  public
    constructor Create(const AConnection: TComponent); override;
    destructor Destroy; override;
    procedure StartTransaction; override;
    procedure Commit; override;
    procedure Rollback; override;
    procedure AddTransaction(const AKey: String; const ATransaction: TComponent); override;
    procedure UseTransaction(const AKey: String); override;
    function InTransaction: Boolean; override;
  end;

implementation

{ TDriverDBExpressTransaction }

constructor TDriverDBExpressTransaction.Create(const AConnection: TComponent);
begin
  FConnection := AConnection as TSQLConnection;
end;

destructor TDriverDBExpressTransaction.Destroy;
begin
  if Assigned(FTransactionLocal) then
    FTransactionLocal.Free;
  inherited;
end;

procedure TDriverDBExpressTransaction.StartTransaction;
begin
  FTransactionLocal := FConnection.BeginTransaction;
end;

procedure TDriverDBExpressTransaction.AddTransaction(const AKey: String;
  const ATransaction: TComponent);
begin

end;

procedure TDriverDBExpressTransaction.UseTransaction(const AKey: String);
begin

end;

procedure TDriverDBExpressTransaction.Commit;
begin
  FConnection.CommitFreeAndNil(FTransactionLocal);
end;

procedure TDriverDBExpressTransaction.Rollback;
begin
  FConnection.RollbackFreeAndNil(FTransactionLocal);
end;

function TDriverDBExpressTransaction.InTransaction: Boolean;
begin
  Result := FConnection.InTransaction;
end;

end.
