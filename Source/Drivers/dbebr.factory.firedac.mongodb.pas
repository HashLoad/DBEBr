﻿{
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

unit dbebr.factory.firedac.mongodb;

interface

uses
  DB,
  Classes,
  SysUtils,
  dbebr.factory.connection,
  dbebr.factory.interfaces;

type
  // Fábrica de conexão concreta com dbExpress
  TFactoryMongoFireDAC = class(TFactoryConnection)
  public
    constructor Create(const AConnection: TComponent;
      const  ADriverName: TDriverName); overload;
    constructor Create(const AConnection: TComponent;
      const ADriverName: TDriverName;
      const AMonitor: ICommandMonitor); overload;
    constructor Create(const AConnection: TComponent;
      const ADriverName: TDriverName;
      const AMonitorCallback: TMonitorProc); overload;
    destructor Destroy; override;
  end;

implementation

uses
  dbebr.driver.firedac.mongodb,
  dbebr.driver.firedac.mongodb.transaction;

{ TFactoryMongoFireDAC }

constructor TFactoryMongoFireDAC.Create(const AConnection: TComponent;
  const  ADriverName: TDriverName);
begin
  FDriverConnection  := TDriverMongoFireDAC.Create(AConnection, ADriverName);
  FDriverTransaction := TDriverMongoFireDACTransaction.Create(AConnection);
end;

constructor TFactoryMongoFireDAC.Create(const AConnection: TComponent;
  const ADriverName: TDriverName; const AMonitorCallback: TMonitorProc);
begin
  Create(AConnection, ADriverName);
  FMonitorCallback := AMonitorCallback;
end;

constructor TFactoryMongoFireDAC.Create(const AConnection: TComponent;
  const ADriverName: TDriverName; const AMonitor: ICommandMonitor);
begin
  Create(AConnection, ADriverName);
  FCommandMonitor := AMonitor;
end;

destructor TFactoryMongoFireDAC.Destroy;
begin
  FDriverTransaction.Free;
  FDriverConnection.Free;
  inherited;
end;

end.