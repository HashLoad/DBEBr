{
      ORM Brasil � um ORM simples e descomplicado para quem utiliza Delphi

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

{ @abstract(ORMBr Framework.)
  @created(20 Jul 2016)
  @author(Isaque Pinheiro <isaquepsp@gmail.com>)
  @author(Skype : ispinheiro)
  @abstract(Website : http://www.ormbr.com.br)
  @abstract(Telagram : https://t.me/ormbr)
}

unit dbebr.connection.base;

interface

uses
  DB,
  SysUtils,
  Classes,
  dbebr.driver.connection,
  dbebr.factory.connection,
  dbebr.factory.interfaces;

type
  {$IF CompilerVersion > 23}
  [ComponentPlatformsAttribute(pidWin32 or
                               pidWin64 or
                               pidOSX32 or
                               pidiOSSimulator or
                               pidiOSDevice or
                               pidAndroid)]
  {$IFEND}
  TDBEBrConnectionBase = class(TComponent)
  protected
    FDBConnection: IDBConnection;
    FDriverName: TDriverName;
    function GetDBConnection: IDBConnection;
  public
    constructor Create(const AOwner: TComponent); virtual;
    destructor Destroy; override;
    procedure Connect;
    procedure Disconnect;
    procedure StartTransaction;
    procedure Commit;
    procedure Rollback;
    procedure ExecuteDirect(const ASQL: string); overload;
    procedure ExecuteDirect(const ASQL: string; const AParams: TParams); overload;
    procedure ExecuteScript(const AScript: string);
    procedure AddScript(const AScript: string);
    procedure ExecuteScripts;
    procedure SetCommandMonitor(AMonitor: ICommandMonitor);
    function InTransaction: Boolean;
    function IsConnected: Boolean;
    function CreateQuery: IDBQuery;
    function CreateResultSet(const ASQL: String): IDBResultSet;
    function CommandMonitor: ICommandMonitor;
    function DBConnection: IDBConnection;
  published
    property DriverName: TDriverName read FDriverName write FDriverName;
  end;

implementation

{ TDBEBrConnectionBase }

constructor TDBEBrConnectionBase.Create(const AOwner: TComponent);
begin

end;

destructor TDBEBrConnectionBase.Destroy;
begin

  inherited;
end;

procedure TDBEBrConnectionBase.AddScript(const AScript: string);
begin
  GetDBConnection.AddScript(AScript);
end;

function TDBEBrConnectionBase.CommandMonitor: ICommandMonitor;
begin
  Result := GetDBConnection.CommandMonitor;
end;

procedure TDBEBrConnectionBase.Commit;
begin
  GetDBConnection.Commit;
end;

procedure TDBEBrConnectionBase.Connect;
begin
  GetDBConnection.Connect;
end;

function TDBEBrConnectionBase.DBConnection: IDBConnection;
begin
  Result := GetDBConnection;
end;

function TDBEBrConnectionBase.CreateQuery: IDBQuery;
begin
  Result := GetDBConnection.CreateQuery;
end;

function TDBEBrConnectionBase.CreateResultSet(
  const ASQL: String): IDBResultSet;
begin
  Result := GetDBConnection.CreateResultSet(ASQL);
end;

procedure TDBEBrConnectionBase.Disconnect;
begin
  GetDBConnection.Disconnect;
end;

procedure TDBEBrConnectionBase.ExecuteDirect(const ASQL: string);
begin
  GetDBConnection.ExecuteDirect(ASQL);
end;

procedure TDBEBrConnectionBase.ExecuteDirect(const ASQL: string;
  const AParams: TParams);
begin
  GetDBConnection.ExecuteDirect(ASQL, AParams);
end;

procedure TDBEBrConnectionBase.ExecuteScript(const AScript: string);
begin
  GetDBConnection.ExecuteScript(AScript);
end;

procedure TDBEBrConnectionBase.ExecuteScripts;
begin
  GetDBConnection.ExecuteScripts;
end;

function TDBEBrConnectionBase.GetDBConnection: IDBConnection;
begin
//  if FDBConnection = nil then
//    raise Exception.Create('Connection property not set!');
  Result := FDBConnection;
end;

function TDBEBrConnectionBase.InTransaction: Boolean;
begin
  Result := GetDBConnection.InTransaction;
end;

function TDBEBrConnectionBase.IsConnected: Boolean;
begin
  Result := GetDBConnection.IsConnected;
end;

procedure TDBEBrConnectionBase.Rollback;
begin
  GetDBConnection.Rollback;
end;

procedure TDBEBrConnectionBase.SetCommandMonitor(AMonitor: ICommandMonitor);
begin
  GetDBConnection.SetCommandMonitor(AMonitor);
end;

procedure TDBEBrConnectionBase.StartTransaction;
begin
  GetDBConnection.StartTransaction;
end;

end.
