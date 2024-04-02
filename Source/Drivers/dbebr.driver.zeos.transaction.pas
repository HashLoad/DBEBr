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
  Classes,
  DB,
  ZAbstractConnection,
  ZConnection,
  // DBEBr
  dbebr.driver.connection,
  dbebr.factory.interfaces;

type
  TDriverUniDACTransaction = class(TDriverTransaction)
  private
    FConnection: TZConnection;
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

constructor TDriverZeosTransaction.Create(AConnection: TComponent);
begin
  FTransactionList := TDictionary<String, TComponent>.Create;
  FConnection := AConnection as TZConnection;
  FConnection.DefaultTransaction.Name := 'DEFAULT';
  FTransactionList.Add('DEFAULT', FConnection.DefaultTransaction);
  FTransactionActive := FConnection.DefaultTransaction;
end;

destructor TDriverZeosTransaction.Destroy;
begin
  FTransactionActive := nil;
  FTransactionList.Clear;
  FTransactionList.Free;
  inherited;
end;

procedure TDriverZeosTransaction.StartTransaction;
begin
  (FTransactionActive as TZTransaction).StartTransaction;
end;

procedure TDriverZeosTransaction.Commit;
begin
  (FTransactionActive as TZTransaction).Commit;
end;

procedure TDriverZeosTransaction.Rollback;
begin
  (FTransactionActive as TZTransaction).Rollback;
end;

function TDriverZeosTransaction.InTransaction: Boolean;
begin
  if not Assigned(FTransactionActive) then
    raise Exception.Create('The active transaction is not defined. Please make sure to start a transaction before checking if it is in progress.');
  Result := (FTransactionActive as TZTransaction).Active;
end;

end.
