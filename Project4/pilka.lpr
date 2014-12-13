program pilka;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, Start, Gra, Boisko, GraczAI;

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TFormularzStartowy, FormularzStartowy);
  Application.CreateForm(TFormularzGry, FormularzGry);
  Application.Run;
end.

