unit Unit2;
{Ustawiam tab = 4 spacje}

{$mode objfpc}{$H+}

interface

uses
  	Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  	StdCtrls;

type

  { TForm2 }

  	TForm2 = class(TForm)
    Bledy: TLabel;
    LicznikBledow: TLabel;
    LicznikPoprawnych: TLabel;
    Poprawnych: TLabel;
    LicznikTestu: TLabel;
    Test: TLabel;
    PrzyciskNastepne: TButton;
    PrzyciskZamknij: TButton;
    PanelMagazyn: TPanel;
    PanelZdanie: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure LicznikPoprawnychClick(Sender: TObject);
    procedure PrzyciskNastepneClick(Sender: TObject);
    procedure PrzyciskZamknijClick(Sender: TObject);
    procedure OnClickMagazynTLabel(Sender : TObject);
    procedure OnClickZdanieTLabel(Sender : TObject);
    procedure OnClickDoNothing(Sender : TObject);
  	private
    { private declarations }
  	public
    { public declarations }
     	plik : Text;
    	numerTestu : Integer;
     	poprawne : Integer;
     	bledne : Integer;
        sprawdzone : Boolean;
  	end;
  	LabelList = ^elemListy;
  	elemListy = record
    	w : TLabel;
    	nast : LabelList;
  	end;

var
  	Form2: TForm2;


implementation

{$R *.lfm}

{ TForm2 }
var
    listZdanie : LabelList;
    listMagazyn : LabelList;
    listOdpowiedzi : LabelList;
    nowy : TLabel;
    luki : Integer;
    slowoPamietane : String;
procedure TForm2.FormCreate(Sender: TObject);
begin

end;

procedure TForm2.LicznikPoprawnychClick(Sender: TObject);
begin

end;

procedure dopasuj(l : LabelList; sizeX : Integer; sizeY : Integer);
{Dopasowujemy tekst do panelu}
begin
    if l <> nil then
    begin
    	if l^.w.Width + sizeX < Form2.PanelZdanie.width then
    	begin
      		l^.w.Left := sizeX;
      		l^.w.Top := sizeY;
      		dopasuj(l^.nast, sizeX + l^.w.Width +5, sizeY);
      	end
      	else
      	begin
      		l^.w.left := 0;
      		l^.w.Top:= sizeY + l^.w.Height +5;
      		dopasuj(l^.nast, l^.w.width +5, sizeY + l^.w.height + 5);
      	end;
      	Form2.repaint;
    end;
end;

procedure wstaw(var l : LabelList; lab : TLabel);
{Wstawiamy TLabel do listy}
var
    help : LabelList;
    przejdz : LabelList;
begin
    if l <> nil then
    begin
    	przejdz := l;
    	while przejdz^.nast <> nil do
      	begin
       		przejdz := przejdz^.nast;
      	end;
      	new(help);
     	help^.w := lab;
      	help^.nast := nil;
      	przejdz^.nast := help;
    end
    else
    begin
    	new(help);
        help^.w := lab;
		help^.nast := nil;
        l := help;
    end;
end;

procedure usun(var l : LabelList);
{Usuwamy całą LabelListe }
var
    help : LabelList;
begin
	if l <> nil then
	begin
    	if l^.w <> nil then
        	l^.w.free;
        help := l^.nast;
        dispose(l);
        l := help;
        usun(l);
    end;
end;

procedure usunZListy(var l : LabelList;lab : TLabel);
{Ustawiamy TLabel na niewidoczny}
var
    poczatek : LabelList;
begin
	if l <> nil then
    begin
      	poczatek := l;
      	if (l^.w <> nil) and ( l^.w <> lab) then
        begin
    	while (l^.nast <>  nil) and (l^.nast^.w <> nil) and (l^.nast^.w <> lab) do
        	l := l^.nast;
        if (l^.nast <> nil) and (l^.nast^.w <> nil) and (l^.nast^.w = lab) then
       	begin
            l^.nast^.w.Caption :='';
       	end;
       	end
       	else
       	begin
           	if l^.w <> nil then
           		l^.w.caption :='';
           	poczatek := l;
       	end;
       	l := poczatek;
    end;
end;

procedure TForm2.OnClickMagazynTLabel(Sender : TObject);
{Gdy klikamy na słowo z magazynu.}
begin
    if luki > 0 then
    begin
    	if sender is TLabel then
    	begin
    		if slowoPamietane = '' then
    		begin
				slowoPamietane := (TLabel(sender)).Caption;
    			usunZListy(listMagazyn,(TLabel(sender)));
    			dopasuj(listMagazyn,0,0);
    		end;
    	end;
    end;
end;

procedure sprawdz(l,odp : LabelList);
{Sprawdza czy poprawnie czy źle wstawiliśmy.}
begin
    if not Form2.sprawdzone then
    begin
	    while (l <> nil) and (odp <> nil) do
    	begin
        	if odp^.w.caption[1] = '*' then
        	begin
    			if '*'+l^.w.Caption = odp^.w.caption then
       			begin
        			l^.w.Font.Color := clGreen;
            		Form2.poprawne := Form2.poprawne +1;
        		end
        		else
        		begin
        			l^.w.Font.Color := clRed;
        			Form2.bledne := Form2.bledne +1;
        		end;
        	end;
        	l := l^.nast;
        	odp := odp^.nast;
    	end;
    	Form2.LicznikPoprawnych.Caption := IntToStr(Form2.poprawne);
    	Form2.LicznikBledow.Caption := IntToStr(Form2.bledne);
        Form2.sprawdzone := true;
    end;
end;

procedure TForm2.OnClickDoNothing(Sender : TObject);
{Nic nie robimy.}
begin

end;

procedure ustawNieKlikalne(l : LabelList);
{Ustawiamy po wstawieniu wszystkich TLabel w luki na nieprzenoszenie.}
begin
	while l <> nil do
    begin
        if l^.w <> nil then
        begin
        	l^.w.OnClick := @Form2.OnClickDoNothing;
        end;
        l := l^.nast;
    end;
end;

procedure TForm2.OnClickZdanieTLabel(Sender : TObject);
{Gdy klikamy na slowo w luce w zdaniu.}
var
   	pom : String;
begin
    if sender is TLabel then
    begin
    	if TLabel(sender).Caption =  '...' then
    	begin
    		if slowoPamietane <> '' then
   			begin
   	 			TLabel(sender).Caption := slowoPamietane;
   	 			dopasuj(listZdanie,0,0);
            	slowoPamietane := '';
            	luki := luki - 1;
            	if luki = 0 then
            	begin
            		sprawdz(listZdanie,listOdpowiedzi);
                	ustawNieKlikalne(listZdanie);
            	end;
			end;
   		end
    	else if slowoPamietane <> '' then
    	begin
    		pom := TLabel(sender).Caption;
    		TLabel(sender).Caption := slowoPamietane;
        	slowoPamietane := pom;
        	dopasuj(listZdanie,0,0);
        	if luki = 0 then
        		ustawNieKlikalne(listZdanie);
    	end
    	else
    	begin
       		slowoPamietane := TLabel(sender).Caption;
       		TLabel(sender).Caption :='...';
       		dopasuj(listZdanie,0,0);
       		luki := luki + 1;
    	end;
    end;
end;

procedure TForm2.PrzyciskNastepneClick(Sender: TObject);
{Klikanie przycisku następny, wczytujemy kolejne zdanie i tworzymy odpowiednie listy z TLabelami.}
var
   	stop : Boolean;
	zdanie : String;
	poczatek : LabelList;
	s : String;
	slowo : String;
	i : Integer;
	j,k : Integer;
begin
	i := 0;
	slowoPamietane := '';
	stop := false;
	luki := 0;
    if not Form2.sprawdzone then
    	sprawdz(listZdanie,listOdpowiedzi);
    Form2.sprawdzone := false;
	usun(listZdanie);
	usun(listMagazyn);
	usun(listOdpowiedzi);
	if eof(plik) then
	begin
		Form2.PanelZdanie.Caption := 'KONIEC';
	end;
	while (not eof(Form2.plik)) and (not Stop) do
	begin
		readln(Form2.plik,zdanie);
		j := 1;
		k := 1;
 		if i = 0 then
		begin
			while (length(zdanie)>= k) and ( zdanie[k] <> '') do
			begin
				while (length(zdanie) >= j) and ( zdanie[j] <> ' ') do
				begin
					j := j+1;
				end;
				s := Copy(zdanie,k,j-k);
				j:= j+1;
				nowy := TLabel.Create(self);
				nowy.Font.Height:= 30;
				nowy.parent := Form2.PanelZdanie;
				nowy.caption := s;
				if s = '...' then
				begin
					nowy.OnClick := @OnClickZdanieTLabel;
					luki := luki+1;
                end;
                k := j;
				wstaw(listZdanie,nowy);
			end;
      	end
		else if i = 1 then
		begin
			while (length(zdanie)>= k) and ( zdanie[k] <> '') do
			begin
				while (length(zdanie) >= j) and ( zdanie[j] <> ' ') do
				begin
					j := j+1;
				end;
				s := Copy(zdanie,k,j-k);
				j:= j+1;
				nowy := TLabel.Create(self);
				nowy.Font.Height:= 30;
				nowy.parent := Form2.PanelMagazyn;
				nowy.caption := s;
				nowy.onClick := @OnClickMagazynTLabel;
				k := j;
				wstaw(listMagazyn,nowy);
			end;
		end
		else if i = 2 then
		begin
			while (length(zdanie)>= k) and ( zdanie[k] <> '') do
			begin
				while (length(zdanie) >= j) and ( zdanie[j] <> ' ') do
				begin
					j := j+1;
				end;
				s := Copy(zdanie,k,j-k);
				j:= j+1;
				nowy := TLabel.Create(self);
				nowy.caption := s;
				k := j;
				wstaw(listOdpowiedzi,nowy);
			end;
			stop := true;
			numerTestu := numerTestu +1;
			LicznikTestu.Caption := IntToStr(numerTestu);
		end
		else
			break;
		i := i+1;
	end;
	dopasuj(listZdanie,0,0);
	dopasuj(listMagazyn,0,0);


end;

procedure TForm2.PrzyciskZamknijClick(Sender: TObject);
{Zamykamy formę i usuwamy z pamięci listy.}
begin
	Form2.PanelZdanie.Caption := '';
	usun(listZdanie);
	usun(listMagazyn);
	usun(listOdpowiedzi);
	LicznikTestu.Caption := '0';
	LicznikPoprawnych.Caption:= '0';
	LicznikBledow.Caption := '0';
    Close();
end;

end.

