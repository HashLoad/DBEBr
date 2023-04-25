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
    FAutoTransaction: Boolean;
    FCommandMonitor: ICommandMonitor;
    FOptions: IOptions;
    FDriverConnection: TDriverConnection;
    FDriverTransaction: TDriverTransaction;
    FMonitorCallback: TMonitorProc;
  public
    procedure Connect; virtual; abstract;
    procedure Disconnect; virtual; abstract;
    procedure StartTransaction; virtual;
    procedure Commit; virtual;
    procedure Rollback; virtual;
    procedure ExecuteDirect(const ASQL: string); overload; virtual;
    procedure ExecuteDirect(const ASQL: string;
      const AParams: TParams); overload; virtual;
    procedure ExecuteScript(const AScript: string); virtual;
    procedure AddScript(const AScript: string); virtual; abstract;
    procedure ExecuteScripts; virtual;
    procedure SetCommandMonitor(AMonitor: ICommandMonitor); virtual;
      deprecated 'use Create(AConnection, ADriverName, AMonitor)';
    function InTransaction: Boolean; virtual; abstract;
    function IsConnected: Boolean; virtual; abstract;
    function GetDriverName: TDriverName; virtual; abstract;
    function CreateQuery: IDBQuery; virtual; abstract;
    function CreateResultSet(const ASQL: String): IDBResultSet; virtual; abstract;
    function CommandMonitor: ICommandMonitor;
    function MonitorCallback: TMonitorProc; virtual;
    function Options: IOptions; virtual;
  end;

implementation

{ TFactoryConnection }

function TFactoryConnection.CommandMonitor: ICommandMonitor;
begin
  Result := FCommandMonitor;
end;

procedure TFactoryConnection.Commit;
begin
  if FAutoTransaction then
    Disconnect;
end;

function TFactoryConnection.Options: IOptions;
begin
  if not Assigned(FOptions) then
    FOptions := TOptions.Create;
  Result := FOptions;
end;

procedure TFactoryConnection.ExecuteDirect(const ASQL: string;
  const AParams: TParams);
var
  LInTransaction: Boolean;
  LIsConnected: Boolean;
begin
  inherited;
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

procedure TFactoryConnection.ExecuteDirect(const ASQL: string);
var
  LInTransaction: Boolean;
  LIsConnected: Boolean;
begin
  inherited;
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

procedure TFactoryConnection.ExecuteScript(const AScript: string);
var
  LInTransaction: Boolean;
  LIsConnected: Boolean;
begin
  inherited;
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
  inherited;
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

function TFactoryConnection.MonitorCallback: TMonitorProc;
begin
  Result := FMonitorCallback;
end;

procedure TFactoryConnection.Rollback;
begin
  if FAutoTransaction then
    Disconnect;
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
end;

end.
