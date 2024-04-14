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

unit dbebr.factory.sqldb;

interface

uses
  DB,
  Classes,
  SysUtils,
  SQLDB,
  // DBEBr
  dbebr.factory.connection,
  dbebr.factory.interfaces;

type
  // Fábrica de conexão concreta com SQLDB
  TFactorySQLdb = class(TFactoryConnection)
  public
    constructor Create(const AConnection: TSQLConnection;
      const ADriverName: TDriverName); overload;
    constructor Create(const AConnection: TSQLConnection;
      const ADriverName: TDriverName;
      const AMonitor: ICommandMonitor); overload;
    constructor Create(const AConnection: TSQLConnection;
      const ADriverName: TDriverName;
      const AMonitorCallback: TMonitorProc); overload;
    destructor Destroy; override;
    procedure AddTransaction(const AKey: String; const ATransaction: TComponent); override;
  end;

implementation

uses
  dbebr.driver.firedac,
  dbebr.driver.firedac.transaction;

{ TFactoryFireDAC }

constructor TFactorySQLdb.Create(const AConnection: TSQLConnection;
  const ADriverName: TDriverName);
begin
  FDriverTransaction := TDriverFireDACTransaction.Create(AConnection);
  FDriverConnection  := TDriverFireDAC.Create(AConnection,
                                              FDriverTransaction,
                                              ADriverName,
                                              FCommandMonitor,
                                              FMonitorCallback);
  FAutoTransaction := False;
end;

constructor TFactorySQLdb.Create(const AConnection: TSQLConnection;
  const ADriverName: TDriverName; const AMonitor: ICommandMonitor);
begin
  FCommandMonitor := AMonitor;
  Create(AConnection, ADriverName);
end;

procedure TFactorySQLdb.AddTransaction(const AKey: String;
  const ATransaction: TComponent);
begin
  if not (ATransaction is TSQLTransaction) then
    raise Exception.Create('Invalid transaction type. Expected TSQLTransaction.');

  inherited AddTransaction(AKey, ATransaction);
end;

constructor TFactorySQLdb.Create(const AConnection: TSQLConnection;
  const ADriverName: TDriverName; const AMonitorCallback: TMonitorProc);
begin
  FMonitorCallback := AMonitorCallback;
  Create(AConnection, ADriverName);
end;

destructor TFactorySQLdb.Destroy;
begin
  FDriverConnection.Free;
  FDriverTransaction.Free;
  inherited;
end;

end.
