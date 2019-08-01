unit ormbr.connection.unidac.reg;

interface

uses
  Classes,
  DesignIntf,
  DesignEditors,
  ormbr.connection.unidac;

procedure register;

implementation

procedure register;
begin
  RegisterComponents('ORMBr', [TORMBrConnectionUniDAC]);
end;

end.
