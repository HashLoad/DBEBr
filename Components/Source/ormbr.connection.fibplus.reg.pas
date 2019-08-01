unit ormbr.connection.fibplus.reg;

interface

uses
  Classes,
  DesignIntf,
  DesignEditors,
  ormbr.connection.fibplus;

procedure register;

implementation

procedure register;
begin
  RegisterComponents('ORMBr', [TORMBrConnectionFIBPlus]);
end;

end.
