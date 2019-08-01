unit ormbr.connection.ibobjects.reg;

interface

uses
  Classes,
  DesignIntf,
  DesignEditors,
  ormbr.connection.ibobjects;

procedure register;

implementation

procedure register;
begin
  RegisterComponents('ORMBr', [TORMBrConnectionIBObjects]);
end;

end.
