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

unit dbebr.factory.ado;

interface

uses
  DB,
  Classes,
  SysUtils,
  ADODB,
  // DBEBr
  dbebr.factory.connection,
  dbebr.factory.interfaces;

type
  // F�brica de conex�o concreta com ADO
  TFactoryADO = class(TFactoryConnection)
  public
    constructor Create(const AConnection: TADOConnection;
      const ADriverName: TDriverName); overload;
    constructor Create(const AConnection: TADOConnection;
      const ADriverName: TDriverName;
      const AMonitor: ICommandMonitor); overload;
    constructor Create(const AConnection: TADOConnection;
      const ADriverName: TDriverName;
      const AMonitorCallback: TMonitorProc); overload;
    destructor Destroy; override;
    procedure AddTransaction(const AKey: String; const ATransaction: TComponent); override;
  end;

implementation

uses
  dbebr.driver.ado,
  dbebr.driver.ado.transaction;

{ TFactoryADO }

constructor TFactoryADO.Create(const AConnection: TADOConnection;
  const ADriverName: TDriverName);
begin
  FDriverTransaction := TDriverADOTransaction.Create(AConnection);
  FDriverConnection  := TDriverADO.Create(AConnection,
                                          FDriverTransaction,
                                          ADriverName,
                                          FCommandMonitor,
                                          FMonitorCallback);
  FAutoTransaction := False;
end;

constructor TFactoryADO.Create(const AConnection: TADOConnection;
  const ADriverName: TDriverName; const AMonitor: ICommandMonitor);
begin
  Create(AConnection, ADriverName);
  FCommandMonitor := AMonitor;
end;

procedure TFactoryADO.AddTransaction(const AKey: String;
  const ATransaction: TComponent);
begin
  if not (ATransaction is TADOConnection) then
    raise Exception.Create('Invalid transaction type. Expected TADOConnection.');

  inherited AddTransaction(AKey, ATransaction);
end;

constructor TFactoryADO.Create(const AConnection: TADOConnection;
  const ADriverName: TDriverName; const AMonitorCallback: TMonitorProc);
begin
  Create(AConnection, ADriverName);
  FMonitorCallback := AMonitorCallback;
end;

destructor TFactoryADO.Destroy;
begin
  FDriverConnection.Free;
  FDriverTransaction.Free;
  inherited;
end;

end.
