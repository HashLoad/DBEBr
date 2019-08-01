unit ormbr.connection.firedac.reg;

interface

uses
  Classes,
  DesignIntf,
  DesignEditors,
  ormbr.connection.firedac;

procedure register;

implementation

procedure register;
begin
  RegisterComponents('ORMBr', [TORMBrConnectionFireDAC]);
end;

end.
