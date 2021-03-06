unit Gra;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls,Boisko, LCLType, ComCtrls, GraczAI;

type

  { TFormularzGry }

  TFormularzGry = class(TForm)
    PrzyciskWrocCalyRuch: TButton;
    PrzyciskCofnijCalyRuch: TButton;
    Image3: TImage;
    LabelGraczEdytor: TLabel;
    LabelWysokosc: TLabel;
    LabelSzerokosc: TLabel;
    ListBoxGracz: TListBox;
    PrzyciskZakonczEdytowanie: TButton;
    PrzyciskEdytuj: TButton;
    Image1: TImage;
    Image2: TImage;
    Image5: TImage;
    Image6: TImage;
    LabelBramka2: TLabel;
    LabelBramka1: TLabel;
    PanelEdytora: TPanel;
    PrzyciskPrzerwij: TButton;
    LabelRuch: TLabel;
    LabelGracz: TLabel;
    LabelAktualnyGracz: TLabel;
    OpenDialog1: TOpenDialog;
    PrzyciskWznow: TButton;
    PrzyciskWroc: TButton;
    PrzyciskWstecz: TButton;
    PrzyciskHint: TButton;
    PrzyciskWczytaj: TButton;
    PrzyciskZapisz: TButton;
    PrzyciskZamknij: TButton;
    PanelBoiska: TPanel;
    SaveDialog1: TSaveDialog;
    Timer1: TTimer;
    TrackBarWysokosc: TTrackBar;
    TrackBarSzerokosc: TTrackBar;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure Image2Click(Sender: TObject);
    procedure Image3Click(Sender: TObject);
    procedure Image5Click(Sender: TObject);
    procedure Image6Click(Sender: TObject);
    procedure ListBoxGraczSelectionChange(Sender: TObject; User: boolean);
    procedure PrzyciskCofnijCalyRuchClick(Sender: TObject);
    procedure PrzyciskEdytujClick(Sender: TObject);
    procedure PrzyciskHintClick(Sender: TObject);
    procedure PrzyciskPrzerwijClick(Sender: TObject);
    procedure PrzyciskWczytajClick(Sender: TObject);
    procedure PrzyciskWrocCalyRuchClick(Sender: TObject);
    procedure PrzyciskWrocClick(Sender: TObject);
    procedure PrzyciskWsteczClick(Sender: TObject);
    procedure PrzyciskWznowClick(Sender: TObject);
    procedure PrzyciskZakonczEdytowanieClick(Sender: TObject);
    procedure PrzyciskZamknijClick(Sender: TObject);
    procedure PrzyciskZapiszClick(Sender: TObject);
    procedure Timer1StartTimer(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure TrackBarSzerokoscChange(Sender: TObject);
    procedure TrackBarWysokoscChange(Sender: TObject);
    procedure zaladujObrazek;
  private
    { private declarations }
  public
    { public declarations }
  end;


var
  FormularzGry: TFormularzGry;
  wysokosc, szerokosc : LongInt;
  boiskoGry : TBoisko;
  pilkax,pilkay : LongInt;
  game : Boolean;
  trybRozgrywki : LongInt;
  wyswietl : Boolean;
  odczekanychSekund : LongInt;
  graj : Boolean;
  czekajPoCofaniu : LongInt;
  edytowany : Boolean;

implementation
{$R *.lfm}

{ TFormularzGry }
const
  MAX_SEKUND = 20; //Ilość interwałów jakie czeka komputer przy każdym ruchu.
  MAX_SEKUND1 = 150; //Ilość interwałów jakie czeka komputer po cofnięciu.
var
  wybrany : LongInt;
  aktGracz : Boolean;
  kliknietyRysunek : TImage;


procedure TFormularzGry.PrzyciskZamknijClick(Sender: TObject);
//Zamykamy.
begin
  Close;
end;

procedure TFormularzGry.PrzyciskZapiszClick(Sender: TObject);
//Zapisujemy grę.
begin
  game := false;
  if SaveDialog1.Execute then
  begin
    Boisko.zapiszDoPliku(SaveDialog1.FileName);
    ShowMessage('Gra została zapisana');
  end
  else
  begin
    ShowMessage('Gra nie została zapisana');
  end;
  game := true;
end;

procedure TFormularzGry.Timer1StartTimer(Sender: TObject);
begin

end;

procedure TFormularzGry.Timer1Timer(Sender: TObject);
//Główna pętla gry zrealizowana w TTimerze.
var
  wykonanyRuch : Boolean;
begin
  TrackBarSzerokosc.Max := Boisko.szerokosc;
  TrackBarSzerokosc.Min := 1;
  TrackBarWysokosc.Max := Boisko.wysokosc;
  TrackBarWysokosc.Min := 1;
  if game then
  begin
    PrzyciskHint.Enabled := true;
    PanelEdytora.Enabled := false;
    if Boisko.wygral1 then
    begin
      LabelRuch.Caption:= 'Wygrał 1';
      game := false;
      PanelBoiska.Enabled:= false;
    end
    else if Boisko.wygral2 then
    begin
      LabelRuch.Caption:= 'Wygrał 2';
      game := false;
      PanelBoiska.Enabled:= false;
    end
    else
      LabelRuch.Caption:= 'Proszę wykonać ruch';
    if Boisko.gracz <> aktGracz then
      ai.usunPodpowiedz(panelBoiska);
    if (czekajPoCofaniu <= MAX_SEKUND1) and (Boisko.trybGry <> 0) then
    begin
      graj := false;
      czekajPoCofaniu := czekajPoCofaniu -1;
    end;
    if (czekajPoCofaniu <= 0) and (Boisko.trybGry <> 0) then
    begin
      graj := true;
      czekajPoCofaniu := MAX_SEKUND1+1;
    end;
    if game and Boisko.gracz then
    begin
      LabelGracz.Caption:= ' 1';
      if (Boisko.trybGry <> 2) then
        PanelBoiska.Enabled := true;
      LabelBramka2.Font.Color := clYellow;
      LabelBramka1.Font.Color := clBlack;
      GraczAI.numerGracza:= 1;
      odczekanychSekund := odczekanychSekund+1;
      if graj and (odczekanychSekund >= MAX_SEKUND) and (Boisko.trybGry = 2) then
      begin
        odczekanychSekund := 0;
        ai.wykonajRuch;
      end;
      wykonanyRuch := not Boisko.gracz;
    end
    else if game then //and wykonanyRuch then
    begin
      LabelGracz.Caption:= ' 2';
      if (Boisko.trybGry <> 0) then
        PanelBoiska.Enabled := false;
      odczekanychSekund := odczekanychSekund+1;
      LabelBramka1.Font.Color := clYellow;
      LabelBramka2.Font.Color := clBlack;
      GraczAI.numerGracza:= 2;
      if graj and (odczekanychSekund >= MAX_SEKUND) and ((Boisko.trybGry = 1) or (Boisko.trybGry = 2)) then
      begin
        odczekanychSekund := 0;
        ai.wykonajRuch;
      end;
      wykonanyRuch := not Boisko.gracz;
    end;
  end
  else
  begin
    PrzyciskHint.Enabled := false;
  end;
  if edytowany then
  begin
    PanelEdytora.Enabled := true;
    PanelBoiska.Enabled := true;
    PrzyciskWroc.Enabled := false;
    PrzyciskWstecz.Enabled := false;
    PrzyciskPrzerwij.Enabled := false;
    PrzyciskWznow.Enabled := false;
    PrzyciskWczytaj.Enabled := false;
    PrzyciskZapisz.Enabled := false;
    PrzyciskWrocCalyRuch.Enabled := false;
    PrzyciskCofnijCalyRuch.Enabled := false;
  end
  else
  begin
    Boisko.wybranyRysunek := 0;
    kliknietyRysunek := nil;
    PrzyciskEdytuj.Enabled := true;
    PrzyciskWroc.Enabled := true;
    PrzyciskWstecz.Enabled := true;
    PrzyciskWrocCalyRuch.Enabled := true;
    PrzyciskCofnijCalyRuch.Enabled := true;
    PrzyciskPrzerwij.Enabled := true;
    PrzyciskWznow.Enabled := true;
    PrzyciskWczytaj.Enabled := true;
    PrzyciskZapisz.Enabled := true;
  end;
end;

procedure TFormularzGry.TrackBarSzerokoscChange(Sender: TObject);
//Wybieranie pozycji x piłki w edytorze.
begin
  polaKlikane[Boisko.pilkax][Boisko.pilkay].pilka := false;
  polaKlikane[Boisko.pilkax][Boisko.pilkay].Picture.LoadFromFile('obrazki/nieodw.png');
  Boisko.pilkax := TrackBarSzerokosc.Position;
  Boisko.pilkay := TrackBarWysokosc.Position;
  polaKlikane[Boisko.pilkax][Boisko.pilkay].pilka := true;
  polaKlikane[Boisko.pilkax][Boisko.pilkay].Picture.LoadFromFile('obrazki/pilka.png');
  polaKlikane[Boisko.pilkax][Boisko.pilkay].klikniete := true;
end;

procedure TFormularzGry.TrackBarWysokoscChange(Sender: TObject);
//Wybieranie pozycji y piłki w edytorze.
begin
  polaKlikane[Boisko.pilkax][Boisko.pilkay].pilka := false;
  polaKlikane[Boisko.pilkax][Boisko.pilkay].Picture.LoadFromFile('obrazki/nieodw.png');
  Boisko.pilkax := TrackBarSzerokosc.Position;
  Boisko.pilkay := TrackBarWysokosc.Position;
  polaKlikane[Boisko.pilkax][Boisko.pilkay].pilka := true;
  polaKlikane[Boisko.pilkax][Boisko.pilkay].Picture.LoadFromFile('obrazki/pilka.png');
  polaKlikane[Boisko.pilkax][Boisko.pilkay].klikniete := true;
end;


procedure TFormularzGry.FormCreate(Sender: TObject);
begin

end;

procedure TFormularzGry.FormClose(Sender: TObject; var CloseAction: TCloseAction
  );
//Gdy zamykamy formularz.
begin
  game := false;
  ai.usunPodpowiedz(panelBoiska);
  edytowany := false;
  zaladujObrazek;
  boiskoGry.usun;
end;


procedure TFormularzGry.FormShow(Sender: TObject);
begin
 // Boisko.trybGry := trybRozgrywki;
end;

procedure TFormularzGry.zaladujObrazek;
//Procedura załadowujaca niekliknięte obrazki.
begin
  if kliknietyRysunek = Image1 then
  begin
    Image1.Picture.LoadFromFile('obrazki/kreskal.png');
  end
  else if kliknietyRysunek = Image2 then
  begin
    Image2.Picture.LoadFromFile('obrazki/kreskag.png');
  end
  else if kliknietyRysunek = Image3 then
  begin
    Image3.Picture.LoadFromFile('obrazki/kreskad.png');
  end
  else if kliknietyRysunek = Image5 then
  begin
    Image5.Picture.LoadFromFile('obrazki/kreska15.png');
  end
  else if kliknietyRysunek = Image6 then
  begin
    Image6.Picture.LoadFromFile('obrazki/kreska37.png');
  end;
end;

//Pare procedure odpowiadających kliknięciu na odpowiednią kreskę w edytorze.
procedure TFormularzGry.Image1Click(Sender: TObject);
begin
  if kliknietyRysunek <> Image1 then
  begin
    zaladujObrazek;
  end;
  TImage(Sender).Picture.LoadFromFile('obrazki/kreskalpod.png');
  kliknietyRysunek := Image1;
  Boisko.wybranyRysunek := 2;
end;

procedure TFormularzGry.Image2Click(Sender: TObject);
begin
  if kliknietyRysunek <> Image2 then
  begin
    zaladujObrazek;
  end;
  TImage(Sender).Picture.LoadFromFile('obrazki/kreskagpod.png');
  kliknietyRysunek := Image2;
  Boisko.wybranyRysunek := 4;
end;

procedure TFormularzGry.Image3Click(Sender: TObject);
begin
  if kliknietyRysunek <> Image3 then
  begin
    zaladujObrazek;
  end;
  TImage(Sender).Picture.LoadFromFile('obrazki/kreskadpod.png');
  kliknietyRysunek := Image3;
  Boisko.wybranyRysunek := 9;
end;


procedure TFormularzGry.Image5Click(Sender: TObject);
begin
  if kliknietyRysunek <> Image5 then
  begin
    zaladujObrazek;
  end;
  TImage(Sender).Picture.LoadFromFile('obrazki/kreska15pod.png');
  kliknietyRysunek := Image5;
  Boisko.wybranyRysunek := 1;
end;

procedure TFormularzGry.Image6Click(Sender: TObject);
begin
  if kliknietyRysunek <> Image6 then
  begin
    zaladujObrazek;
  end;
  TImage(Sender).Picture.LoadFromFile('obrazki/kreska37pod.png');
  kliknietyRysunek := Image6;
  Boisko.wybranyRysunek := 3;
end;


procedure TFormularzGry.ListBoxGraczSelectionChange(Sender: TObject;
  User: boolean);
begin
  Boisko.gracz := ListBoxGracz.ItemIndex = 0;
end;

procedure TFormularzGry.PrzyciskCofnijCalyRuchClick(Sender: TObject);
var
  aktualnyGracz : Boolean;
begin
  if Boisko.numerRuchu > 0 then
  begin
    PrzyciskWstecz.Click;
    aktualnyGracz :=  Boisko.gracz;
    while (aktualnyGracz = Boisko.gracz) and (Boisko.numerRuchu > 0) do
      PrzyciskWstecz.Click;
    if Boisko.gracz <> aktualnyGracz then
      PrzyciskWroc.Click;
  end
  else
  begin
    ShowMessage('Nie wykonałeś jeszcze żadnego ruchu, nie możesz cofnąć');
  end;
end;



procedure TFormularzGry.PrzyciskEdytujClick(Sender: TObject);
//Gdy zaczynamy edytować.
var
  wybranyPrzycisk : LongInt;
begin
  wybranyPrzycisk := MessageDlg('Edytowanie trwale usuwa historię rozgrywki. Na pewno chcesz kontynuować?',mtCustom, [mbYes,mbNo], 0);
  if wybranyPrzycisk = mrYes then
  begin
    Boisko.usunPrzyszleRuchy;
    Boisko.wylaczPola;
    edytowany := true;
    game := false;
    PrzyciskEdytuj.Enabled := false;
    PrzyciskZakonczEdytowanie.Enabled := true;
  end;
end;

procedure TFormularzGry.PrzyciskHintClick(Sender: TObject);
//Podpowiedź.
begin
  aktGracz := Boisko.gracz;
  ai.usunPodpowiedz(panelBoiska);
  ai.zaznaczPodpowiedz(panelBoiska);
end;

procedure TFormularzGry.PrzyciskPrzerwijClick(Sender: TObject);
//Przerywamy grę.
begin
  if not game then
    ShowMessage('Gra już jest przerwana albo się zakończyła')
  else
  begin
    game := false;
    PanelBoiska.Enabled := false;
  end;
end;

procedure TFormularzGry.PrzyciskWczytajClick(Sender: TObject);
//Wczytujemy grę z wybranego pliku.
begin
  game := false;
  if OpenDialog1.Execute then
  begin

    boiskoGry.usun;
    Boisko.wczytajZPliku(OpenDialog1.FileName, FormularzGry.panelBoiska);
    game := true;
    //panelBoiska.Repaint;
    ShowMessage('Wczytałem z pliku');
  end
  else
  begin
    ShowMessage('Nie wczytałem z pliku');
  end;
  game := true;
end;

procedure TFormularzGry.PrzyciskWrocCalyRuchClick(Sender: TObject);
var
  aktualnyGracz : Boolean;
begin
  if numerRuchu < wszystkichRuchow then
  begin
    aktualnyGracz := Boisko.gracz;
    while (aktualnyGracz = Boisko.gracz) and (Boisko.numerRuchu < Boisko.wszystkichRuchow) do
      PrzyciskWroc.Click;
    //PrzyciskWstecz.Click;
  end
  else
    ShowMessage('Nie ma więcej ruchów do przywrócenia');
end;

procedure TFormularzGry.PrzyciskWrocClick(Sender: TObject);
//Przywracamy ruch.
begin
  if numerRuchu < wszystkichRuchow then
  begin
    Boisko.numerRuchu := Boisko.numerRuchu + 1;
    Boisko.kolejnyStan(Boisko.historia[Boisko.numerRuchu]);
    czekajPoCofaniu := MAX_SEKUND1;
  end
  else
    ShowMessage('Nie ma więcej ruchów do przywrócenia');
end;


procedure TFormularzGry.PrzyciskWsteczClick(Sender: TObject);
//Cofamy ruch.
begin
 { if game then
  begin      }
    if Boisko.numerRuchu > 0 then
    begin
      Boisko.numerRuchu := Boisko.numerRuchu - 1;
      Boisko.poprzedniStan(Boisko.historia[Boisko.numerRuchu],1);
      czekajPoCofaniu := MAX_SEKUND1;
      if (Boisko.trybGry = 0)or ((Boisko.trybGry = 1) and (Boisko.gracz = true))then
        panelBoiska.Enabled := true;
      game := true;
    end
    else
    begin
      ShowMessage('Nie wykonałeś jeszcze żadnego ruchu, nie możesz cofnąć');
    end;
 { end
  else
    ShowMessage('Gra się już skończyła');  }
end;

procedure TFormularzGry.PrzyciskWznowClick(Sender: TObject);
//Wznowienie gry.
begin
  if game or Boisko.wygral1 or Boisko.wygral2 then
    showMessage('Gra już trwa albo któryś z graczy wygrał')
  else
    game := true;
end;

procedure TFormularzGry.PrzyciskZakonczEdytowanieClick(Sender: TObject);
//Zatwierdzenie edycji.
begin
  if edytowany then
  begin
    Boisko.wlaczPola;
    PrzyciskEdytuj.Enabled := true;
    PrzyciskZakonczEdytowanie.Enabled := false;
    game := true;
    edytowany := false;
    Boisko.usunHistorie;
    zaladujObrazek;
  end;
end;

end.

