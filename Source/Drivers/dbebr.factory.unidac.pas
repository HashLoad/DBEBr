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
  @created(25 julho 2017)
  @author(Marcos J O Nielsen <marcos@softniels.com.br>)
  @author(Skype : marcos@softniels.com.br)

  @author(Isaque Pinheiro <https://www.isaquepinheiro.com.br>)
}

unit dbebr.factory.unidac;

interface

uses
  DB,
  Classes,
  // DBEBr
  dbebr.factory.connection,
  dbebr.factory.interfaces;

type
  // Fábrica de conexão concreta com UniDAC
  TFactoryUniDAC = class(TFactoryConnection)
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
    procedure ExecuteDirect(const ASQL: string); overload; override;
    procedure ExecuteDirect(const ASQL: string;
      const AParams: TParams); overload; override;
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
  dbebr.driver.unidac,
  dbebr.driver.unidac.transaction;

{ TFactoryUniDAC }

procedure TFactoryUniDAC.Connect;
begin
  if not IsConnected then
    FDriverConnection.Connect;
end;

constructor TFactoryUniDAC.Create(const AConnection: TComponent;
  const ADriverName: TDriverName);
begin
  FDriverConnection  := TDriverUniDAC.Create(AConnection, ADriverName);
  FDriverTransaction := TDriverUniDACTransaction.Create(AConnection);
  FAutoTransaction := False;
end;

constructor TFactoryUniDAC.Create(const AConnection: TComponent;
  const ADriverName: TDriverName; const AMonitor: ICommandMonitor);
begin
  Create(AConnection, ADriverName);
  FCommandMonitor := AMonitor;
end;

constructor TFactoryUniDAC.Create(const AConnection: TComponent;
  const ADriverName: TDriverName; const AMonitorCallback: TMonitorProc);
begin
  Create(AConnection, ADriverName);
  FMonitorCallback := AMonitorCallback;
end;

function TFactoryUniDAC.CreateQuery: IDBQuery;
begin
  Result := FDriverConnection.CreateQuery;
end;

function TFactoryUniDAC.CreateResultSet(const ASQL: String): IDBResultSet;
begin
  Result := FDriverConnection.CreateResultSet(ASQL);
end;

destructor TFactoryUniDAC.Destroy;
begin
  FDriverTransaction.Free;
  FDriverConnection.Free;
  inherited;
end;

procedure TFactoryUniDAC.Disconnect;
begin
  inherited;
  if IsConnected then
    FDriverConnection.Disconnect;
end;

procedure TFactoryUniDAC.ExecuteDirect(const ASQL: string);
begin
  inherited;
end;

procedure TFactoryUniDAC.ExecuteDirect(const ASQL: string;
  const AParams: TParams);
begin
  inherited;
end;

procedure TFactoryUniDAC.ExecuteScript(const AScript: string);
begin
  inherited;
end;

procedure TFactoryUniDAC.ExecuteScripts;
begin
  inherited;
end;

function TFactoryUniDAC.GetDriverName: TDriverName;
begin
  inherited;
  Result := FDriverConnection.DriverName;
end;

function TFactoryUniDAC.IsConnected: Boolean;
begin
  inherited;
  Result := FDriverConnection.IsConnected;
end;

function TFactoryUniDAC.InTransaction: Boolean;
begin
  Result := FDriverTransaction.InTransaction;
end;

procedure TFactoryUniDAC.StartTransaction;
begin
  inherited;
  FDriverTransaction.StartTransaction;
end;

procedure TFactoryUniDAC.AddScript(const AScript: string);
begin
  inherited;
  FDriverConnection.AddScript(AScript);
end;

procedure TFactoryUniDAC.Commit;
begin
  FDriverTransaction.Commit;
  inherited;
end;

procedure TFactoryUniDAC.Rollback;
begin
  FDriverTransaction.Rollback;
  inherited;
end;

end.
