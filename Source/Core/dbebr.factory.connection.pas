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

unit dbebr.factory.connection;

interface

uses
  DB,
  Classes,
  SysUtils,
  dbebr.factory.interfaces,
  dbebr.driver.connection;

type
  // Fábrica de conexões abstratas
  TFactoryConnection = class abstract(TInterfacedObject, IDBConnection)
  protected
    FOptions: IOptions;
    FAutoTransaction: Boolean;
    FDriverConnection: TDriverConnection;
    FDriverTransaction: TDriverTransaction;
    FCommandMonitor: ICommandMonitor;
    FMonitorCallback: TMonitorProc;
    function _GetTransaction(const AKey: String): TComponent; virtual;
  public
    procedure Connect; virtual;
    procedure Disconnect; virtual;
    procedure StartTransaction; virtual;
    procedure Commit; virtual;
    procedure Rollback; virtual;
    procedure ExecuteDirect(const ASQL: String); overload; virtual;
    procedure ExecuteDirect(const ASQL: String;
      const AParams: TParams); overload; virtual;
    procedure ExecuteScript(const AScript: String); virtual;
    procedure AddScript(const AScript: String); virtual;
    procedure ExecuteScripts; virtual;
    procedure SetCommandMonitor(AMonitor: ICommandMonitor); virtual;
      deprecated 'use Create(AConnection, ADriverName, AMonitor)';
    procedure ApplyUpdates(const ADataSets: array of IDBResultSet); virtual;
    procedure AddTransaction(const AKey: String; const ATransaction: TComponent); virtual;
    procedure UseTransaction(const AKey: String); virtual;
    function TransactionActive: TComponent; virtual;
    function InTransaction: Boolean; virtual;
    function IsConnected: Boolean; virtual;
    function GetDriverName: TDriverName; virtual;
    function CreateQuery: IDBQuery; virtual;
    function CreateResultSet(const ASQL: String = ''): IDBResultSet; virtual;
    function CommandMonitor: ICommandMonitor;
    function MonitorCallback: TMonitorProc; virtual;
    function Options: IOptions; virtual;
    function RowsAffected: UInt32; virtual;
  end;

  TDriverTransactionHacker = class(TDriverTransaction)
  end;

implementation

{ TFactoryConnection }

procedure TFactoryConnection.AddScript(const AScript: String);
begin
  FDriverConnection.AddScript(AScript);
end;

procedure TFactoryConnection.AddTransaction(const AKey: String;
  const ATransaction: TComponent);
begin
  FDriverTransaction.AddTransaction(AKey, ATransaction);
end;

procedure TFactoryConnection.ApplyUpdates(const ADataSets: array of IDBResultSet);
begin
  FDriverConnection.ApplyUpdates(ADataSets);
end;

function TFactoryConnection.CommandMonitor: ICommandMonitor;
begin
  Result := FCommandMonitor;
end;

procedure TFactoryConnection.Commit;
begin
  FDriverTransaction.Commit;
  if FAutoTransaction then
    Disconnect;
end;

procedure TFactoryConnection.Connect;
begin
  if not IsConnected then
    FDriverConnection.Connect;
end;

function TFactoryConnection.CreateQuery: IDBQuery;
begin
  Result := FDriverConnection.CreateQuery;
end;

function TFactoryConnection.CreateResultSet(const ASQL: String): IDBResultSet;
begin
  Result := FDriverConnection.CreateResultSet(ASQL);
end;

procedure TFactoryConnection.Disconnect;
begin
  if IsConnected then
    FDriverConnection.Disconnect;
end;

function TFactoryConnection.Options: IOptions;
begin
  if not Assigned(FOptions) then
    FOptions := TOptions.Create;
  Result := FOptions;
end;

procedure TFactoryConnection.ExecuteDirect(const ASQL: String;
  const AParams: TParams);
var
  LInTransaction: Boolean;
  LIsConnected: Boolean;
begin
  LInTransaction := InTransaction;
  LIsConnected := IsConnected;
  if not LIsConnected then
    Connect;
  try
    try
      if not LInTransaction then
        StartTransaction;
      FDriverConnection.ExecuteDirect(ASQL, AParams);
      if not LInTransaction then
        Commit;
    except
      on E: Exception do
      begin
        if not LInTransaction then
          Rollback;
        raise Exception.Create(E.Message);
      end;
    end;
  finally
    if not LIsConnected then
      Disconnect;
  end;
end;

procedure TFactoryConnection.ExecuteDirect(const ASQL: String);
var
  LInTransaction: Boolean;
  LIsConnected: Boolean;
begin
  LInTransaction := InTransaction;
  LIsConnected := IsConnected;
  if not LIsConnected then
    Connect;
  try
    if not LInTransaction then
      StartTransaction;
    try
      FDriverConnection.ExecuteDirect(ASQL);
      if not LInTransaction then
        Commit;
    except
      on E: Exception do
      begin
        if not LInTransaction then
          Rollback;
        raise Exception.Create(E.Message);
      end;
    end;
  finally
    if not LIsConnected then
      Disconnect;
  end;
end;

procedure TFactoryConnection.ExecuteScript(const AScript: String);
var
  LInTransaction: Boolean;
  LIsConnected: Boolean;
begin
  LInTransaction := InTransaction;
  LIsConnected := IsConnected;
  if not LIsConnected then
    Connect;
  try
    if not LInTransaction then
      StartTransaction;
    try
      FDriverConnection.ExecuteScript(AScript);
      if not LInTransaction then
        Commit;
    except
      on E: Exception do
      begin
        if not LInTransaction then
          Rollback;
        raise Exception.Create(E.Message);
      end;
    end;
  finally
    if not LIsConnected then
      Disconnect;
  end;
end;

procedure TFactoryConnection.ExecuteScripts;
var
  LInTransaction: Boolean;
  LIsConnected: Boolean;
begin
  LInTransaction := InTransaction;
  LIsConnected := IsConnected;
  if not LIsConnected then
    Connect;
  try
    if not LInTransaction then
      StartTransaction;
    try
      FDriverConnection.ExecuteScripts;
      if not LInTransaction then
        Commit;
    except
      on E: Exception do
      begin
        if not LInTransaction then
          Rollback;
        raise Exception.Create(E.Message);
      end;
    end;
  finally
    if not LIsConnected then
      Disconnect;
  end;
end;

function TFactoryConnection.GetDriverName: TDriverName;
begin
  Result := FDriverConnection.GetDriverName;
end;

function TFactoryConnection.InTransaction: Boolean;
begin
  Result := False;
  if not IsConnected then
    Exit;
  Result := FDriverTransaction.InTransaction;
end;

function TFactoryConnection.IsConnected: Boolean;
begin
  Result := FDriverConnection.IsConnected;
end;

function TFactoryConnection.MonitorCallback: TMonitorProc;
begin
  Result := FMonitorCallback;
end;

procedure TFactoryConnection.Rollback;
begin
  FDriverTransaction.Rollback;
  if FAutoTransaction then
    Disconnect;
end;

function TFactoryConnection.RowsAffected: UInt32;
begin
  Result := FDriverConnection.RowsAffected;
end;

procedure TFactoryConnection.SetCommandMonitor(AMonitor: ICommandMonitor);
begin
  FCommandMonitor := AMonitor;
end;

procedure TFactoryConnection.StartTransaction;
begin
  if not IsConnected then
  begin
    Connect;
    FAutoTransaction := True;
  end;
  FDriverTransaction.StartTransaction;
end;

function TFactoryConnection.TransactionActive: TComponent;
begin
  Result := FDriverTransaction.TransactionActive;
end;

procedure TFactoryConnection.UseTransaction(const AKey: String);
begin
  FDriverTransaction.UseTransaction(AKey);
end;

function TFactoryConnection._GetTransaction(const AKey: String): TComponent;
begin
  Result := TDriverTransactionHacker(FDriverTransaction)._GetTransaction(AKey);
end;

end.
