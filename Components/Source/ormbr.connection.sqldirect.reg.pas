unit ormbr.connection.sqldirect.reg;

interface

uses
  Classes,
  DesignIntf,
  DesignEditors,
  ormbr.connection.sqldirect;

procedure register;

implementation

procedure register;
begin
  RegisterComponents('ORMBr', [TORMBrConnectionSQLDirect]);
end;

end.
