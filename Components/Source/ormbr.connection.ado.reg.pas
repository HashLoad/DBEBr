unit ormbr.connection.ado.reg;

interface

uses
  Classes,
  DesignIntf,
  DesignEditors,
  ormbr.connection.ado;

procedure register;

implementation

procedure register;
begin
  RegisterComponents('ORMBr', [TORMBrConnectionADO]);
end;

end.
