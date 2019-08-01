unit ormbr.connection.zeos.reg;

interface

uses
  Classes,
  DesignIntf,
  DesignEditors,
  ormbr.connection.zeos;

procedure register;

implementation

procedure register;
begin
  RegisterComponents('ORMBr', [TORMBrConnectionZeos]);
end;

end.
