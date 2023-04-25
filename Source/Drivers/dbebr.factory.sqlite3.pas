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

unit dbebr.factory.sqlite3;

interface

uses
  DB,
  Classes,
  dbebr.factory.connection,
  dbebr.factory.interfaces;

type
  // Fábrica de conexão concreta com dbExpress
  TFactorySQLite = class(TFactoryConnection)
  public
    constructor Create(const AConnection: TComponent;
      const ADriverName: TDriverName); overload;
    constructor Create(const AConnection: TComponent;
      const ADriverName: TDriverName;
      const AMonitor: ICommandMonitor); overload;
    constructor Create(const AConnection: TComponent;
      const ADriverName: TDriverName;
      const AMonitorCallback: TMonitorProc); overload;
    destructor Destroy; override;
    procedure Connect; override;
    procedure Disconnect; override;
    procedure StartTransaction; override;
    procedure Commit; override;
    procedure Rollback; override;
    procedure ExecuteDirect(const ASQL: string); override;
    procedure ExecuteDirect(const ASQL: string; const AParams: TParams); override;
    procedure ExecuteScript(const AScript: string); override;
    procedure AddScript(const AScript: string); override;
    procedure ExecuteScripts; override;
    function InTransaction: Boolean; override;
    function IsConnected: Boolean; override;
    function GetDriverName: TDriverName; override;
    function CreateQuery: IDBQuery; override;
    function CreateResultSet(const ASQL: String): IDBResultSet; override;
  end;

implementation

uses
  dbebr.driver.sqlite3,
  dbebr.driver.sqlite3.transaction;

{ TFactorySQLite }

procedure TFactorySQLite.Connect;
begin
  if not IsConnected then
    FDriverConnection.Connect;
end;

constructor TFactorySQLite.Create(const AConnection: TComponent;
  const ADriverName: TDriverName);
begin
  FDriverConnection  := TDriverSQLite3.Create(AConnection, ADriverName);
  FDriverTransaction := TDriverSQLiteTransaction3.Create(AConnection);
  FAutoTransaction := False;
end;

constructor TFactorySQLite.Create(const AConnection: TComponent;
  const ADriverName: TDriverName;
  const AMonitor: ICommandMonitor);
begin
  Create(AConnection, ADriverName);
  FCommandMonitor := AMonitor;
end;

constructor TFactorySQLite.Create(const AConnection: TComponent;
  const ADriverName: TDriverName; const AMonitorCallback: TMonitorProc);
begin
  Create(AConnection, ADriverName);
  FMonitorCallback := AMonitorCallback;
end;

function TFactorySQLite.CreateQuery: IDBQuery;
begin
  Result := FDriverConnection.CreateQuery;
end;

function TFactorySQLite.CreateResultSet(const ASQL: String): IDBResultSet;
begin
  Result := FDriverConnection.CreateResultSet(ASQL);
end;

destructor TFactorySQLite.Destroy;
begin
  FDriverTransaction.Free;
  FDriverConnection.Free;
  inherited;
end;

procedure TFactorySQLite.Disconnect;
begin
  inherited;
  if IsConnected then
    FDriverConnection.Disconnect;
end;

procedure TFactorySQLite.ExecuteDirect(const ASQL: string);
begin
  inherited;
end;

procedure TFactorySQLite.ExecuteDirect(const ASQL: string; const AParams: TParams);
begin
  inherited;
end;

procedure TFactorySQLite.ExecuteScript(const AScript: string);
begin
  inherited;
end;

procedure TFactorySQLite.ExecuteScripts;
begin
  inherited;
end;

function TFactorySQLite.GetDriverName: TDriverName;
begin
  inherited;
  Result := FDriverConnection.DriverName;
end;

function TFactorySQLite.IsConnected: Boolean;
begin
  inherited;
  Result := FDriverConnection.IsConnected;
end;

function TFactorySQLite.InTransaction: Boolean;
begin
  Result := FDriverTransaction.InTransaction;
end;

procedure TFactorySQLite.StartTransaction;
begin
  inherited;
  FDriverTransaction.StartTransaction;
end;

procedure TFactorySQLite.AddScript(const AScript: string);
begin
  inherited;
  FDriverConnection.AddScript(AScript);
end;

procedure TFactorySQLite.Commit;
begin
  FDriverTransaction.Commit;
  inherited;
end;

procedure TFactorySQLite.Rollback;
begin
  FDriverTransaction.Rollback;
  inherited;
end;

end.
