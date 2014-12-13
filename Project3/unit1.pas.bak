unit Unit1;

{$mode objfpc}{$H+}

interface

uses
	Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,Unit2;

type

	{ TForm1 }

	TForm1 = class(TForm)
    PrzyciskTesty: TButton;
    OpenDialog1: TOpenDialog;
    PrzyciskZamknij: TButton;
    PrzyciskRozpocznij: TButton;
    Label1: TLabel;
    procedure PrzyciskTestyClick(Sender: TObject);
    procedure PrzyciskRozpocznijClick(Sender: TObject);
    procedure PrzyciskZamknijClick(Sender: TObject);
  	private
    { private declarations }
  	public
    { public declarations }
  	end;

var
  	Form1: TForm1;
implementation

{$R *.lfm}

{ TForm1 }
var
	plikTestu : String;
procedure TForm1.PrzyciskZamknijClick(Sender: TObject);
{Zamykamy formę}
begin
  	Close();
end;

procedure TForm1.PrzyciskRozpocznijClick(Sender: TObject);
{Inicjujemy i pokazujemy formę ze zdaniami.}

begin
  	Form2.Show();
  	AssignFile(Form2.plik,plikTestu);
  	reset(Form2.plik);
  	Form2.poprawne := 0;
  	Form2.bledne := 0;
  	Form2.numerTestu := 0;
    Form2.sprawdzone := true;
end;

procedure TForm1.PrzyciskTestyClick(Sender: TObject);
{Wybieramy plik z testami.}
begin
  	if OpenDialog1.Execute then
		plikTestu := OpenDialog1.FileName;
end;



end.

