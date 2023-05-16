unit tests.driver.zeos;

{$mode objfpc}{$H+}

interface

uses
  DB,
  Classes, SysUtils, fpcunit, testutils, testregistry,

  ZConnection,
  dbebr.factory.interfaces;

type

  { TTestDBEBrZeos }

  TTestDBEBrZeos= class(TTestCase)
  strict private
    FConnection: TZConnection;
    FDBConnection: IDBConnection;
    FDBQuery: IDBQuery;
    FDBResultSet: IDBResultSet;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestConnect;
    procedure TestDisconnect;
    procedure TestExecuteDirect;
    procedure TestExecuteDirectParams;
    procedure TestExecuteScript;
    procedure TestAddScript;
    procedure TestExecuteScripts;
    procedure TestIsConnected;
    procedure TestInTransaction;
    procedure TestCreateQuery;
    procedure TestCreateResultSet;
    procedure TestStartTransaction;
    procedure TestCommit;
    procedure TestRollback;
  end;

implementation

uses
  dbebr.factory.zeos,
  Tests.Consts;

procedure TTestDBEBrZeos.TestConnect;
begin
  FDBConnection.Connect;
  AssertEquals('FConnection.IsConnected = true', True, FDBConnection.IsConnected);
end;

procedure TTestDBEBrZeos.TestDisconnect;
begin
  FDBConnection.Disconnect;
  AssertEquals('FConnection.IsConnected = false', False, FDBConnection.IsConnected);
end;

procedure TTestDBEBrZeos.TestExecuteDirect;
var
  LValue: String;
  LRandon: String;
begin
  LRandon := IntToStr( Random(9999) );

  FDBConnection.ExecuteDirect( Format(cSQLUPDATE, [QuotedStr(cDESCRIPTION + LRandon), '1']) );

  FDBQuery := FDBConnection.CreateQuery;
  FDBQuery.CommandText := Format(cSQLSELECT, ['1']);
  LValue := FDBQuery.ExecuteQuery.FieldByName('CLIENT_NAME').AsString;

  AssertEquals(LValue + ' <> ' + cDESCRIPTION + LRandon, LValue, cDESCRIPTION + LRandon);
end;

procedure TTestDBEBrZeos.TestExecuteDirectParams;
var
  LParams: TParams;
  LRandon: String;
  LValue: String;
begin
  LRandon := IntToStr( Random(9999) );

  LParams := TParams.Create(nil);
  try
    with LParams.Add as TParam do
    begin
      Name := 'CLIENT_NAME';
      DataType := ftString;
      Value := cDESCRIPTION + LRandon;
      ParamType := ptInput;
    end;
    with LParams.Add as TParam do
    begin
      Name := 'CLIENT_ID';
      DataType := ftInteger;
      Value := 1;
      ParamType := ptInput;
    end;
    FDBConnection.ExecuteDirect(cSQLUPDATEPARAM, LParams);

    FDBResultSet := FDBConnection.CreateResultSet(Format(cSQLSELECT, ['1']));
    LValue := FDBResultSet.FieldByName('CLIENT_NAME').AsString;

    AssertEquals(LValue + ' <> ' + cDESCRIPTION + LRandon, LValue, cDESCRIPTION + LRandon);
  finally
    LParams.Free;
  end;
end;

procedure TTestDBEBrZeos.TestExecuteScript;
begin

end;

procedure TTestDBEBrZeos.TestAddScript;
begin

end;

procedure TTestDBEBrZeos.TestExecuteScripts;
begin

end;

procedure TTestDBEBrZeos.TestIsConnected;
begin
  AssertEquals('FConnection.IsConnected = false', false, FDBConnection.IsConnected);
end;

procedure TTestDBEBrZeos.TestInTransaction;
begin
  FDBConnection.Connect;
  FDBConnection.StartTransaction;

  AssertEquals('FConnection.InTransaction <> FFDConnection.InTransaction', FDBConnection.InTransaction, FConnection.InTransaction);

  FDBConnection.Rollback;
  FDBConnection.Disconnect;
end;

procedure TTestDBEBrZeos.TestCreateQuery;
var
  LValue: String;
  LRandon: String;
begin
  LRandon := IntToStr( Random(9999) );

  FDBQuery := FDBConnection.CreateQuery;
  FDBQuery.CommandText := Format(cSQLUPDATE, [QuotedStr(cDESCRIPTION + LRandon), '1']);
  FDBQuery.ExecuteDirect;

  FDBQuery.CommandText := Format(cSQLSELECT, ['1']);
  LValue := FDBQuery.ExecuteQuery.FieldByName('CLIENT_NAME').AsString;

  AssertEquals(LValue + ' <> ' + cDESCRIPTION + LRandon, LValue, cDESCRIPTION + LRandon);
end;

procedure TTestDBEBrZeos.TestCreateResultSet;
begin
  FDBResultSet := FDBConnection.CreateResultSet(Format(cSQLSELECT, ['1']));

  AssertEquals('FDBResultSet.RecordCount = ' + IntToStr(FDBResultSet.RecordCount), 1, FDBResultSet.RecordCount);
end;

procedure TTestDBEBrZeos.TestStartTransaction;
begin
  FDBConnection.StartTransaction;
  AssertEquals('FConnection.InTransaction = true', True, FDBConnection.InTransaction);
end;

procedure TTestDBEBrZeos.TestCommit;
begin
  TestStartTransaction;

  FDBConnection.Commit;
  AssertEquals('FConnection.InTransaction = false', False, FDBConnection.InTransaction);
end;

procedure TTestDBEBrZeos.TestRollback;
begin
  TestStartTransaction;

  FDBConnection.Rollback;
  AssertEquals('FConnection.InTransaction = false', False, FDBConnection.InTransaction);
end;

procedure TTestDBEBrZeos.SetUp;
begin
  FConnection := TZConnection.Create(nil);
  FConnection.LoginPrompt := False;
  FConnection.Protocol := 'sqlite';
  FConnection.Database := 'database.db3';

  FDBConnection := TFactoryUniDAC.Create(FConnection, dnSQLite);
end;

procedure TTestDBEBrZeos.TearDown;
begin
  if Assigned(FConnection) then
    FreeAndNil(FConnection);
end;

initialization
  RegisterTest(TTestDBEBrZeos);

end.

