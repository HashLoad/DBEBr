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

unit dbebr.factory.absolutedb;

interface

uses
  DB,
  Classes,
  SysUtils,
  ABSMain,
  // DBEBr
  dbebr.factory.connection,
  dbebr.factory.interfaces;

type
  // Fábrica de conexão concreta com AbsoluteDB
  TFactoryAbsoluteDB = class(TFactoryConnection)
  public
    constructor Create(const AConnection: TABSDatabase;
      const ADriverName: TDriverName); overload;
    constructor Create(const AConnection: TABSDatabase;
      const ADriverName: TDriverName;
      const AMonitor: ICommandMonitor); overload;
    constructor Create(const AConnection: TABSDatabase;
      const ADriverName: TDriverName;
      const AMonitorCallback: TMonitorProc); overload;
    destructor Destroy; override;
  end;

implementation

uses
  dbebr.driver.absolutedb,
  dbebr.driver.absolutedb.transaction;

{ TFactoryAbsoluteDB }

constructor TFactoryAbsoluteDB.Create(const AConnection: TABSDatabase;
  const ADriverName: TDriverName);
begin
  FDriverTransaction := TDriverAbsoluteDBTransaction.Create(AConnection);
  FDriverConnection  := TDriverAbsoluteDB.Create(AConnection,
                                                 FDriverTransaction,
                                                 ADriverName,
                                                 FCommandMonitor,
                                                 FMonitorCallback);
  FAutoTransaction := False;
end;

constructor TFactoryAbsoluteDB.Create(const AConnection: TABSDatabase;
  const ADriverName: TDriverName; const AMonitor: ICommandMonitor);
begin
  Create(AConnection, ADriverName);
  FCommandMonitor := AMonitor;
end;

procedure TFactoryAbsoluteDB.AddTransaction(const AKey: String;
  const ATransaction: TComponent);
begin
  if not (ATransaction is TABSDatabase) then
    raise Exception.Create('Invalid transaction type. Expected TABSDatabase.');

  inherited AddTransaction(AKey, ATransaction);
end;

constructor TFactoryAbsoluteDB.Create(const AConnection: TABSDatabase;
  const ADriverName: TDriverName; const AMonitorCallback: TMonitorProc);
begin
  Create(AConnection, ADriverName);
  FMonitorCallback := AMonitorCallback;
end;

destructor TFactoryAbsoluteDB.Destroy;
begin
  FDriverConnection.Free;
  FDriverTransaction.Free;
  inherited;
end;

end.
