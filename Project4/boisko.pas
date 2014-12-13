unit Boisko;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls;
type
  TPole = class(TImage)
    function stworz(x,y,wysokosc,szerokosc,px,py : LongInt; t : TWinControl) : TPole;
    constructor Create(TheOwner : TComponent);
    procedure Click(Sender: TObject);
    private
      px,py : LongInt;
  end;
  TSciana = class(TPole)
    function stworz(x,y,wysokosc,szerokosc,kierunek : LongInt; t : TWinControl) : TSciana;
    constructor Create(TheOwner : TComponent);
    public var
      kierunek : LongInt;
  end;
  TPoleKlikalne = class(TImage)
    function stworz(x,y,wysokosc,szerokosc,px,py : LongInt; t : TWinControl) : TPoleKlikalne;
    constructor Create(TheOwner : TComponent);
    procedure MouseEnter(Sender: TObject);
    procedure MouseLeave(Sender: TObject);
    procedure Click(Sender: TObject);
    public
    var
    klikniete : Boolean;
    pilka : Boolean;
    x,y : LongInt;
    ruch : array [0..7] of Boolean;
  end;
  StanZapisu = record
     wysokosc,szerokosc : LongInt;
     trybGry : LongInt;
     poprzednix,poprzedniy,terazx,terazy : LongInt;
     numerRuchu : LongInt;
     gracz : LongInt;
     wygral1,wygral2 : LongInt;
  end;
  TablicaPol = array of array of TPole;
  TablicaScian = array of array of array [0..17] of TSciana;
  TablicaPolKlikalnych = array of array of TPoleKlikalne;
  TBoisko = class
    private
      procedure narysuj(szeroko,wysoko : LongInt; t : TWinControl);
      procedure zainicjujSciany(szer,wys : LongInt);
    public
    procedure stworz(szerokoscpodana, wysokoscpodana : LongInt; t : TWinControl );
    procedure usun;
    procedure polacz(x,y,px,py : LongInt; t : TWinControl);
  end;
  StanGry = record
     wysokosc,szerokosc : LongInt;
     trybGry : LongInt;
     poprzednix,poprzedniy,terazx,terazy : LongInt;
     numerRuchu : LongInt;
     gracz : Boolean;
     wygral1,wygral2 : Boolean;
  end;
  HistoriaGry = array of StanGry;
  PoleZapisu = record
     klikniete : LongInt;
     ruch : array [0..7] of LongInt;
  end;

  ScianyDoZapisu = array of array of array [0..17] of LongInt;
  PolaDoZapisu = array of array of PoleZapisu;
  procedure poprzedniStan(stan : StanGry; kontrolny : Integer);
  procedure kolejnyStan(stan : StanGry);
  procedure zapiszDoPliku(nazwa : String);
  procedure wczytajZPliku(nazwa : String; t : TWinControl);
  procedure wczytajSciane(var s : TSciana; kierunek : LongInt);
  procedure polaczPodpowiedz(x,y,kierunek : LongInt; t : TWinControl);
  procedure wylaczPola;
  procedure wlaczPola;
  procedure usunHistorie;
  procedure usunPrzyszleRuchy;

var
  boiskov : TBoisko;
  pilkax,pilkay : LongInt;
  gracz : Boolean;
  wygral1,wygral2 : Boolean;
  historia : HistoriaGry;
  wszystkichRuchow : LongInt;
  numerRuchu : LongInt;
  trybGry : LongInt;
  liczbaZapisow : LongInt;
  polaKlikane : TablicaPolKlikalnych;
  sciany : TablicaScian;
  szerokosc : LongInt;
  wysokosc : LongInt;
  wybranyRysunek : LongInt;
implementation

var
  pola : TablicaPol;
  bramka1,bramka2 : TPoleKlikalne;
  panelBoiska : TWinControl;
  poprzednix,poprzedniy,terazx,terazy : LongInt;

  constructor TPole.Create(TheOwner : TComponent);
  begin
    inherited Create(TheOwner);
  end;

  function TPole.stworz(x,y,wysokosc,szerokosc,px,py  : LongInt; t: TWinControl) : TPole;
  //Tworzymy kwadraty pola boiska.
  var
    tworzone : TPole;
  begin
    tworzone := TPole.Create(t);
    tworzone.parent := t;
    tworzone.top := y;
    tworzone.left := x;
    tworzone.px := px;
    tworzone.py := py;
    tworzone.height := wysokosc;
    tworzone.width := szerokosc;
    tworzone.Picture.LoadFromFile('obrazki/kwadrat.jpg');
    tworzone.stretch := true;
    tworzone.OnClick := @tworzone.Click;
    stworz := tworzone;
  end;

  procedure TPole.Click(Sender : TObject);
  var
    x,y : LongInt;
    nowa : TSciana;
  begin
    x := TPole(Sender).px;
    y := TPole(Sender).py;
    if (px > 0) and (x < szerokosc) then
    begin
      if (y > 0) and (y < wysokosc) then
      begin
        if (wybranyRysunek > 0) and (wybranyRysunek <> 20) then
        begin
          if wybranyRysunek = 1 then
          begin
            boiskov.polacz(px+1,py,px,py+1,panelBoiska);
            polaKlikane[px+1][py].ruch[5] := true;
            polaKlikane[px][py+1].ruch[1] := true;
            polaKlikane[px+1][py].klikniete := true;
            polaKlikane[px][py+1].klikniete := true;
          end
          else if wybranyRysunek = 2 then
          begin
            boiskov.polacz(px,py+1,px,py,panelBoiska);
            polaKlikane[px][py+1].ruch[2] := true;
            polaKlikane[px][py].ruch[6] := true;
            polaKlikane[px][py].klikniete := true;
            polaKlikane[px][py+1].klikniete := true;
          end
          else if wybranyRysunek = 3 then
          begin
            boiskov.polacz(px,py,px+1,py+1,panelBoiska);
            polaKlikane[px][py].ruch[7] := true;
            polaKlikane[px+1][py+1].ruch[3] := true;
            polaKlikane[px][py].klikniete := true;
            polaKlikane[px+1][py+1].klikniete := true;
          end
          else if wybranyRysunek = 4 then
          begin
            boiskov.polacz(px,py,px+1,py,panelBoiska);
            polaKlikane[px][py].ruch[0] := true;
            polaKlikane[px+1][py].ruch[4] := true;
            polaKlikane[px][py].klikniete := true;
            polaKlikane[px+1][py].klikniete := true;
          end
          else if wybranyRysunek = 9 then
          begin
            boiskov.polacz(px,py+1,px+1,py+1,panelBoiska);
            polaKlikane[px][py+1].ruch[0] := true;
            polaKlikane[px+1][py+1].ruch[4] := true;
            polaKlikane[px][py+1].klikniete := true;
            polaKlikane[px+1][py+1].klikniete := true;
          end;
          //sciany[px][py][wybranyRysunek] := nowa.stworz(TPole(sender).Left,TPole(sender).Top,TPole(sender).height,TPole(sender).width,wybranyRysunek,TPole(Sender).Parent)
        end;
      end;
    end;

  end;

  constructor TSciana.Create(TheOwner : TComponent);
  begin
    inherited Create(TheOwner);
  end;

  function TSciana.stworz(x,y,wysokosc,szerokosc,kierunek  : LongInt; t: TWinControl) : TSciana;
  //Tworzymy ścianę.
  var
    tworzone : TSciana;
  begin
    tworzone := TSciana.Create(t);
    tworzone.parent := t;
    tworzone.top := y;
    tworzone.left := x;
    tworzone.height := wysokosc;
    tworzone.width := szerokosc;
    tworzone.kierunek := kierunek;
    if kierunek = 0 then
      tworzone.Picture.LoadFromFile('obrazki/kreskag.png')
    else if kierunek = 1 then
      tworzone.Picture.LoadFromFile('obrazki/kreska15.png')
    else if kierunek = 2 then
      tworzone.Picture.LoadFromFile('obrazki/kreskal.png')
    else if kierunek = 3 then
      tworzone.Picture.LoadFromFile('obrazki/kreska37.png')
    else if kierunek = 4 then
      tworzone.Picture.LoadFromFile('obrazki/kreskag.png')
    else if kierunek = 5 then
      tworzone.Picture.LoadFromFile('obrazki/kreska15.png')
    else if kierunek = 6 then
      tworzone.Picture.LoadFromFile('obrazki/kreskal.png')
    else if kierunek = 7 then
      tworzone.Picture.LoadFromFile('obrazki/kreska37.png')
    else if kierunek = 8 then
      tworzone.Picture.LoadFromFile('obrazki/nieodw.png')
    else if kierunek = 9 then
      tworzone.Picture.LoadFromFile('obrazki/kreskad.png')
    else if kierunek = 10 then
      tworzone.Picture.LoadFromFile('obrazki/kreskagpod.png')
    else if kierunek = 11 then
      tworzone.Picture.LoadFromFile('obrazki/kreska15pod.png')
    else if kierunek = 12 then
      tworzone.Picture.LoadFromFile('obrazki/kreskalpod.png')
    else if kierunek = 13 then
      tworzone.Picture.LoadFromFile('obrazki/kreska37pod.png')
    else if kierunek = 14 then
      tworzone.Picture.LoadFromFile('obrazki/kreskagpod.png')
    else if kierunek = 15 then
      tworzone.Picture.LoadFromFile('obrazki/kreska15pod.png')
    else if kierunek = 16 then
      tworzone.Picture.LoadFromFile('obrazki/kreskalpod.png')
    else if kierunek = 17 then
      tworzone.Picture.LoadFromFile('obrazki/kreska37pod.png');

    tworzone.stretch := true;
    tworzone.transparent := true;
    tworzone.Enabled:= false;
    stworz := tworzone;
  end;




  constructor TPoleKlikalne.Create(TheOwner : TComponent);
  begin
    inherited Create(TheOwner);
  end;

  function TPoleKlikalne.stworz(x,y,wysokosc,szerokosc,px,py  : LongInt; t: TWinControl) : TPoleKlikalne;
  //Tworzymy i inicjujemy pole klikalne
  var
    tworzone : TPoleKlikalne;
    i : LongInt;
  begin
    tworzone := TPoleKlikalne.Create(t);
    tworzone.parent := t;
    tworzone.top := y;
    tworzone.left := x;
    tworzone.height := wysokosc;
    tworzone.width := szerokosc;
    tworzone.Picture.LoadFromFile('obrazki/nieodw.png');
    tworzone.stretch := true;
    tworzone.visible := true;
    tworzone.transparent := true;
    tworzone.klikniete := false;
    tworzone.OnClick := @tworzone.Click;
    tworzone.OnMouseEnter := @tworzone.MouseEnter;
    tworzone.OnMouseLeave := @tworzone.MouseLeave;
    tworzone.pilka := false;
    for i := 0 to 7 do
      tworzone.ruch[i] := false;
    tworzone.x := px;
    tworzone.y := py;
    stworz := tworzone;
  end;
  procedure TPoleKlikalne.MouseEnter(Sender: TObject);
  //Gdy wchodzimy w obszar podswietlany.
  var
    s : String;
  begin
    if Sender is TPoleKlikalne then
    begin
      if not TPoleKlikalne(Sender).pilka then
        TPoleKlikalne(Sender).picture.LoadFromFile('obrazki/podswietlone.png');
    end;
  end;

  procedure TPoleKlikalne.MouseLeave(Sender: TObject);
  //Gdy zjedziemy z podświetlanego punktu.
  var
    s : String;
  begin
    if Sender is TPoleKlikalne then
    begin
      if (not TPoleKlikalne(Sender).klikniete) and (not TPoleKlikalne(Sender).pilka) then
        TPoleKlikalne(Sender).picture.LoadFromFile('obrazki/nieodw.png')
      else if (not TPoleKlikalne(Sender).pilka) then
        TPoleKlikalne(Sender).picture.LoadFromFile('obrazki/nieodw.png')
      else
        TPoleKlikalne(Sender).picture.LoadFromFile('obrazki/pilka.png');
    end;
  end;


  function modul(a : LongInt) : LongInt;
  //Funkcja zwraca moduł z liczby.
  begin
    if a >= 0 then
      modul := a
    else
      modul := -a;
  end;

  function obok(x,y,px,py : LongInt) : Boolean;
  //Sprawdzamy czy pole jest obok podanych współrzędnych.
  begin
    if (modul(x-px) <= 1) and (modul(y-py) <= 1)then
      obok := true
    else
      obok := false;
  end;
  procedure TBoisko.polacz(x,y,px,py : LongInt; t : TWinControl);
  //Procedura łącząca dwa punkty kreską.
  var
    nowa : TSciana;
    sizeX, sizeY : LongInt;
    wys,szer : LongInt;
  begin
    szer := sciany[1][1][6].Width;
    wys := sciany[1][1][6].Height;
    sizeX := (szer)*x;
    sizeY := (wys)*y;
    if x-px = 0 then
    begin
      if y-py = 1 then
      begin
        if sciany[x][y][6] <> nil then
        begin
          sciany[x][y][6].Destroy;
          sciany[x][y][6] := nil;
        end;
        sciany[x][y][6] := nowa.stworz(sizeX,sizeY-wys,wys,szer,6,t);
      end
      else if y-py = -1 then
      begin
        if sciany[x][y][2] <> nil then
        begin
          sciany[x][y][2].Destroy;
          sciany[x][y][2] := nil;
        end;
        sciany[x][y][2] := nowa.stworz(sizeX,sizeY,wys,szer,2,t);
      end;
    end
    else if x-px = -1 then
    begin
      if y-py = 0 then
      begin
        if sciany[x][y][4] <> nil then
        begin
          sciany[x][y][4].Destroy;
          sciany[x][y][4] := nil;
        end;
        sciany[x][y][4] := nowa.stworz(sizeX,sizeY,wys,szer,0,t);
      end
      else if y-py = -1 then
      begin
        if sciany[x][y][3] <> nil then
        begin
          sciany[x][y][3].Destroy;
          sciany[x][y][3] := nil;
        end;
        sciany[x][y][3] := nowa.stworz(sizeX,sizeY,wys,szer,3,t);
      end
      else if y-py = 1 then
      begin
        if sciany[x][y][5] <> nil then
        begin
          sciany[x][y][5].Destroy;
          sciany[x][y][5] := nil;
        end;
        sciany[x][y][5] := nowa.stworz(sizeX,sizeY-wys,wys,szer,5,t);
      end;
    end
    else if x-px = 1 then
    begin
      if y-py = 0 then
      begin
        if sciany[x][y][0] <> nil then
        begin
          sciany[x][y][0].Destroy;
          sciany[x][y][0] := nil;
        end;
        sciany[x][y][0] := nowa.stworz(sizeX- szer,sizeY,wys,szer,0,t);
      end
      else if y-py = -1 then
      begin
        if sciany[x][y][1] <> nil then
        begin
          sciany[x][y][1].Destroy;
          sciany[x][y][1] := nil;
        end;
        sciany[x][y][1] := nowa.stworz(sizeX-szer,sizeY,wys,szer,1,t);
      end
      else if y-py = 1 then
      begin
        if sciany[x][y][7] <> nil then
        begin
          sciany[x][y][7].Destroy;
          sciany[x][y][7] := nil;
        end;
        sciany[x][y][7] := nowa.stworz(sizeX-szer,sizeY-wys,wys,szer,7,t);
      end;
    end;
  end;

  procedure polaczPodpowiedz(x,y,kierunek : LongInt; t : TWinControl);
  //Procedura łącząca dwa punkty kreską podpowiedzi.
  var
    nowa : TSciana;
    sizeX, sizeY : LongInt;
    wys,szer : LongInt;
  begin
    szer := sciany[1][1][6].Width;
    wys := sciany[1][1][6].Height;
    sizeX := (szer)*x;
    sizeY := (wys)*y;
      if kierunek = 6 then
      begin
        sciany[x][y][16] := nowa.stworz(sizeX,sizeY-wys,wys,szer,16,t);
      end
      else if kierunek = 2 then
      begin
        sciany[x][y][12] := nowa.stworz(sizeX,sizeY,wys,szer,12,t);
      end
      else if kierunek = 4 then
      begin
        sciany[x][y][14] := nowa.stworz(sizeX,sizeY,wys,szer,10,t);
      end
      else if kierunek = 3 then
      begin
        sciany[x][y][13] := nowa.stworz(sizeX,sizeY,wys,szer,13,t);
      end
      else if kierunek = 5 then
      begin
        sciany[x][y][15] := nowa.stworz(sizeX,sizeY-wys,wys,szer,15,t);
      end
      else if kierunek = 0 then
      begin
        sciany[x][y][10] := nowa.stworz(sizeX- szer,sizeY,wys,szer,10,t);
      end
      else if kierunek = 1 then
      begin
        sciany[x][y][11] := nowa.stworz(sizeX-szer,sizeY,wys,szer,11,t);
      end
      else if kierunek = 7 then
      begin
        sciany[x][y][17] := nowa.stworz(sizeX-szer,sizeY-wys,wys,szer,17,t);
      end;
  end;



  function przeciwny(k : LongInt) : LongInt;
  //Funkcja zwraca przeciwny kierunek.
  begin
    przeciwny := (k +4) mod 8;
  end;

  procedure wczytajSciane(var s : TSciana; kierunek : LongInt);
  //Wczytujemy odpowiednią ścianę.
  begin
    if kierunek = 0 then
      s.Picture.LoadFromFile('obrazki/kreskag.png')
    else if kierunek = 1 then
      s.Picture.LoadFromFile('obrazki/kreska15.png')
    else if kierunek = 2 then
      s.Picture.LoadFromFile('obrazki/kreskal.png')
    else if kierunek = 3 then
      s.Picture.LoadFromFile('obrazki/kreska37.png')
    else if kierunek = 4 then
      s.Picture.LoadFromFile('obrazki/kreskag.png')
    else if kierunek = 5 then
      s.Picture.LoadFromFile('obrazki/kreska15.png')
    else if kierunek = 6 then
      s.Picture.LoadFromFile('obrazki/kreskal.png')
    else if kierunek = 7 then
      s.Picture.LoadFromFile('obrazki/kreska37.png')
    else if kierunek = 8 then
      s.Picture.LoadFromFile('obrazki/nieodw.png')
    else if kierunek = 9 then
      s.Picture.LoadFromFile('obrazki/kreskad.png')
    else if kierunek = 10 then
      s.Picture.LoadFromFile('obrazki/kreskagpod.png')
    else if kierunek = 11 then
      s.Picture.LoadFromFile('obrazki/kreska15pod.png')
    else if kierunek = 12 then
      s.Picture.LoadFromFile('obrazki/kreskalpod.png')
    else if kierunek = 13 then
      s.Picture.LoadFromFile('obrazki/kreska37pod.png')
    else if kierunek = 14 then
      s.Picture.LoadFromFile('obrazki/kreskagpod.png')
    else if kierunek = 15 then
      s.Picture.LoadFromFile('obrazki/kreska15pod.png')
    else if kierunek = 16 then
      s.Picture.LoadFromFile('obrazki/kreskalpod.png')
    else if kierunek = 17 then
      s.Picture.LoadFromFile('obrazki/kreska37pod.png');
    //s.Picture.GetNamePath;
    //showMessage(s.Picture.);
  end;

  procedure kolejnyStan(stan : StanGry);
  //Procedura przywracająca ruch.
  var
    i,j,k : LongInt;
    kierunek : LongInt;
  begin
    if stan.terazx-stan.poprzednix = 0 then
    begin
      if stan.terazy-stan.poprzedniy = -1 then
      begin
        kierunek := 2;
      end
      else if stan.terazy-stan.poprzedniy = 1 then
      begin
        kierunek := 6;
      end;
    end
    else if stan.terazx-stan.poprzednix = -1 then
    begin
      if stan.terazy-stan.poprzedniy = -1 then
      begin
        kierunek := 3;
      end
      else if stan.terazy-stan.poprzedniy = 0 then
      begin
        kierunek := 4;
      end
      else if stan.terazy-stan.poprzedniy = 1 then
      begin
        kierunek := 5;
      end;
    end
    else if stan.terazx-stan.poprzednix = 1 then
    begin
      if stan.terazy-stan.poprzedniy = -1 then
      begin
        kierunek := 1;
      end
      else if stan.terazy-stan.poprzedniy = 0 then
      begin
        kierunek := 0;
      end
      else if stan.terazy-stan.poprzedniy = 1 then
      begin
        kierunek := 7;
      end;
    end;
        polaKlikane[terazx][terazy].klikniete := true;
        polaKlikane[terazx][terazy].ruch[kierunek] := true;
        polaKlikane[terazx][terazy].Picture.LoadFromFile('obrazki/nieodw.png');
        polaKlikane[terazx][terazy].pilka:= false;
        boiskov.polacz(stan.terazx,stan.terazy,terazx,terazy,panelBoiska);
        //tak było poprzednio i było źle wczytajSciane(sciany[stan.terazx][stan.terazy][kierunek],kierunek);
        trybGry := stan.trybGry;
        wysokosc := stan.wysokosc;
        szerokosc := stan.szerokosc;
        pilkax := stan.terazx;
        pilkay := stan.terazy;
        terazx := stan.terazx;
        terazy := stan.terazy;
        polaKlikane[terazx][terazy].ruch[przeciwny(kierunek)] := true;
        poprzednix := stan.poprzednix;
        poprzedniy := stan.poprzedniy;
        polaKlikane[terazx][terazy].Picture.LoadFromFile('obrazki/pilka.png');
        polaKlikane[terazx][terazy].pilka:= true;
        gracz := stan.gracz;
        wygral1 := stan.wygral1;
        wygral2 := stan.wygral2;
        numerRuchu := stan.numerRuchu;
  end;


  procedure zaladujSciane(terazx,terazy,kierunek : LongInt);
  begin
    if sciany[terazx][terazy][kierunek] <> nil then
      sciany[terazx][terazy][kierunek].picture.LoadFromFile('obrazki/nieodw.png');
  end;

  procedure wywalSciane(terazx,terazy,kierunek : LongInt);
  begin
    if sciany[terazx][terazy][kierunek] <> nil then
      sciany[terazx][terazy][kierunek].Destroy;
    sciany[terazx][terazy][kierunek] := nil;
  end;

  procedure poprzedniStan(stan : StanGry; kontrolny : Integer);
  //W tej procedurze wczytujemy stan gry z zapamiętanego.
  var
    i,j,k : LongInt;
    mozna : LongInt;
    kierunek : LongInt;
  begin
    mozna := 0;
    for i := 0 to 7 do
    begin
      if not polaKlikane[terazx][terazy].ruch[i] then
        mozna := mozna + 1;
    end;
      if terazx-poprzednix = 0 then
      begin
        if terazy-poprzedniy = -1 then
        begin
          kierunek := 2;
        end
        else if terazy-poprzedniy = 1 then
        begin
          kierunek := 6;
        end;
      end
      else if terazx-poprzednix = -1 then
      begin
        if terazy-poprzedniy = -1 then
        begin
          kierunek := 3;
        end
        else if terazy-poprzedniy = 0 then
        begin
          kierunek := 4;
        end
        else if terazy-poprzedniy = 1 then
        begin
          kierunek := 5;
        end;
      end
      else if terazx-poprzednix = 1 then
      begin
        if terazy-poprzedniy = -1 then
        begin
          kierunek := 1;
        end
        else if terazy-poprzedniy = 0 then
        begin
          kierunek := 0;
        end
        else if terazy-poprzedniy = 1 then
        begin
          kierunek := 7;
        end;
      end;
    if mozna = 7 then
    begin
      for i := 0 to 7 do
        polaKlikane[terazx][terazy].ruch[i] := false;
      polaKlikane[terazx][terazy].klikniete := false;
      polaKlikane[poprzednix][poprzedniy].ruch[kierunek] := false;
      polaKlikane[terazx][terazy].Picture.LoadFromFile('obrazki/nieodw.png');
    end
    else
    begin
      polaKlikane[terazx][terazy].ruch[przeciwny(kierunek)] := false;
      polaKlikane[terazx][terazy].Picture.LoadFromFile('obrazki/nieodw.png');
      polaKlikane[poprzednix][poprzedniy].ruch[kierunek] := false;
    end;
    //Musimy ustawić scianę na żadną.
    if kontrolny = 0 then
      zaladujSciane(terazx,terazy,kierunek)
    else if kontrolny = 1 then
      wywalSciane(terazx,terazy,kierunek);

    polaKlikane[terazx][terazy].pilka:= false;
    trybGry := stan.trybGry;
    wysokosc := stan.wysokosc;
    szerokosc := stan.szerokosc;
    pilkax := stan.terazx;
    pilkay := stan.terazy;
    terazx := stan.terazx;
    terazy := stan.terazy;
    poprzednix := stan.poprzednix;
    poprzedniy := stan.poprzedniy;
    polaKlikane[terazx][terazy].Picture.LoadFromFile('obrazki/pilka.png');
    polaKlikane[terazx][terazy].klikniete := true;
    polaKlikane[terazx][terazy].pilka:= true;
    gracz := stan.gracz;
    wygral1 := stan.wygral1;
    wygral2 := stan.wygral2;
    numerRuchu := stan.numerRuchu;

  end;

  procedure zapiszStan(var stan : StanGry);
  //W tej procedurze bedziemy zapisywali obecny stan gry.
  var
    i,j,k : LongInt;
  begin
    stan.trybGry:= trybGry;
    stan.wysokosc := wysokosc;
    stan.szerokosc := szerokosc;
    stan.terazx := terazx;
    stan.terazy := terazy;
    stan.poprzednix := poprzednix;
    stan.poprzedniy := poprzedniy;
    stan.gracz := gracz;
    stan.wygral1 := wygral1;
    stan.wygral2 := wygral2;
    stan.numerRuchu := numerRuchu;
  end;

  procedure dodajRuch(var hist : HistoriaGry);
  //Zapisujemy ruch w historii oraz zwiększamy aktualny numer danego ruchu
  begin
    numerRuchu := numerRuchu +1;
    zapiszStan(historia[numerRuchu]);
  end;

  procedure TPoleKlikalne.Click(Sender: TObject);
  //Klikamy na wolne pole.
  var
    danex,daney : LongInt;
    kierunek : LongInt;
    mozna : LongInt;
    k : LongInt;
  begin
    if Sender is TPoleKlikalne then
    begin
      danex := TPoleKlikalne(Sender).x;
      daney := TPoleKlikalne(Sender).y;
      //Ustawiamy w jakim kierunku się ruszamy.
      if danex - pilkax = 0 then
      begin
        if daney -pilkay = -1 then
        begin
          kierunek := 2;
        end
        else if daney - pilkay = 1 then
        begin
          kierunek := 6;
        end;
      end
      else if danex - pilkax = -1 then
      begin
        if daney - pilkay = 0 then
        begin
          kierunek := 4;
        end
        else if daney - pilkay = -1 then
        begin
          kierunek := 3;
        end
        else if daney - pilkay = 1 then
        begin
          kierunek := 5;
        end;
      end
      else if danex - pilkax = 1 then
      begin
        if daney - pilkay = 0 then
        begin
          kierunek := 0;
        end
        else if daney - pilkay = -1 then
        begin
          kierunek := 1;
        end
        else if daney - pilkay = 1 then
        begin
          kierunek := 7;
        end;
      end;
      //Sprawdzamy czy możemy do danego pola wejść oraz czy jest ono obok.
      if obok(danex, daney, pilkax, pilkay) and (not TPoleKlikalne(Sender).ruch[przeciwny(kierunek)]) and (not polaKlikane[pilkax][pilkay].ruch[kierunek]) then
      begin
        poprzednix := pilkax;
        poprzedniy := pilkay;
        //Łączymy ścianą dwa pola.
        boiskov.polacz(danex,daney,pilkax,pilkay,panelBoiska);
        TPoleKlikalne(Sender).ruch[przeciwny(kierunek)] := true;
        polaKlikane[pilkax][pilkay].ruch[kierunek] := true;
        polaKlikane[pilkax][pilkay].picture.LoadFromFile('obrazki/nieodw.png');
        polaKlikane[pilkax][pilkay].pilka := false;
        //Jeśli weszliśmy na nieodwiedzone pole to zmieniamy gracza.
        if not TPoleKlikalne(Sender).klikniete then
          gracz := not gracz;
        TPoleKlikalne(Sender).klikniete := true;
        TPoleKlikalne(Sender).picture.LoadFromFile('obrazki/pilka.png');
        pilkax := danex;
        pilkay := daney;
        terazx := danex;
        terazy := daney;
        TPoleKlikalne(Sender).pilka := true;
        mozna := 0;
        for k := 0 to 7 do
        begin
          if not TPoleKlikalne(Sender).ruch[k] then
            mozna := mozna +1;
        end;
        //Sprawdzamy czy gra się nie zakończyła.
        if mozna = 0 then
        begin
          if gracz then
          begin
            wygral2 := true;
            wygral1 := false;
          end
          else
          begin
            wygral1 := true;
            wygral2 := false;
          end;
        end;
        if (pilkax = (szerokosc div 2)+1) and (pilkay = 0)  then
        begin
          wygral1 := true;
          wygral2 := false;
        end
        else if (pilkax = (szerokosc div 2)+1) and (pilkay = wysokosc+1) then
        begin
          wygral1 := false;
          wygral2 := true;
        end;
        //Zapisujemy ruch w historii.
        dodajRuch(historia);
        wszystkichRuchow := numerRuchu;
      end;
    end;
  end;

  procedure TBoisko.usun;
  //Usuwamy narysowane boisko
  var
    i,j,k : LongInt;
  begin
    if (length(polaKlikane) = szerokosc+1) and (length(polaKlikane[szerokosc]) = wysokosc+2) and (length(sciany)= szerokosc+1) and (length(sciany[szerokosc]) = wysokosc+2) then
    begin
      for i := 0 to szerokosc do
      begin
        for j := 0 to wysokosc do
        begin
          if pola[i][j] <> nil then
            pola[i][j].destroy;
          for k := 0 to 7 do
          begin
            if sciany[i][j][k] <> nil then
              sciany[i][j][k].destroy;
            if (j = wysokosc ) and (sciany[i][j+1][k] <> nil) then
              sciany[i][j+1][k].destroy;
          end;
          if polaKlikane[i][j] <> nil then
            polaKlikane[i][j].destroy;
          if (j = wysokosc ) and (polaKlikane[i][j+1] <> nil) then
            polaKlikane[i][j+1].destroy;
        end;
      end;
    end;
    SetLength(historia,0);
    SetLength(pola,0);
    SetLength(sciany,0);
    SetLength(polaKlikane,0);
  end;

  procedure TBoisko.zainicjujSciany(szer,wys : LongInt);
  //W tej procedurze ustawiamy z którego pola można gdzie pójść.
  var
    i,j,k : LongInt;
  begin
    for i := 0 to szer do
    begin
      for j := 0 to wys do
      begin

            if polaKlikane[i][j] <> nil then
            //ustawiamy kierunki dla klikalnych ścian
            begin
              if ( j = 1 ) and ( i = 1 ) then
              begin
                for k := 0 to 6 do
                  polaKlikane[i][j].ruch[k] := true;
                polaKlikane[i][j].ruch[7] := false;
                polaKlikane[i][j].klikniete := true;
              end
              else if (j = 1) and ( i = szer) then
              begin
                for k := 0 to 7 do
                  polaKlikane[i][j].ruch[k] := true;
                polaKlikane[i][j].ruch[5] := false;
                polaKlikane[i][j].klikniete := true;
              end
              else if (j = 1) and ((i < szer div 2) or ( i > (szer div 2) +2)) then
              begin
                for k := 0 to 4 do
                  polaKlikane[i][j].ruch[k] := true;
                for k := 5 to 7 do
                  polaKlikane[i][j].ruch[k] := false;
                polaKlikane[i][j].klikniete := true;
              end
              else if (j = wys) and ( i = 1 ) then
              begin
                for k := 0 to 7 do
                  polaKlikane[i][j].ruch[k] := true;
                polaKlikane[i][j].ruch[1] := false;
                polaKlikane[i][j].klikniete := true;
              end
              else if ( j = wys ) and ( i = szer ) then
              begin
                for k := 0 to 7 do
                  polaKlikane[i][j].ruch[k] := true;
                polaKlikane[i][j].ruch[3] := false;
                polaKlikane[i][j].klikniete := true;
              end
              else if ( j = wys ) and ((i < szer div 2) or ( i > (szer div 2) +2)) then
              begin
                for k := 0 to 7 do
                  polaKlikane[i][j].ruch[k] := true;
                for k := 1 to 3 do
                  polaKlikane[i][j].ruch[k] := false;
                polaKlikane[i][j].klikniete := true;
              end
              else if ( i = 1 ) then
              begin
                for k := 2 to 6 do
                  polaKlikane[i][j].ruch[k] := true;
                for k := 0 to 1 do
                  polaKlikane[i][j].ruch[k] := false;
                polaKlikane[i][j].ruch[7] := false;
                polaKlikane[i][j].klikniete := true;
              end
              else if ( i = szer ) then
              begin
                for k := 0 to 2 do
                  polaKlikane[i][j].ruch[k] := true;
                for k := 6 to 7 do
                  polaKlikane[i][j].ruch[k] := true;
                for k := 3 to 5 do
                  polaKlikane[i][j].ruch[k] := false;
                polaKlikane[i][j].klikniete := true;
              end
              else if (i = (szer div 2)) and (j = 1) then
              begin
                for k := 0 to 7 do
                  polaKlikane[i][j].ruch[k] := false;
                for k := 2 to 4 do
                  polaKlikane[i][j].ruch[k] := true;
                polaKlikane[i][j].klikniete := true;
              end
              else if (i = (szer div 2)+2) and (j =1) then
              begin
                for k := 0 to 7 do
                  polaKlikane[i][j].ruch[k] := false;
                for k := 0 to 2 do
                  polaKlikane[i][j].ruch[k] := true;
                polaKlikane[i][j].klikniete := true;
              end
              else if (i = (szer div 2)) and (j = wys) then
              begin
                for k := 0 to 7 do
                  polaKlikane[i][j].ruch[k] := false;
                for k := 4 to 6 do
                  polaKlikane[i][j].ruch[k] := true;
                polaKlikane[i][j].klikniete := true;
              end
              else if (i = (szer div 2)+2) and (j = wys) then
              begin
                for k := 1 to 5 do
                  polaKlikane[i][j].ruch[k] := false;
                for k := 6 to 7 do
                  polaKlikane[i][j].ruch[k] := true;
                polaKlikane[i][j].ruch[0] := true;
                polaKlikane[i][j].klikniete := true;
              end;
            end;
      end;
    end;
  end;

  procedure TBoisko.narysuj(szeroko,wysoko : LongInt; t : TWinControl);
  //Rysujemy boisko.
  var
    i,j,k : LongInt;
    sizeX, sizeY,wys,szer : LongInt;
    nowy : TPole;
    nowa : TSciana;
    nowePole : TPoleKlikalne;
  begin
    sizeX := 0;
    sizeY := 0;
    wys := t.height div (wysoko+1);
    szer := t.width div (szeroko+1);
    for i := 0 to szeroko do
    begin
      sizeY := 0;
      for j := 0 to wysoko do
      begin
        pola[i][j] := nowy.stworz(sizeX,sizeY,wys,szer,i,j,t);
        for k := 0 to 7 do
          sciany[i][j][k] := nil;
        if (j = 0) and (i >= ((szeroko)div 2)) and ( i < (((szeroko)div 2 )+2)) then
        //ściany bramki na górze
        begin
          sciany[i][j][0] := nowa.stworz(sizeX,sizeY,wys,szer,0,t);
        end;
        if (j = wysoko) and (i >= ((szeroko)div 2)) and ( i < (((szeroko)div 2 )+2)) then
        // ściany bramki na dole
        begin
          sciany[i][j][4] := nowa.stworz(sizeX,sizeY,wys,szer,9,t);
        end;
        if (i = 1) and (j > 0) and (j < wysoko)  then
        //lewe ściany
        begin
          sciany[i][j][6] := nowa.stworz(sizeX,sizeY,wys,szer,6,t);
        end;
        if ((i = ((szeroko)div 2)) and (j = 0)) then
        //ściany bramki na górze
        begin
          sciany[i][j][6] := nowa.stworz(sizeX,sizeY,wys,szer,6,t);
        end;
        if ((i = ((szeroko)div 2)+2) and (j = 0)) then
        //sciany bramki na górze
        begin
          sciany[i][j][2] := nowa.stworz(sizeX,sizeY,wys,szer,2,t);
        end;
        if (i = szeroko) and (j > 0) and (j < wysoko) then
        //ściany z prawej strony
        begin
          sciany[i][j][2] := nowa.stworz(sizeX,sizeY,wys,szer,2,t);
        end;
        if ((i = ((szeroko)div 2)) and (j = wysoko)) then
        //ściany bramki na dole
        begin
          sciany[i][j][6] := nowa.stworz(sizeX,sizeY,wys,szer,6,t);
        end;
        if ((i = ((szeroko)div 2)+2) and (j = wysoko)) then
        //ściany bramki na dole
        begin
          sciany[i][j][2] := nowa.stworz(sizeX,sizeY,wys,szer,2,t);
        end;
        if (j = 1) and (i > 0) and (i < szeroko) and((i < (szeroko)div 2) or (i > (((szeroko)div 2)+1))) then
        //ściany boiska na górze
        begin
          sciany[i][j][0] := nowa.stworz(sizeX,sizeY,wys,szer,0,t);
        end;
        if (j = wysoko) and (i > 0) and (i < szeroko) and((i < (szeroko)div 2) or (i > (((szeroko)div 2)+1))) then
        //ściany boiska na dole
        begin
          sciany[i][j][0] := nowa.stworz(sizeX,sizeY,wys,szer,0,t);
        end;
        if (i > 0 ) and ( i <= szeroko) and (j > 0 ) and ( j <= wysoko) then
        //tworzymy pola klikalne
          polaKlikane[i][j] := nowePole.stworz(sizeX - ((szer div 2)),sizeY - ((wys div 2)),wys,szer,i,j,t);

        if (i = (szeroko div 2)+1) and ( j = 0) then
        //bramka na górze
        begin
          bramka1 := nowePole.stworz(sizeX - (szer div 2),sizeY - (wys div 2)+10,wys,szer,i,j,t);
          polaKlikane[i][j] := bramka1;
        end;
        if (i = (szeroko div 2)+1) and ( j = wysoko) then
        //bramka na dole
        begin
          bramka2 := nowePole.stworz(sizeX - (szer div 2),sizeY + (wys div 2)-10,wys,szer,i,j+1,t);
          polaKlikane[i][j+1] := bramka2;
        end;
        if (i = pilkax) and ( j =  pilkay) then
        //piłka na początku
        begin
          polaKlikane[i][j].pilka := true;
          polaKlikane[i][j].Picture.LoadFromFile('obrazki/pilka.png');
          polaKlikane[i][j].klikniete := true;
        end;

        sizeY := sizeY + wys;
      end;
      sizeX := sizeX + szer;
    end;

  end;

  procedure TBoisko.stworz(szerokoscpodana, wysokoscpodana : LongInt; t : TWinControl);
  //Tworzymy boisko i je rysujemy oraz stawiamy piłkę na środku.
  begin

    gracz := true;
    wygral1 := false;
    wygral2 := false;
    szerokosc := szerokoscpodana+1;
    wysokosc := wysokoscpodana+1;
    numerRuchu := 0;
    pilkax := (szerokosc div 2)+1;
    pilkay := (wysokosc div 2)+1;
    poprzednix := pilkax;
    poprzedniy := pilkay;
    terazx := pilkax;
    terazy := pilkay;
    wszystkichRuchow := 0;
    panelBoiska := t;
    SetLength(pola,szerokosc+1,wysokosc+1);
    SetLength(sciany,szerokosc+1,wysokosc+2);
    SetLength(polaKlikane,szerokosc+1,wysokosc+2);
    SetLength(historia,szerokosc*wysokosc*8);
    narysuj(szerokosc,wysokosc,t);
    zainicjujSciany(szerokosc,wysokosc);
    zapiszStan(historia[numerRuchu]);
  end;

  procedure zapiszDoPliku(nazwa : String);
  //Zapisuje całą historię gry do pliku od podanej nazwie z końcówką .fsave
  var
    i,j,k : LongInt;
    dlugosc : LongInt;
    stan : array of StanZapisu;
    plik : file of LongInt;
    polaSave : PolaDoZapisu;
    aktualnyRuch : LongInt;
    scianySave : ScianyDoZapisu;
  begin
    SetLength(polaSave,szerokosc+1,wysokosc+2);
    SetLength(scianySave,szerokosc+1,wysokosc+1);
    aktualnyRuch := numerRuchu;
   for i := aktualnyRuch+1 to wszystkichRuchow do
    begin
      kolejnyStan(historia[i]);
    end;
    for i := wszystkichRuchow-1 downto aktualnyRuch do
    begin
      poprzedniStan(historia[i],1);
    end;

    for i := 0 to szerokosc do
    begin
      for j := 0 to wysokosc+1 do
      begin
        if polaKlikane[i][j] <> nil then
        begin
          if polaKlikane[i][j].klikniete then
            polaSave[i][j].klikniete := 1
          else
            polaSave[i][j].klikniete := 0;
          for k := 0 to 7 do
          begin
            if polaKlikane[i][j].ruch[k] then
              polaSave[i][j].ruch[k] := 1
            else
              polaSave[i][j].ruch[k] := 0;
          end;
        end;
      end;
    end;

    for i := 0 to szerokosc do
    begin
      for j := 0 to wysokosc do
      begin
        for k := 0 to 17 do
        begin
          if sciany[i][j][k] <> nil then
            scianySave[i][j][k] := 1
          else
            scianySave[i][j][k] := 0;
        end;
      end;
    end;
    aktualnyRuch := numerRuchu;
    dlugosc := aktualnyRuch;
    SetLength(stan,aktualnyRuch+1);
    for i := 0 to aktualnyRuch do
    begin
    stan[i].trybGry:= historia[i].trybGry;
    stan[i].wysokosc := historia[i].wysokosc;
    stan[i].szerokosc := historia[i].szerokosc;
    stan[i].terazx := historia[i].terazx;
    stan[i].terazy := historia[i].terazy;
    stan[i].poprzednix := historia[i].poprzednix;
    stan[i].poprzedniy := historia[i].poprzedniy;
    if historia[i].gracz then
      stan[i].gracz := 1
    else
      stan[i].gracz := 0;
    if historia[i].wygral1 then
      stan[i].wygral1 := 1
    else
      stan[i].wygral1 := 0;
    if historia[i].wygral1 then
      stan[i].wygral1 := 1
    else
      stan[i].wygral1 := 0;
    stan[i].numerRuchu := historia[i].numerRuchu;
    end;
    assign(plik,nazwa+'.fsave');
    rewrite(plik);
    write(plik,aktualnyRuch);
    write(plik,dlugosc);

    for i := 0 to aktualnyRuch do
    begin
      write(plik,stan[i].trybGry);
      write(plik,stan[i].wysokosc);
      write(plik,stan[i].szerokosc);
      write(plik,stan[i].terazx);
      write(plik,stan[i].terazy);
      write(plik,stan[i].poprzednix);
      write(plik,stan[i].poprzedniy);
      write(plik,stan[i].gracz);
      write(plik,stan[i].wygral1);
      write(plik,stan[i].wygral2);
      write(plik,stan[i].numerRuchu);
    end;
    for i := 0 to szerokosc do
    begin
      for j := 0 to wysokosc+1 do
      begin
        write(plik,polaSave[i][j].klikniete);
        for k := 0 to 7 do
        begin
          write(plik,polaSave[i][j].ruch[k]);
        end;
      end;
    end;
    for i := 0 to szerokosc do
    begin
      for j := 0 to wysokosc do
      begin
        for k := 0 to 17 do
        begin
          write(plik,scianySave[i][j][k]);
        end;
      end;
    end;
    close(plik);
  end;

  procedure wczytajZPliku(nazwa : String; t : TWinControl);
  //Procedura wczytująca zapis gry razem z jego historią.
  var
    i,j,k : LongInt;
    stan : array of StanZapisu;
    plik : file of LongInt;
    wys,szer,dlugosc : LongInt;
    nowa : TSciana;
    polaSave : PolaDoZapisu;
    scianySave : ScianyDoZapisu;
    sizeX,sizeY,wyss,szers : LongInt;
    aktualnyRuch : LongInt;
  begin
    assign(plik,nazwa);
    reset(plik);
    read(plik,aktualnyRuch);
    read(plik,dlugosc);
    SetLength(stan,dlugosc+1);
    for i := 0 to dlugosc do
    begin
      read(plik,stan[i].trybGry);
      read(plik,stan[i].wysokosc);
      read(plik,stan[i].szerokosc);
      read(plik,stan[i].terazx);
      read(plik,stan[i].terazy);
      read(plik,stan[i].poprzednix);
      read(plik,stan[i].poprzedniy);
      read(plik,stan[i].gracz);
      read(plik,stan[i].wygral1);
      read(plik,stan[i].wygral2);
      read(plik,stan[i].numerRuchu);
    end;
    SetLength(polaSave,stan[0].szerokosc+1,stan[0].wysokosc+2);
    SetLength(scianySave,stan[0].szerokosc+1,stan[0].wysokosc+1);
    //Wczytujemy wszystkie polaKlikane
    for i := 0 to stan[0].szerokosc do
    begin
      for j := 0 to stan[0].wysokosc+1 do
      begin
        read(plik,polaSave[i][j].klikniete);
        for k := 0 to 7 do
        begin
          read(plik,polaSave[i][j].ruch[k]);
        end;
      end;
    end;
    //Wczytujemy ściany.
    for i := 0 to stan[0].szerokosc do
    begin
      for j := 0 to stan[0].wysokosc do
      begin
        for k := 0 to 17 do
        begin
          read(plik,scianySave[i][j][k]);
        end;
      end;
    end;
    boiskov.stworz(stan[0].szerokosc-1,stan[0].wysokosc-1,t);
    for i := 0 to aktualnyRuch do
    begin
    historia[i].trybGry := stan[i].trybGry ;
    historia[i].wysokosc := stan[i].wysokosc;
    historia[i].szerokosc := stan[i].szerokosc;
    historia[i].terazx := stan[i].terazx;
    historia[i].terazy := stan[i].terazy;
    historia[i].poprzednix := stan[i].poprzednix;
    historia[i].poprzedniy := stan[i].poprzedniy;
    historia[i].gracz := (stan[i].gracz = 1);
    historia[i].wygral1 := (stan[i].wygral1 = 1);
    historia[i].wygral2 := (stan[i].wygral2 = 1);
    historia[i].numerRuchu := stan[i].numerRuchu;
    end;
    if (pilkax <> stan[0].terazx) or (pilkay <> stan[0].terazy) then
    begin
      polaKlikane[pilkax][pilkay].pilka := false;
      polaKlikane[pilkax][pilkay].Picture.LoadFromFile('obrazki/nieodw.png');
    end;
    pilkax := stan[0].terazx;
    pilkay := stan[0].terazy;
    polaKlikane[pilkax][pilkay].pilka := true;
    polaKlikane[pilkax][pilkay].Picture.LoadFromFile('obrazki/pilka.png');
    for i := 1 to aktualnyRuch do
    begin
      polaKlikane[historia[i].terazx][historia[i].terazy].Click(polaKlikane[historia[i].terazx][historia[i].terazy]);
    end;
    {for i := dlugosc downto aktualnyRuch+1 do
    begin
      numerRuchu := numerRuchu-1;
      poprzedniStan(historia[numerRuchu]);
    end;  }
    trybGry := stan[aktualnyRuch].trybGry ;
    wysokosc := stan[aktualnyRuch].wysokosc;
    szerokosc := stan[aktualnyRuch].szerokosc;
    terazx := stan[aktualnyRuch].terazx;
    terazy := stan[aktualnyRuch].terazy;
    poprzednix := stan[aktualnyRuch].poprzednix;
    poprzedniy := stan[aktualnyRuch].poprzedniy;
    gracz := (stan[aktualnyRuch].gracz = 1);
    wygral1 := (stan[aktualnyRuch].wygral1 = 1);
    wygral2 := (stan[aktualnyRuch].wygral2 = 1);
    numerRuchu := stan[aktualnyRuch].numerRuchu;
    SetLength(polaSave,stan[0].szerokosc+1,stan[0].wysokosc+2);
    SetLength(scianySave,stan[0].szerokosc+1,stan[0].wysokosc+1);
    //Ustawiamy polaKlikane
    for i := 0 to stan[0].szerokosc do
    begin
      for j := 0 to stan[0].wysokosc+1 do
      begin
        if polaKlikane[i][j] <> nil then
        begin
          if polaSave[i][j].klikniete = 1 then
          begin
            polaKlikane[i][j].klikniete := true;
          end
          else
          begin
            polaKlikane[i][j].klikniete := false;
          end;
          for k := 0 to 7 do
          begin
            if polaSave[i][j].ruch[k] = 1 then
            begin
              polaKlikane[i][j].ruch[k] := true;
            end
            else
            begin
              polaKlikane[i][j].ruch[k] := false;
            end;
          end;
        end;
      end;
    end;
    //Ładujemy ściany.
    sizeX := 0;
    sizeY := 0;
    wyss := pola[0][0].Height;
    szers := pola[0][0].Width;
    for i := 0 to stan[0].szerokosc do
    begin
      sizeY := 0;
      for j := 0 to stan[0].wysokosc do
      begin
        for k := 0 to 17 do
        begin
          if scianySave[i][j][k] = 1 then
          begin
            if sciany[i][j][k] = nil then
            begin
              if k = 0 then
                sciany[i][j][k] := nowa.stworz(sizeX-szers,sizeY,wyss,szers,k,t)
              else if k = 1 then
                sciany[i][j][k] := nowa.stworz(sizeX-szers,sizeY,wyss,szers,k,t)
              else if k = 2 then
                sciany[i][j][k] := nowa.stworz(sizeX,sizeY,wyss,szers,k,t)
              else if k = 3 then
                sciany[i][j][k] := nowa.stworz(sizeX,sizeY,wyss,szers,k,t)
              else if k = 4 then
                sciany[i][j][k] := nowa.stworz(sizeX,sizeY,wyss,szers,k,t)
              else if k = 5 then
                sciany[i][j][k] := nowa.stworz(sizeX,sizeY-wyss,wyss,szers,k,t)
              else if k = 6 then
                sciany[i][j][k] := nowa.stworz(sizeX,sizeY-wyss,wyss,szers,k,t)
              else if k = 7 then
                sciany[i][j][k] := nowa.stworz(sizeX-szers,sizeY-wyss,wyss,szers,k,t);
            end;
          end;
        end;
        sizeY := sizeY + wyss;
      end;
      SizeX := sizeX + szers;
    end;
    close(plik);
  end;

  procedure wylaczPola;
  //Wyłączamy pola klikalne podczas edycji.
  var
    i,j,k : LongInt;
  begin
    for i := 0 to szerokosc do
    begin
      for j := 0 to wysokosc do
      begin
        if polaKlikane[i][j] <> nil then
          polaKlikane[i][j].enabled  := false;
        if pola[i][j] <> nil then
          pola[i][j].Enabled := true;
      end;
    end;
    if polaKlikane[(szerokosc div 2)+1][wysokosc+1] <> nil then
      polaKlikane[(szerokosc div 2)+1][wysokosc+1].enabled := false;
  end;

  procedure wlaczPola;
  //Po edytowaniu włączamy pola klikalne z powrotem.
  var
    i,j : LongInt;
  begin
    for i := 0 to szerokosc do
    begin
      for j := 0 to wysokosc do
      begin
        if polaKlikane[i][j] <> nil then
          polaKlikane[i][j].enabled := true;
        if pola[i][j] <> nil then
          pola[i][j].Enabled := false;
      end;
    end;
    if polaKlikane[(szerokosc div 2)+1][wysokosc+1] <> nil then
      polaKlikane[(szerokosc div 2)+1][wysokosc+1].enabled  := true;
  end;

  procedure usunPrzyszleRuchy;
  //Usuwamy zapamiętany przyszłe ruchy po edycji i zapisie
  var
    i,akt : LongInt;
  begin
    akt := numerRuchu;
    for i := numerRuchu+1 to wszystkichRuchow do
    begin
      kolejnyStan(historia[i]);
    end;
    for i := wszystkichRuchow-1 downto akt do
    begin
      poprzedniStan(historia[i],1);
    end;
  end;

  procedure usunHistorie;
  //Usuwamy historię do bieżącego stanu.
  var
    i : LongInt;
  begin
    SetLength(historia,0);
    SetLength(historia,szerokosc*wysokosc*8);
    poprzednix := pilkax;
    poprzedniy := pilkay;
    terazx := pilkax;
    terazy := pilkay;
    numerRuchu := 0;
    wszystkichRuchow := 0;
    zapiszStan(historia[numerRuchu]);
  end;

end.

