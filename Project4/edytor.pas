unit Edytor;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs;

type

  { TFormularzEdytora }

  TFormularzEdytora = class(TForm)
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  FormularzEdytora: TFormularzEdytora;

implementation

{$R *.lfm}

{ TFormularzEdytora }

procedure TFormularzEdytora.FormCreate(Sender: TObject);
begin

end;

end.

