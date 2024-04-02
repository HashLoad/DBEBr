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

unit dbebr.factory.nexusdb;

interface

uses
  DB,
  Classes,
  SysUtils,
  nxdb,
  // DBEBr
  dbebr.factory.connection,
  dbebr.factory.interfaces;

type
  // Fábrica de conexão concreta com NexusDB
  TFactoryNexusDB = class(TFactoryConnection)
  public
    constructor Create(const AConnection: TnxDatabase;
      const ADriverName: TDriverName); overload;
    constructor Create(const AConnection: TnxDatabase;
      const ADriverName: TDriverName;
      const AMonitor: ICommandMonitor); overload;
    constructor Create(const AConnection: TnxDatabase;
      const ADriverName: TDriverName;
      const AMonitorCallback: TMonitorProc); overload;
    destructor Destroy; override;
    procedure AddTransaction(const AKey: String; const ATransaction: TComponent); override;
  end;

implementation

uses
  dbebr.driver.nexusdb,
  dbebr.driver.nexusdb.transaction;

{ TFactoryNexusDB }

constructor TFactoryNexusDB.Create(const AConnection: TnxDatabase;
  const ADriverName: TDriverName);
begin
  FDriverTransaction := TDriverNexusDBTransaction.Create(AConnection);
  FDriverConnection  := TDriverNexusDB.Create(AConnection,
                                              FDriverTransaction,
                                              ADriverName,
                                              FCommandMonitor,
                                              FMonitorCallback);
  FAutoTransaction := False;
end;

constructor TFactoryNexusDB.Create(const AConnection: TnxDatabase;
  const ADriverName: TDriverName; const AMonitor: ICommandMonitor);
begin
  Create(AConnection, ADriverName);
  FCommandMonitor := AMonitor;
end;

procedure TFactoryNexusDB.AddTransaction(const AKey: String;
  const ATransaction: TComponent);
begin
  if not (ATransaction is TnxDatabase) then
    raise Exception.Create('Invalid transaction type. Expected TnxDatabase.');

  inherited AddTransaction(AKey, ATransaction);
end;

constructor TFactoryNexusDB.Create(const AConnection: TUniConnection;
  const ADriverName: TDriverName; const AMonitorCallback: TMonitorProc);
begin
  Create(AConnection, ADriverName);
  FMonitorCallback := AMonitorCallback;
end;

destructor TFactoryNexusDB.Destroy;
begin
  FDriverConnection.Free;
  FDriverTransaction.Free;
  inherited;
end;

end.
