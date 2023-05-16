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

unit dbebr.factory.zeos;

interface

uses
  DB,
  Classes,
  dbebr.factory.connection,
  dbebr.factory.interfaces;

type
  // Fábrica de conexão concreta com dbExpress
  TFactoryZeos = class(TFactoryConnection)
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
  dbebr.driver.zeos,
  dbebr.driver.zeos.transaction;

{ TFactoryZeos }

procedure TFactoryZeos.Connect;
begin
  if not IsConnected then
    FDriverConnection.Connect;
end;

constructor TFactoryZeos.Create(const AConnection: TComponent;
  const ADriverName: TDriverName);
begin
  FDriverConnection  := TDriverZeos.Create(AConnection, ADriverName);
  FDriverTransaction := TDriverZeosTransaction.Create(AConnection);
  FAutoTransaction := False;
end;

constructor TFactoryZeos.Create(const AConnection: TComponent;
  const ADriverName: TDriverName; const AMonitor: ICommandMonitor);
begin
  Create(AConnection, ADriverName);
  FCommandMonitor := AMonitor;
end;

constructor TFactoryZeos.Create(const AConnection: TComponent;
  const ADriverName: TDriverName; const AMonitorCallback: TMonitorProc);
begin
  Create(AConnection, ADriverName);
  FMonitorCallback := AMonitorCallback;
end;

function TFactoryZeos.CreateQuery: IDBQuery;
begin
  Result := FDriverConnection.CreateQuery;
end;

function TFactoryZeos.CreateResultSet(const ASQL: String): IDBResultSet;
begin
  Result := FDriverConnection.CreateResultSet(ASQL);
end;

destructor TFactoryZeos.Destroy;
begin
  FDriverTransaction.Free;
  FDriverConnection.Free;
  inherited;
end;

procedure TFactoryZeos.Disconnect;
begin
  if IsConnected then
    FDriverConnection.Disconnect;
end;

procedure TFactoryZeos.ExecuteDirect(const ASQL: string);
begin
  inherited;
end;

procedure TFactoryZeos.ExecuteDirect(const ASQL: string; const AParams: TParams);
begin
  inherited;
end;

procedure TFactoryZeos.ExecuteScript(const AScript: string);
begin
  inherited;
end;

procedure TFactoryZeos.ExecuteScripts;
begin
  inherited;
end;

function TFactoryZeos.GetDriverName: TDriverName;
begin
  Result := FDriverConnection.DriverName;
end;

function TFactoryZeos.IsConnected: Boolean;
begin
  Result := FDriverConnection.IsConnected;
end;

function TFactoryZeos.InTransaction: Boolean;
begin
  Result := FDriverTransaction.InTransaction;
end;

procedure TFactoryZeos.StartTransaction;
begin
  inherited;
  FDriverTransaction.StartTransaction;
end;

procedure TFactoryZeos.AddScript(const AScript: string);
begin
  FDriverConnection.AddScript(AScript);
end;

procedure TFactoryZeos.Commit;
begin
  FDriverTransaction.Commit;
  inherited;
end;

procedure TFactoryZeos.Rollback;
begin
  FDriverTransaction.Rollback;
  inherited;
end;

end.
