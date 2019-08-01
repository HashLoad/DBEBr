unit ormbr.connection.dbexpress.reg;

interface

uses
  Classes,
  DesignIntf,
  DesignEditors,
  ormbr.connection.dbexpress;

procedure register;

implementation

procedure register;
begin
  RegisterComponents('ORMBr', [TORMBrConnectionDBExpress]);
end;

end.
