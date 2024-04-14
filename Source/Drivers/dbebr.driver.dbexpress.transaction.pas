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
  // Classe de conex�o concreta com dbExpress
  TDriverDBExpressTransaction = class(TDriverTransaction)
  protected
    FConnection: TSQLConnection;
    FDBXTransaction: TDBXTransaction;
  public
    constructor Create(const AConnection: TComponent); override;
    destructor Destroy; override;
    procedure StartTransaction; override;
    procedure Commit; override;
    procedure Rollback; override;
    function InTransaction: Boolean; override;
  end;

implementation

{ TDriverDBExpressTransaction }

constructor TDriverDBExpressTransaction.Create(const AConnection: TComponent);
begin
  FTransactionList := TDictionary<String, TComponent>.Create;
  FConnection := AConnection as TSQLConnection;
  FConnection.DefaultTransaction.Name := 'DEFAULT';
  FTransactionList.Add('DEFAULT', FConnection.DefaultTransaction);
  FTransactionActive := FConnection.DefaultTransaction;
end;

destructor TDriverDBExpressTransaction.Destroy;
begin
  FTransactionActive := nil;
  FTransactionList.Clear;
  FTransactionList.Free;
  inherited;
end;

procedure TDriverDBExpressTransaction.StartTransaction;
begin
  (FTransactionActive as TDBXTransaction).StartTransaction;
end;

procedure TDriverDBExpressTransaction.Commit;
begin
  (FTransactionActive as TDBXTransaction).Commit;
end;

procedure TDriverDBExpressTransaction.Rollback;
begin
  (FTransactionActive as TDBXTransaction).Rollback;
end;

function TDriverDBExpressTransaction.InTransaction: Boolean;
begin
  if not Assigned(FTransactionActive) then
    raise Exception.Create('The active transaction is not defined. Please make sure to start a transaction before checking if it is in progress.');
  Result := (FTransactionActive as TDBXTransaction).Active;
end;

end.
