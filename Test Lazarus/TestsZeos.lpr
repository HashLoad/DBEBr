program TestsZeos;

{$mode objfpc}{$H+}

uses
  Interfaces, Forms, GuiTestRunner, Tests.Driver.Zeos, Tests.Consts;

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TGuiTestRunner, TestRunner);
  Application.Run;
end.

