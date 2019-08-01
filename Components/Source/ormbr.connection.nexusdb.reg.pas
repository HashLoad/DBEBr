unit ormbr.connection.nexusdb.reg;

interface

uses
  Classes,
  DesignIntf,
  DesignEditors,
  ormbr.connection.nexusdb;

procedure register;

implementation

procedure register;
begin
  RegisterComponents('ORMBr', [TORMBrConnectionNexusDB]);
end;

end.
