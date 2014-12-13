unit GraczAI;
//W tym unicie znajduje się sztuczna 'inteligencja', która wybiera pole klikane
//przez komputer. Również ona jest odpowiedzialna za zaznaczenia podpowiedzi.
//Wybór pola odbywa się metodą monte carlo, ale lekko przerobioną, gdyż nie
//losujemy rozgrywki do końca, tylko do ustalonej maksymalnej ilości ruchów.
//W razie gdy komputer miałby problemy z wyborem kierunku, włączamy tryb failsafe
//który wybiera głupio kierunek random(8), ponieważ nie można niektórych błędów
//przewidzieć.

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls, Boisko;
type
	APole = record
		ruch : array [0..7] of Boolean;
		odwiedzony : Boolean;
	end;
	ABoisko = array of array of APole;
  ListaScian = ^elem;
  elem = record
    s : TSciana;
    nast : ListaScian;
  end;
  graczSztuczny = class
  private
    function wybierzKierunek(boiskos : ABoisko; px,py : LongInt) : LongInt;
  public
    procedure wykonajRuch;
    procedure wykonajRuch_FAILSAFE;
    procedure zaznaczPodpowiedz(t : TWinControl);
    procedure usunPodpowiedz(t : TWinControl);

  end;
var
//numerGracza jest nam potrzebny, aby komputer mógł stwierdzić, w którą stronę
//ma strzelać.
  ai : graczSztuczny;
  numerGracza : LongInt;
implementation
const
//Ustawienia odnoszące się do maksymalnej ilości przeprowadzanych losowych
//rozgrywek przez komputer.
  iloscSymulacji = 5000; //Im więcej tym wolniej komputer gra, ale lepiej.
  iloscRuchow = 30;
  maxLosowan = 100; //Jeśli generator by się "zaciął" potrzeba maksymalnej
                    //ilości możliwych losowan tej samej liczby


  function przeciwny(k : LongInt) : LongInt;
  //Funkcja zwraca przeciwny kierunek.
  begin
	  przeciwny := (k + 4) mod 8;
  end;

  function zwrocKierunek(danex,daney,pilkax,pilkay : LongInt) : LongInt;
  //Zwracamy kierunek dla podanych punktów.
  var
    kierunek : LongInt;
  begin
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
        zwrocKierunek := kierunek;
  end;

  procedure skopiujBoisko(var boisko : ABoisko; szer,wys : LongInt);
  //W tej funkcji kopiujemy do bardziej oszczędnego typu boisko, ponieważ ważne
  //dla nas jest tylko to czy byliśmy w tym polu oraz czy można w daną stronę
  //wyjść czy też wejść.
  var
	  i,j,k : LongInt;
  begin
    //showMessage('tu');
	  SetLength(boisko,szer+1,wys+1);
	  for i:= 0 to szer do
	  begin
		  for j:= 0 to wys do
		  begin
        if polaKlikane[i+1][j+1] <> nil then
        begin
			    boisko[i][j].odwiedzony := polaKlikane[i+1][j+1].klikniete;
			    for k := 0 to 7 do
				    boisko[i][j].ruch[k] := polaKlikane[i+1][j+1].ruch[k];

        end
      end;
	  end;
  end;


  procedure skopiujABoisko(const boisko : ABoisko; var boiskos : ABoisko; szer,wys : LongInt);
  //Kopiujemy stworzone ABoisko do podanego boiska.
  var
	  i,j,k : LongInt;
  begin
	  SetLength(boiskos,szer+1,wys+1);
	  for i:= 0 to szer do
	  begin
		  for j:= 0 to wys do
		  begin
			  boiskos[i][j].odwiedzony := boisko[i][j].odwiedzony;
			  for k := 0 to 7 do
				  boiskos[i][j].ruch[k] := boisko[i][j].ruch[k];
		  end;
	  end;
  end;

  function przesunPilke(var boisko : ABoisko; szer,wys : LongInt; var pilkax,pilkay : LongInt) : LongInt;
  //Funkcja przesuwająca piłkę w losowym kierunku(dostępnym), potrzebna do
  //wykonania losowych rozgrywek dla procedury okreslWartośćPola.
  //Dużo kodu wiąże się z wieloma przypadkami i sprawdzaniem położenia względem boiska
  var
    kierunek : LongInt;
    k : array [0..7] of Integer;
    i : LongInt;
    x,y : LongInt;
    stop : Boolean;
    losowane : LongInt;
  begin
    x := pilkax;
    y := pilkay;
    losowane := 0;
    kierunek := random(8);
    stop := false;
    assert ((y >=0 ) and (y <= wys));
    assert ((x >=0 ) and (x <= szer));
    if (x > 0) and ( x < szer) then
    begin
      if (y > 0 ) and ( y < wys) then
      begin
        kierunek := random(8);
        while (boisko[x][y].ruch[kierunek]) and (not stop) do
        begin
          losowane := losowane + 1;
          kierunek := random(8);
          if losowane > maxLosowan then
            stop := true;
        end;
      end
      else if y = 0 then
      begin
        if (x > (szer div 2 )- 2) and ( x < (szer div 2) + 2 )then
        begin
          if x = (szer div 2) - 1 then
            kierunek := 1
          else if x = szer div 2 then
            kierunek := 2
          else
            kierunek := 3;
        end
        else
        begin
          kierunek := random(3)+5;
          while (boisko[x][y].ruch[kierunek]) and (not stop) do
          begin
            losowane := losowane + 1;
            kierunek := random(3)+5;
            if losowane > maxLosowan then
              stop := true;
          end;
        end;
      end
      else if y = wys then
      begin
        if (x > (szer div 2) - 2) and ( x < (szer div 2) + 2 )then
        begin
          if x = (szer div 2) - 1 then
          begin
            kierunek := random(4);
            while (boisko[x][y].ruch[kierunek]) and (not stop) do
            begin
              losowane := losowane + 1;
              kierunek := random(4);
              if losowane > maxLosowan then
                stop := true;
            end;
          end
          else if x = szer div 2 then
          begin
            kierunek := random(8);
            while (boisko[x][y].ruch[kierunek]) and (not stop) do
            begin
              losowane := losowane + 1;
              kierunek := random(8);
              if losowane > maxLosowan then
                stop := true;
            end;
          end
          else
          begin
            kierunek := random(4)+1;
            while (boisko[x][y].ruch[kierunek]) and (not stop) do
            begin
              losowane := losowane + 1;
              kierunek := random(4)+1;
              if losowane > maxLosowan then
                stop := true;
            end;
          end;
        end;
      end
      else
      begin
        kierunek := random(3)+1;
        while (boisko[x][y].ruch[kierunek]) and (not stop) do
        begin
          losowane := losowane + 1;
          kierunek := random(3)+1;
          if losowane > maxLosowan then
            stop := true;
        end;
      end;
    end
    else
    begin
      if (x = 0) and (y < wys) and ( y > 0)then
      begin
        kierunek := (random(3)+7) mod 8;
        while (boisko[x][y].ruch[kierunek]) and (not stop) do
        begin
          losowane := losowane + 1;
          kierunek :=  (random(3)+7) mod 8;
          if losowane > maxLosowan then
            stop := true;
        end;
      end
      else if (x = 0) and ( y = 0 ) then
      begin
        kierunek := 7;
      end
      else if (x = 0) and (y = wys) then
      begin
        kierunek := 1;
      end
      else if (x = szer) and (y < wys) and ( y > 0) then
      begin
        kierunek := random(3)+3;
        while (boisko[x][y].ruch[kierunek]) and (not stop) do
        begin
          losowane := losowane + 1;
          kierunek :=  random(3)+3;
          if losowane > maxLosowan then
            stop := true;
        end;
      end
      else if (x = szer) and (y = 0) then
      begin
        kierunek := 5;
      end
      else if (x = szer) and (y = wys) then
      begin
        kierunek := 3;
      end;
    end;

    if stop then
    begin
      for i:= 0 to 7 do
      begin
        if not boisko[x][y].ruch[i] then
          kierunek := i;
      end;
    end;
    x := pilkax;
    y := pilkay;
    boisko[x][y].ruch[kierunek] := true;
    boisko[x][y].odwiedzony := true;
    if kierunek = 0 then
    begin
      x := x + 1;
    end
    else if kierunek = 1 then
    begin
      x := x + 1;
      y := y - 1;
    end
    else if kierunek = 2 then
    begin
      y := y - 1;
    end
    else if kierunek = 3 then
    begin
      x := x - 1;
      y := y - 1;
    end
    else if kierunek = 4 then
    begin
      x := x - 1;
    end
    else if kierunek = 5 then
    begin
      x := x - 1;
      y := y + 1;
    end
    else if kierunek = 6 then
    begin
      y := y + 1;
    end
    else if kierunek = 7 then
    begin
      x := x + 1;
      y := y + 1;
    end;
    pilkax := x;
    pilkay := y;
    przesunPilke := kierunek;
  end;

  function modul (a : LongInt) : LongInt;
  //Funkcja zwraca moduł z liczby.
	begin
		if a >= 0 then
			modul := a
		else
			modul := -a;
	end;


  function wycenPole(boisko : ABoisko; szer,wys,x,y,kBramki : LongInt) : LongInt;
  //Funkcja wyceniająca, czy pole jest dobrym polem.
	var
		wPola : LongInt;
		i : LongInt;
		mozna : LongInt;
	begin
		wPola := 0;
    if kBramki = 1 then
		  wPola := (wys-x)*100
    else
      wPola := (x)*100;
		wPola := wPola - modul((szer div 2) - y)*(50);
		mozna := 0;
		if boisko[x][y].odwiedzony then
		begin
			for i := 0 to 7 do
			begin
				if not boisko[x][y].ruch[i] then
					mozna := mozna + 1;
			end;
			if mozna < 2 then
				wPola := -200000000
			else
				wPola := wPola + (8-mozna)*200;
		end;
		wycenPole := wPola;
	end;



  function czyMozna(boisko : ABoisko;szer,wys,x,y : LongInt) : Boolean;
  //Sprawdzamy czy z danego pola można wyjść.
  var
	  i : Integer;
	  mozna : Integer;
  begin
	  mozna := 0;
	  for i:= 0 to 7 do
		  if not boisko[x][y].ruch[i] then
			  mozna := mozna + 1;
	  if mozna = 0 then
		  czyMozna := false
	  else
		  czyMozna := true;
  end;

  function okreslWartoscPola(const boisko : ABoisko; szer,wys,x,y,px,py,kBramki : LongInt) : Real;
  //Funkcja określająca prawdopodobieństwo wygranej dla danego pola.
  //Polega na wylosowaniu ustalonej liczby losowych rozgrywek i porównaniu czy
  //uzyskaliśmy lepszą pozycję od wyjściowej, bądź wygraliśmy albo przegraliśmy.
  	function losujRozgrywke(const boiskoz : ABoisko; szer,wys,il  : LongInt;const pilkax,pilkay,px,py: LongInt) : Boolean;
    //Funkcja losuje rozgrywke i zwraca true jeśli uzyskaliśmy coś na tym
    //bądż false jeśli nie.
  	var
  		gracz : Boolean;
  		xx,yy : LongInt;
  		kierunek : LongInt;
  		boiskop : ABoisko;
  		wynik : Boolean;
  		ile : LongInt;
  		stop : Boolean;
  	begin
  		xx := pilkax;
  		yy := pilkay;
  		gracz := true;
  		wynik := false;
  		ile := il;
  		stop := false;
  		skopiujABoisko(boiskoz,boiskop, szer,wys);
  		assert ((y >=0 ) and (y <= wys));
      assert ((x >=0 ) and (x <= szer));
  		if not boiskop[xx][yy].odwiedzony then
  		begin
  			gracz := not gracz;
  			ile := ile -1;
  		end;
  		if (yy = -1) and (xx = szer div 2) then
  		begin

  			ile := -1;
        if kBramki = 1 then
  			  wynik := true
        else
          wynik := false;
  		end
      else if (yy = wys+1) and (xx = szer div 2) then
  		begin

  			ile := -1;
        if kBramki = 1 then
  			  wynik := false
        else
          wynik := true;
  		end
  		else if (yy < 0 ) or ( yy > wys) then
  		begin
  			ile := -1;
  			wynik := false;
  		end;
  		while (ile > 0)and (not stop) do
  		begin
  			if czyMozna(boiskop,szer,wys,xx,yy) then
  			begin
  				kierunek := przesunPilke(boiskop,szer,wys,xx,yy);
  				if (yy >= 0) and ( yy <= wys) then
  				begin
  					if not boiskop[xx][yy].odwiedzony then
  					begin
  						gracz := not gracz;
  						ile := ile -1;
  					end;
  					boiskop[xx][yy].odwiedzony := true;
  					boiskop[xx][yy].ruch[przeciwny(kierunek)] := true;
  				end
  				else if (yy = -1) and (xx = szer div 2) then
  				begin
  					ile := -1;
            if kBramki = 1 then
      			  wynik := true
            else
              wynik := false;
  					stop := true;
  				end
  				else
  				begin
  					ile := -1;
  					if kBramki = 1 then
  			      wynik := false
            else
              wynik := true;
  					stop := true;
  				end;
  			end
  			else
  			begin
  				wynik := false;
  				stop := true;
  			end;
  		end;
  		if ile = 0 then
  		begin
  			if wycenPole(boiskoz,szer,wys,px,py,kBramki) < wycenPole(boiskop,szer,wys,xx,yy,kBramki) then
  				wynik := true
  			else
  				wynik := false;
  		end;
  		if ile > 0 then
  			wynik := false;
  		SetLength(boiskop,0,0);
  		losujRozgrywke := wynik;
  	end;

  	var
  		wygrane,przegrane : Real;
  		i,kier : LongInt;
      kopia : ABoisko;
  	begin
      //Losujemy rozgrywki i zliczamy prawdopodobienstwo wygranej z pola = wygrane / wszystkie rozgrywki.
  		wygrane := 0;
  		przegrane := 0;
      kier := zwrocKierunek(x,y,px,py);
      skopiujABoisko(boisko,kopia,szer,wys);
      kopia[x][y].ruch[przeciwny(kier)] := true;
      kopia[px][py].ruch[kier] := true;
  		for i := 1 to iloscSymulacji do
  		begin
  			if (y > 0) and ( y < wys) then
  			begin
  				if losujRozgrywke(kopia,szer,wys,iloscRuchow,x,y,px,py) then
  					wygrane := wygrane +1
  				else
  					przegrane := przegrane + 1;
  			end
  			else if ((y < 0) and (x = (szer div 2)))or ((y = 0)and (x > (szer div 2)-2 ) and (x < (szer div 2) +2)) then
        begin
          if kBramki = 1 then
  				  wygrane := wygrane +1
          else
            przegrane := przegrane +1;
        end
        else if ((y > wys) and (x = (szer div 2)))or ((y = wys)and (x > (szer div 2)-2 ) and (x < (szer div 2) +2)) then
        begin
          if kBramki <> 1 then
  				  wygrane := wygrane +1
          else
            przegrane := przegrane +1;
        end
        else if y = 0 then
  			begin
  				if losujRozgrywke(kopia,szer,wys,iloscRuchow,x,y,px,py) then
  					wygrane := wygrane +1
  				else
  					przegrane := przegrane + 1;
  			end
        else if y = wys then
  			begin
  				if losujRozgrywke(kopia,szer,wys,iloscRuchow,x,y,px,py) then
  					wygrane := wygrane +1
  				else
  					przegrane := przegrane + 1;
  			end
  			else
  				przegrane := przegrane + 1;
  		end;
  		//writeln(wygrane / (wygrane + przegrane));
  		okreslWartoscPola := wygrane / (wygrane + przegrane)
  	end;
  function funkcjaOceny(boisko : ABoisko;szer,wys,x,y,px,py,kBramki : LongInt) : LongInt;
  //Funkcja oceniająca, do którego pola warto pójść jeśli mamy takie samo
  //prawdopodobieństwo wygranej dla kilku pól.
	var
		wPola : LongInt;
		mozna : LongInt;
		i : LongInt;
	begin
		wPola := 0;
    if kBramki = 1 then
		  wPola := wPola + (wys-y)*200
    else
      wPola := wPola + y*200;
		wPola := wPola - modul((szer div 2)-x)*100;
		if boisko[x][y].odwiedzony then
		begin
			mozna := 0;
			wPola := wPola + 400;
			for i:= 0 to 7 do
			begin
				if not boisko[x][y].ruch[i] then
					mozna := mozna +1;
			end;
			if mozna < 2 then
				wPola := -200000000
			else
			begin
				wPola := wPola + (8-mozna)*300;
			end;
		end;
		funkcjaOceny := wPola;
	end;

  function graczSztuczny.wybierzKierunek(boiskos : ABoisko; px,py : LongInt) : LongInt;
  //Główna funkcja wybierająca kierunek, jest tutaj bardzo dużo kodu, gdyż musimy
  //rozważyć każdą niemalże odmienną pozycję na boisku i dla niej odmiennie wybrać
  //odpowiedni kierunek (odpalić dla dobrych pól(znajdujących sie na boisku)
  //funkcję określającą prawdopodobieństwo wygranej).
  var
    kBramki : LongInt;
	  kierunek : LongInt;
	  max : Real;
	  maxO : LongInt;
	  kO : Array[0..7] of LongInt;
	  k : array [0..7] of Real;
	  i : LongInt;
	  boisko : array [0..7] of ABoisko;
    boiskop : ABoisko;
	  x,y ,wys,szer,gora,dol: LongInt;
    pom : LongInt;
  begin
    if numerGracza = 1 then
      kBramki := 1
    else
      kBramki := -1;
    x := px;
		y := py;
		max := -1;
		maxO := -260000001;
    wys := wysokosc-1;
    szer := szerokosc-1;
		kierunek := random(8);
    skopiujABoisko(boiskos,boiskop, szer,wys);
		for i:= 0 to 7 do
		begin
			skopiujABoisko(boiskos,boisko[i], szer,wys);
		end;
    //Tutaj następuje mnóstwo kodu, który jest w zasadzie dosyć podobny, lecz
    //musimy go odpalić dla różnych kierunków. Trochę copypasty ale przynajmniej
    //wiemy dla jakich kierunków odpalamy gdzie. Plus ustalone są pozycje
    //wygrywające ( 8 pól przed bramkami).
    if (x > 0) and ( x < szer) then
		begin
			if (y > 0 ) and ( y < wys-1) then
			begin
				k[0] := okreslWartoscPola(boisko[0],szer,wys,x+1,y,x,y,kBramki);
				k[1] := okreslWartoscPola(boisko[1],szer,wys,x+1,y-1,x,y,kBramki);
				k[2] := okreslWartoscPola(boisko[2],szer,wys,x,y-1,x,y,kBramki);
				k[3] := okreslWartoscPola(boisko[3],szer,wys,x-1,y-1,x,y,kBramki);
				k[4] := okreslWartoscPola(boisko[4],szer,wys,x-1,y,x,y,kBramki);
				k[5] := okreslWartoscPola(boisko[5],szer,wys,x-1,y+1,x,y,kBramki);
				k[6] := okreslWartoscPola(boisko[6],szer,wys,x,y+1,x,y,kBramki);
				k[7] := okreslWartoscPola(boisko[7],szer,wys,x+1,y+1,x,y,kBramki);
				for i:= 0 to 7 do
				begin
					if (not boiskop[x][y].ruch[i]) and (k[i] > max)  then
					begin
						kierunek := i;
						max := k[i];
					end;
				end;
				kO[0] := funkcjaOceny(boisko[0],szer,wys,x+1,y,x,y,kBramki);
				kO[1] := funkcjaOceny(boisko[1],szer,wys,x+1,y-1,x,y,kBramki);
				kO[2] := funkcjaOceny(boisko[2],szer,wys,x,y-1,x,y,kBramki);
				kO[3] := funkcjaOceny(boisko[3],szer,wys,x-1,y-1,x,y,kBramki);
				kO[4] := funkcjaOceny(boisko[4],szer,wys,x-1,y,x,y,kBramki);
				kO[5] := funkcjaOceny(boisko[5],szer,wys,x-1,y+1,x,y,kBramki);
				kO[6] := funkcjaOceny(boisko[6],szer,wys,x,y+1,x,y,kBramki);
				kO[7] := funkcjaOceny(boisko[7],szer,wys,x+1,y+1,x,y,kBramki);
				for i:= 0 to 7 do
				begin
					if (not boiskop[x][y].ruch[i]) and (k[i] = max) then
					begin
						if kO[i] > maxO then
						begin
							maxO := kO[i];
							kierunek := i;
						end;
					end;
				end;
			end
			else if (y = 0) then
			begin
				if (x > (szer div 2 )- 2) and ( x < (szer div 2) + 2 ) and (kBramki = 1)then
				begin
					if x = (szer div 2) - 1 then
						kierunek := 1
					else if x = szer div 2 then
						kierunek := 2
					else
						kierunek := 3;
				end
        else if (x > (szer div 2 )- 2) and ( x < (szer div 2) + 2 ) and (kBramki <> 1) then
        begin
          if x = (szer div 2) - 1 then
          begin
    				k[0] := okreslWartoscPola(boisko[0],szer,wys,x+1,y,x,y,kBramki);
    				k[1] := okreslWartoscPola(boisko[1],szer,wys,x+1,y-1,x,y,kBramki);
    				k[5] := okreslWartoscPola(boisko[5],szer,wys,x-1,y+1,x,y,kBramki);
    				k[6] := okreslWartoscPola(boisko[6],szer,wys,x,y+1,x,y,kBramki);
    				k[7] := okreslWartoscPola(boisko[7],szer,wys,x+1,y+1,x,y,kBramki);
    				for i:= 0 to 1 do
    				begin
    					if (not boiskop[x][y].ruch[i]) and (k[i] > max)  then
    					begin
    						kierunek := i;
    						max := k[i];
    					end;
    				end;
            for i:= 5 to 7 do
    				begin
    					if (not boiskop[x][y].ruch[i]) and (k[i] > max)  then
    					begin
    						kierunek := i;
    						max := k[i];
    					end;
    				end;
    				kO[0] := funkcjaOceny(boisko[0],szer,wys,x+1,y,x,y,kBramki);
    				kO[1] := funkcjaOceny(boisko[1],szer,wys,x+1,y-1,x,y,kBramki);
    				kO[5] := funkcjaOceny(boisko[5],szer,wys,x-1,y+1,x,y,kBramki);
    				kO[6] := funkcjaOceny(boisko[6],szer,wys,x,y+1,x,y,kBramki);
    				kO[7] := funkcjaOceny(boisko[7],szer,wys,x+1,y+1,x,y,kBramki);
    				for i:= 0 to 1 do
    				begin
    					if (not boiskop[x][y].ruch[i]) and (k[i] = max) then
    					begin
    						if kO[i] > maxO then
    						begin
    							maxO := kO[i];
    							kierunek := i;
    						end;
    					end;
    				end;
            for i:= 5 to 7 do
    				begin
    					if (not boiskop[x][y].ruch[i]) and (k[i] = max) then
    					begin
    						if kO[i] > maxO then
    						begin
    							maxO := kO[i];
    							kierunek := i;
    						end;
    					end;
    				end;
          end
          else if x = szer div 2 then
          begin
    				k[0] := okreslWartoscPola(boisko[0],szer,wys,x+1,y,x,y,kBramki);
    				k[1] := okreslWartoscPola(boisko[1],szer,wys,x+1,y-1,x,y,kBramki);
    				k[2] := okreslWartoscPola(boisko[2],szer,wys,x,y-1,x,y,kBramki);
    				k[3] := okreslWartoscPola(boisko[3],szer,wys,x-1,y-1,x,y,kBramki);
    				k[4] := okreslWartoscPola(boisko[4],szer,wys,x-1,y,x,y,kBramki);
    				k[5] := okreslWartoscPola(boisko[5],szer,wys,x-1,y+1,x,y,kBramki);
    				k[6] := okreslWartoscPola(boisko[6],szer,wys,x,y+1,x,y,kBramki);
    				k[7] := okreslWartoscPola(boisko[7],szer,wys,x+1,y+1,x,y,kBramki);
    				for i:= 0 to 7 do
    				begin
    					if (not boiskop[x][y].ruch[i]) and (k[i] > max)  then
    					begin
    						kierunek := i;
    						max := k[i];
    					end;
    				end;
    				kO[0] := funkcjaOceny(boisko[0],szer,wys,x+1,y,x,y,kBramki);
    				kO[1] := funkcjaOceny(boisko[1],szer,wys,x+1,y-1,x,y,kBramki);
    				kO[2] := funkcjaOceny(boisko[2],szer,wys,x,y-1,x,y,kBramki);
    				kO[3] := funkcjaOceny(boisko[3],szer,wys,x-1,y-1,x,y,kBramki);
    				kO[4] := funkcjaOceny(boisko[4],szer,wys,x-1,y,x,y,kBramki);
    				kO[5] := funkcjaOceny(boisko[5],szer,wys,x-1,y+1,x,y,kBramki);
    				kO[6] := funkcjaOceny(boisko[6],szer,wys,x,y+1,x,y,kBramki);
    				kO[7] := funkcjaOceny(boisko[7],szer,wys,x+1,y+1,x,y,kBramki);
    				for i:= 0 to 7 do
    				begin
    					if (not boiskop[x][y].ruch[i]) and (k[i] = max) then
    					begin
    						if kO[i] > maxO then
    						begin
    							maxO := kO[i];
    							kierunek := i;
    						end;
    					end;
    				end;
          end
          else
          begin
    				k[3] := okreslWartoscPola(boisko[3],szer,wys,x-1,y-1,x,y,kBramki);
    				k[4] := okreslWartoscPola(boisko[4],szer,wys,x-1,y,x,y,kBramki);
    				k[5] := okreslWartoscPola(boisko[5],szer,wys,x-1,y+1,x,y,kBramki);
    				k[6] := okreslWartoscPola(boisko[6],szer,wys,x,y+1,x,y,kBramki);
    				k[7] := okreslWartoscPola(boisko[7],szer,wys,x+1,y+1,x,y,kBramki);
    				for i:= 3 to 7 do
    				begin
    					if (not boiskop[x][y].ruch[i]) and (k[i] > max)  then
    					begin
    						kierunek := i;
    						max := k[i];
    					end;
    				end;
    				kO[3] := funkcjaOceny(boisko[3],szer,wys,x-1,y-1,x,y,kBramki);
    				kO[4] := funkcjaOceny(boisko[4],szer,wys,x-1,y,x,y,kBramki);
    				kO[5] := funkcjaOceny(boisko[5],szer,wys,x-1,y+1,x,y,kBramki);
    				kO[6] := funkcjaOceny(boisko[6],szer,wys,x,y+1,x,y,kBramki);
    				kO[7] := funkcjaOceny(boisko[7],szer,wys,x+1,y+1,x,y,kBramki);
    				for i:= 3 to 7 do
    				begin
    					if (not boiskop[x][y].ruch[i]) and (k[i] = max) then
    					begin
    						if kO[i] > maxO then
    						begin
    							maxO := kO[i];
    							kierunek := i;
    						end;
    					end;
    				end;
          end;
        end
        else
				begin
					k[5] := okreslWartoscPola(boisko[5],szer,wys,x-1,y+1,x,y,kBramki);
					k[6] := okreslWartoscPola(boisko[6],szer,wys,x,y+1,x,y,kBramki);
					k[7] := okreslWartoscPola(boisko[7],szer,wys,x+1,y+1,x,y,kBramki);
					for i:= 5 to 7 do
					begin
						if (k[i] > max) and (not boiskop[x][y].ruch[i]) then
						begin
							kierunek := i;
							max := k[i];
						end;
					end;
				  kO[5] := funkcjaOceny(boisko[5],szer,wys,x-1,y+1,x,y,kBramki);
				  kO[6] := funkcjaOceny(boisko[6],szer,wys,x,y+1,x,y,kBramki);
				  kO[7] := funkcjaOceny(boisko[7],szer,wys,x+1,y+1,x,y,kBramki);
				  for i:= 5 to 7 do
				  begin
					  if (not boiskop[x][y].ruch[i]) and (k[i] = max) then
					  begin
						  if kO[i] > maxO then
						  begin
							  maxO := kO[i];
							  kierunek := i;
						  end;
					  end;
				  end;
				end;
			end
			else if y = 1 then
			begin
				if (x > (szer div 2) - 3) and ( x < (szer div 2) + 3)then
				begin
					if x = (szer div 2) -2 then
					begin
						kierunek := 1;
					end
					else if x = (szer div 2) - 1 then
					begin
						kierunek := 2;
					end
					else if x = szer div 2 then
					begin
						kierunek := 3;

					end
					else if x= (szer div 2 ) +1 then
					begin
						kierunek := 2;
					end
					else if x = (szer div 2 ) +2 then
					begin
						kierunek := 3;
					end;
          if kBramki <> 1 then
          begin
            pom := przeciwny(kierunek);
            kierunek := pom;
          end;
          if boiskop[x][y].ruch[kierunek] then
					begin
						k[0] := okreslWartoscPola(boisko[0],szer,wys,x+1,y,x,y,kBramki);
						k[1] := okreslWartoscPola(boisko[1],szer,wys,x+1,y-1,x,y,kBramki);
						k[2] := okreslWartoscPola(boisko[2],szer,wys,x,y-1,x,y,kBramki);
						k[3] := okreslWartoscPola(boisko[3],szer,wys,x-1,y-1,x,y,kBramki);
						k[4] := okreslWartoscPola(boisko[4],szer,wys,x-1,y,x,y,kBramki);
						k[5] := okreslWartoscPola(boisko[5],szer,wys,x-1,y+1,x,y,kBramki);
						k[6] := okreslWartoscPola(boisko[6],szer,wys,x,y+1,x,y,kBramki);
						k[7] := okreslWartoscPola(boisko[7],szer,wys,x+1,y+1,x,y,kBramki);
						for i:= 0 to 7 do
						begin
							if (not boiskop[x][y].ruch[i]) and (k[i] > max)  then
							begin
								kierunek := i;
								max := k[i];
							end;
						end;
						kO[0] := funkcjaOceny(boisko[0],szer,wys,x+1,y,x,y,kBramki);
						kO[1] := funkcjaOceny(boisko[1],szer,wys,x+1,y-1,x,y,kBramki);
						kO[2] := funkcjaOceny(boisko[2],szer,wys,x,y-1,x,y,kBramki);
						kO[3] := funkcjaOceny(boisko[3],szer,wys,x-1,y-1,x,y,kBramki);
						kO[4] := funkcjaOceny(boisko[4],szer,wys,x-1,y,x,y,kBramki);
						kO[5] := funkcjaOceny(boisko[5],szer,wys,x-1,y+1,x,y,kBramki);
						kO[6] := funkcjaOceny(boisko[6],szer,wys,x,y+1,x,y,kBramki);
						kO[7] := funkcjaOceny(boisko[7],szer,wys,x+1,y+1,x,y,kBramki);
						for i:= 0 to 7 do
						begin
							if (not boiskop[x][y].ruch[i]) and (k[i] = max) then
							begin
								if kO[i] > maxO then
								begin
									maxO := kO[i];
									kierunek := i;
								end;
							end;
						end;
					end;
				end
				else
				begin
					k[0] := okreslWartoscPola(boisko[0],szer,wys,x+1,y,x,y,kBramki);
					k[1] := okreslWartoscPola(boisko[1],szer,wys,x+1,y-1,x,y,kBramki);
					k[2] := okreslWartoscPola(boisko[2],szer,wys,x,y-1,x,y,kBramki);
					k[3] := okreslWartoscPola(boisko[3],szer,wys,x-1,y-1,x,y,kBramki);
					k[4] := okreslWartoscPola(boisko[4],szer,wys,x-1,y,x,y,kBramki);
					k[5] := okreslWartoscPola(boisko[5],szer,wys,x-1,y+1,x,y,kBramki);
					k[6] := okreslWartoscPola(boisko[6],szer,wys,x,y+1,x,y,kBramki);
					k[7] := okreslWartoscPola(boisko[7],szer,wys,x+1,y+1,x,y,kBramki);
					for i:= 0 to 7 do
					begin
						if (not boiskop[x][y].ruch[i]) and (k[i] > max)  then
						begin
							kierunek := i;
							max := k[i];
						end;
					end;
					kO[0] := funkcjaOceny(boisko[0],szer,wys,x+1,y,x,y,kBramki);
					kO[1] := funkcjaOceny(boisko[1],szer,wys,x+1,y-1,x,y,kBramki);
					kO[2] := funkcjaOceny(boisko[2],szer,wys,x,y-1,x,y,kBramki);
					kO[3] := funkcjaOceny(boisko[3],szer,wys,x-1,y-1,x,y,kBramki);
					kO[4] := funkcjaOceny(boisko[4],szer,wys,x-1,y,x,y,kBramki);
					kO[5] := funkcjaOceny(boisko[5],szer,wys,x-1,y+1,x,y,kBramki);
					kO[6] := funkcjaOceny(boisko[6],szer,wys,x,y+1,x,y,kBramki);
					kO[7] := funkcjaOceny(boisko[7],szer,wys,x+1,y+1,x,y,kBramki);
					for i:= 0 to 7 do
					begin
						if (not boiskop[x][y].ruch[i]) and (k[i] = max) then
						begin
							if kO[i] > maxO then
							begin
								maxO := kO[i];
								kierunek := i;
							end;
						end;
					end;
				end;
			end
      else if y = wys-1 then
      begin
				if (x > (szer div 2) - 3) and ( x < (szer div 2) + 3) then
				begin
					if x = (szer div 2) -2 then
					begin
						kierunek := 7;
					end
					else if x = (szer div 2) - 1 then
					begin
						kierunek := 6;
					end
					else if x = szer div 2 then
					begin
						kierunek := 7;

					end
					else if x= (szer div 2 ) +1 then
					begin
						kierunek := 6;
					end
					else if x = (szer div 2 ) +2 then
					begin
						kierunek := 5;
					end;
          if kBramki = 1 then
          begin
            pom := przeciwny(kierunek);
            kierunek := pom;
          end;
          if boiskop[x][y].ruch[kierunek] then
					begin
						k[0] := okreslWartoscPola(boisko[0],szer,wys,x+1,y,x,y,kBramki);
						k[1] := okreslWartoscPola(boisko[1],szer,wys,x+1,y-1,x,y,kBramki);
						k[2] := okreslWartoscPola(boisko[2],szer,wys,x,y-1,x,y,kBramki);
						k[3] := okreslWartoscPola(boisko[3],szer,wys,x-1,y-1,x,y,kBramki);
						k[4] := okreslWartoscPola(boisko[4],szer,wys,x-1,y,x,y,kBramki);
						k[5] := okreslWartoscPola(boisko[5],szer,wys,x-1,y+1,x,y,kBramki);
						k[6] := okreslWartoscPola(boisko[6],szer,wys,x,y+1,x,y,kBramki);
						k[7] := okreslWartoscPola(boisko[7],szer,wys,x+1,y+1,x,y,kBramki);
						for i:= 0 to 7 do
						begin
							if (not boiskop[x][y].ruch[i]) and (k[i] > max)  then
							begin
								kierunek := i;
								max := k[i];
							end;
						end;
						kO[0] := funkcjaOceny(boisko[0],szer,wys,x+1,y,x,y,kBramki);
						kO[1] := funkcjaOceny(boisko[1],szer,wys,x+1,y-1,x,y,kBramki);
						kO[2] := funkcjaOceny(boisko[2],szer,wys,x,y-1,x,y,kBramki);
						kO[3] := funkcjaOceny(boisko[3],szer,wys,x-1,y-1,x,y,kBramki);
						kO[4] := funkcjaOceny(boisko[4],szer,wys,x-1,y,x,y,kBramki);
						kO[5] := funkcjaOceny(boisko[5],szer,wys,x-1,y+1,x,y,kBramki);
						kO[6] := funkcjaOceny(boisko[6],szer,wys,x,y+1,x,y,kBramki);
						kO[7] := funkcjaOceny(boisko[7],szer,wys,x+1,y+1,x,y,kBramki);
						for i:= 0 to 7 do
						begin
							if (not boiskop[x][y].ruch[i]) and (k[i] = max) then
							begin
								if kO[i] > maxO then
								begin
									maxO := kO[i];
									kierunek := i;
								end;
							end;
						end;
					end;
				end
				else
				begin
					k[0] := okreslWartoscPola(boisko[0],szer,wys,x+1,y,x,y,kBramki);
					k[1] := okreslWartoscPola(boisko[1],szer,wys,x+1,y-1,x,y,kBramki);
					k[2] := okreslWartoscPola(boisko[2],szer,wys,x,y-1,x,y,kBramki);
					k[3] := okreslWartoscPola(boisko[3],szer,wys,x-1,y-1,x,y,kBramki);
					k[4] := okreslWartoscPola(boisko[4],szer,wys,x-1,y,x,y,kBramki);
					k[5] := okreslWartoscPola(boisko[5],szer,wys,x-1,y+1,x,y,kBramki);
					k[6] := okreslWartoscPola(boisko[6],szer,wys,x,y+1,x,y,kBramki);
					k[7] := okreslWartoscPola(boisko[7],szer,wys,x+1,y+1,x,y,kBramki);
					for i:= 0 to 7 do
					begin
						if (not boiskop[x][y].ruch[i]) and (k[i] > max)  then
						begin
							kierunek := i;
							max := k[i];
						end;
					end;
					kO[0] := funkcjaOceny(boisko[0],szer,wys,x+1,y,x,y,kBramki);
					kO[1] := funkcjaOceny(boisko[1],szer,wys,x+1,y-1,x,y,kBramki);
					kO[2] := funkcjaOceny(boisko[2],szer,wys,x,y-1,x,y,kBramki);
					kO[3] := funkcjaOceny(boisko[3],szer,wys,x-1,y-1,x,y,kBramki);
					kO[4] := funkcjaOceny(boisko[4],szer,wys,x-1,y,x,y,kBramki);
					kO[5] := funkcjaOceny(boisko[5],szer,wys,x-1,y+1,x,y,kBramki);
					kO[6] := funkcjaOceny(boisko[6],szer,wys,x,y+1,x,y,kBramki);
					kO[7] := funkcjaOceny(boisko[7],szer,wys,x+1,y+1,x,y,kBramki);
					for i:= 0 to 7 do
					begin
						if (not boiskop[x][y].ruch[i]) and (k[i] = max) then
						begin
							if kO[i] > maxO then
							begin
								maxO := kO[i];
								kierunek := i;
							end;
						end;
					end;
				end;
      end
      else if y = wys then
			begin
				if (x > (szer div 2) - 2) and ( x < (szer div 2) + 2 )and (kBramki = 1)then
				begin
					if x = (szer div 2) - 1 then
					begin
						k[7] := okreslWartoscPola(boisko[7],szer,wys,x+1,y+1,x,y,kBramki);
						k[0] := okreslWartoscPola(boisko[0],szer,wys,x+1,y,x,y,kBramki);
						k[1] := okreslWartoscPola(boisko[1],szer,wys,x+1,y-1,x,y,kBramki);
						k[2] := okreslWartoscPola(boisko[2],szer,wys,x,y-1,x,y,kBramki);
						k[3] := okreslWartoscPola(boisko[3],szer,wys,x-1,y-1,x,y,kBramki);
						for i:= 0 to 3 do
						begin
							if (k[i] > max) and (not boiskop[x][y].ruch[i]) then
							begin
								kierunek := i;
								max := k[i];
							end;
						end;
						if (k[7] > max) and (not boiskop[x][y].ruch[7]) then
						begin
							kierunek := 7;
							max := k[7];
						end;
						kO[0] := funkcjaOceny(boisko[0],szer,wys,x+1,y,x,y,kBramki);
						kO[1] := funkcjaOceny(boisko[1],szer,wys,x+1,y-1,x,y,kBramki);
						kO[2] := funkcjaOceny(boisko[2],szer,wys,x,y-1,x,y,kBramki);
						kO[3] := funkcjaOceny(boisko[3],szer,wys,x-1,y-1,x,y,kBramki);
						kO[7] := funkcjaOceny(boisko[7],szer,wys,x+1,y+1,x,y,kBramki);
						for i:= 0 to 3 do
						begin
							if (not boiskop[x][y].ruch[i]) and (k[i] = max) then
							begin
								if kO[i] > maxO then
								begin
									maxO := kO[i];
									kierunek := i;
								end;
							end;
						end;
						if (k[7] = max) and (not boiskop[x][y].ruch[7]) then
						begin
							if kO[i] > maxO then
							begin
								maxO := kO[i];
								kierunek := i;
							end;
						end;
					end
					else if x = szer div 2 then
					begin
						k[0] := okreslWartoscPola(boisko[0],szer,wys,x+1,y,x,y,kBramki);
						k[1] := okreslWartoscPola(boisko[1],szer,wys,x+1,y-1,x,y,kBramki);
						k[2] := okreslWartoscPola(boisko[2],szer,wys,x,y-1,x,y,kBramki);
						k[3] := okreslWartoscPola(boisko[3],szer,wys,x-1,y-1,x,y,kBramki);
						k[4] := okreslWartoscPola(boisko[4],szer,wys,x-1,y,x,y,kBramki);
						k[5] := okreslWartoscPola(boisko[5],szer,wys,x-1,y+1,x,y,kBramki);
						k[6] := okreslWartoscPola(boisko[6],szer,wys,x,y+1,x,y,kBramki);
						k[7] := okreslWartoscPola(boisko[7],szer,wys,x+1,y+1,x,y,kBramki);
						for i:= 0 to 7 do
						begin
							if (k[i] > max) and (not boiskop[x][y].ruch[i]) then
							begin
								kierunek := i;
								max := k[i];
							end;
						end;
						kO[0] := funkcjaOceny(boisko[0],szer,wys,x+1,y,x,y,kBramki);
						kO[1] := funkcjaOceny(boisko[1],szer,wys,x+1,y-1,x,y,kBramki);
						kO[2] := funkcjaOceny(boisko[2],szer,wys,x,y-1,x,y,kBramki);
						kO[3] := funkcjaOceny(boisko[3],szer,wys,x-1,y-1,x,y,kBramki);
						kO[4] := funkcjaOceny(boisko[4],szer,wys,x-1,y,x,y,kBramki);
						kO[5] := funkcjaOceny(boisko[5],szer,wys,x-1,y+1,x,y,kBramki);
						kO[6] := funkcjaOceny(boisko[6],szer,wys,x,y+1,x,y,kBramki);
						kO[7] := funkcjaOceny(boisko[7],szer,wys,x+1,y+1,x,y,kBramki);
						for i:= 0 to 7 do
						begin
							if (not boiskop[x][y].ruch[i]) and (k[i] = max) then
							begin
								if kO[i] > maxO then
								begin
									maxO := kO[i];
									kierunek := i;
								end;
							end;
						end;
					end
          else
					begin
						k[1] := okreslWartoscPola(boisko[1],szer,wys,x+1,y-1,x,y,kBramki);
						k[2] := okreslWartoscPola(boisko[2],szer,wys,x,y-1,x,y,kBramki);
						k[3] := okreslWartoscPola(boisko[3],szer,wys,x-1,y-1,x,y,kBramki);
						k[4] := okreslWartoscPola(boisko[4],szer,wys,x-1,y,x,y,kBramki);
						k[5] := okreslWartoscPola(boisko[5],szer,wys,x-1,y+1,x,y,kBramki);
						for i:= 1 to 5 do
						begin
							if (k[i] > max) and (not boiskop[x][y].ruch[i]) then
							begin
								kierunek := i;
								max := k[i];
							end;
						end;
						kO[1] := funkcjaOceny(boisko[1],szer,wys,x+1,y-1,x,y,kBramki);
						kO[2] := funkcjaOceny(boisko[2],szer,wys,x,y-1,x,y,kBramki);
						kO[3] := funkcjaOceny(boisko[3],szer,wys,x-1,y-1,x,y,kBramki);
						kO[4] := funkcjaOceny(boisko[4],szer,wys,x-1,y,x,y,kBramki);
						kO[5] := funkcjaOceny(boisko[5],szer,wys,x-1,y+1,x,y,kBramki);
						for i:= 1 to 5 do
						begin
							if (not boiskop[x][y].ruch[i]) and (k[i] = max) then
							begin
								if kO[i] > maxO then
								begin
									maxO := kO[i];
									kierunek := i;
								end;
							end;
						end;
					end;
				end
				else if (x > (szer div 2) - 2) and ( x < (szer div 2) + 2 )and (kBramki <> 1) then
        begin
        	if x = (szer div 2) - 1 then
						kierunek := 7
					else if x = szer div 2 then
						kierunek := 6
					else
						kierunek := 5;
        end
				else
				begin
					k[1] := okreslWartoscPola(boisko[1],szer,wys,x-1,y+1,x,y,kBramki);
					k[2] := okreslWartoscPola(boisko[2],szer,wys,x,y+1,x,y,kBramki);
					k[3] := okreslWartoscPola(boisko[3],szer,wys,x+1,y+1,x,y,kBramki);
					for i:= 1 to 3 do
					begin
						if (k[i] > max) and (not boiskop[x][y].ruch[i]) then
						begin
							kierunek := i;
							max := k[i];
						end;
					end;
					kO[1] := funkcjaOceny(boisko[1],szer,wys,x+1,y-1,x,y,kBramki);
					kO[2] := funkcjaOceny(boisko[2],szer,wys,x,y-1,x,y,kBramki);
					kO[3] := funkcjaOceny(boisko[3],szer,wys,x-1,y-1,x,y,kBramki);
					for i:= 1 to 3 do
					begin
						if (not boiskop[x][y].ruch[i]) and (k[i] = max) then
						begin
							if kO[i] > maxO then
							begin
								maxO := kO[i];
								kierunek := i;
							end;
						end;
					end;
				end;
			end;
		end
		else
		begin
			if x = 0 then
			begin
				k[0] := okreslWartoscPola(boisko[0],szer,wys,x+1,y,x,y,kBramki);
				k[1] := okreslWartoscPola(boisko[1],szer,wys,x+1,y-1,x,y,kBramki);
				k[7] := okreslWartoscPola(boisko[7],szer,wys,x+1,y+1,x,y,kBramki);
				for i:= 0 to 1 do
				begin
					if (k[i] > max) and (not boiskop[x][y].ruch[i]) then
					begin
						kierunek := i;
						max := k[i];
					end;
				end;
				if (k[7] > max) and (not boiskop[x][y].ruch[7]) then
				begin
					kierunek := 7;
					max := k[7];
				end;
				{kO[0] := funkcjaOceny(boisko[0],szer,wys,x+1,y,x,y,kBramki);
				kO[1] := funkcjaOceny(boisko[1],szer,wys,x+1,y-1,x,y,kBramki);
				kO[7] := funkcjaOceny(boisko[7],szer,wys,x+1,y+1,x,y,kBramki);
				for i:= 0 to 1 do
				begin
					if (not boiskop[x][y].ruch[i]) and (k[i] = max) then
					begin
						if kO[i] > maxO then
						begin
							maxO := kO[i];
							kierunek := i;
						end;
					end;
				end;
				if (k[7] = max) and (not boiskop[x][y].ruch[7]) then
				begin
					if kO[i] > maxO then
					begin
						maxO := kO[i];
						kierunek := i;
					end;
				end;}
			end
			else if x = szer then
			begin
				k[3] := okreslWartoscPola(boisko[3],szer,wys,x-1,y-1,x,y,kBramki);
				k[4] := okreslWartoscPola(boisko[4],szer,wys,x-1,y,x,y,kBramki);
				k[5] := okreslWartoscPola(boisko[5],szer,wys,x-1,y+1,x,y,kBramki);
				for i:= 3 to 5 do
				begin
					if (k[i] > max) and (not boiskop[x][y].ruch[i]) then
					begin
						kierunek := i;
						max := k[i];
					end;
				end;
			{	kO[3] := funkcjaOceny(boisko[3],szer,wys,x-1,y-1,x,y,kBramki);
				kO[4] := funkcjaOceny(boisko[4],szer,wys,x-1,y,x,y,kBramki);
				kO[5] := funkcjaOceny(boisko[5],szer,wys,x-1,y+1,x,y,kBramki);
				for i:= 3 to 5 do
				begin
					if (not boiskop[x][y].ruch[i]) and (k[i] = max) then
					begin
						if kO[i] > maxO then
						begin
							maxO := kO[i];
							kierunek := i;
						end;
					end;
				end; }
			end;
		end;
    //Zwracamy wybrany kierunek.
    wybierzKierunek := kierunek;
  end;

  procedure graczSztuczny.wykonajRuch;
  //Procedura wykonująca ruch przez komputer i zaznaczająca go na boisku.
  var
    kierunek : LongInt;
    x, y : LongInt;
    boiskos : ABoisko;
  begin
    randomize;
    x := Boisko.pilkax;
    y := Boisko.pilkay;
    skopiujBoisko(boiskos,Boisko.szerokosc-1,Boisko.wysokosc-1);
    kierunek := wybierzKierunek(boiskos,Boisko.pilkax-1,Boisko.pilkay-1);
    assert(kierunek >= 0);
    if kierunek = 0 then
    begin
      x := x +1;
    end
    else if kierunek = 1 then
    begin
      x := x +1;
      y := y -1;
    end
    else if kierunek = 2 then
    begin
      y := y -1;
    end
    else if kierunek = 3 then
    begin
      x := x -1;
      y := y -1;
    end
    else if kierunek = 4 then
    begin
      x := x -1;
    end
    else if kierunek = 5 then
    begin
      x := x -1;
      y := y +1;
    end
    else if kierunek = 6 then
    begin
      y := y +1;
    end
    else if kierunek = 7 then
    begin
      y := y +1;
      x := x +1;
    end;
    Boisko.polaKlikane[x][y].Click(Boisko.polaKlikane[x][y]);
  end;

  procedure graczSztuczny.wykonajRuch_FAILSAFE;
  //Failsafe na razie z niego nie korzystamy...
  var
    kierunek : LongInt;
    x, y : LongInt;
  begin
    randomize;
    x := Boisko.pilkax;
    y := Boisko.pilkay;
    kierunek := random(8);
    assert(kierunek >= 0);
    if kierunek = 0 then
    begin
      x := x +1;
    end
    else if kierunek = 1 then
    begin
      x := x +1;
      y := y -1;
    end
    else if kierunek = 2 then
    begin
      y := y -1;
    end
    else if kierunek = 3 then
    begin
      x := x -1;
      y := y -1;
    end
    else if kierunek = 4 then
    begin
      x := x -1;
    end
    else if kierunek = 5 then
    begin
      x := x -1;
      y := y +1;
    end
    else if kierunek = 6 then
    begin
      y := y +1;
    end
    else if kierunek = 7 then
    begin
      y := y +1;
      x := x +1;
    end;
    Boisko.polaKlikane[x][y].Click(Boisko.polaKlikane[x][y]);
  end;
  var
    listaScianPodpowiedzi : ListaScian;

  procedure graczSztuczny.usunPodpowiedz(t : TWinControl);
  //Usuwamy podpowiedzi.
  var
    pom : ListaScian;
  begin
    while listaScianPodpowiedzi <> nil do
    begin
      if listaScianPodpowiedzi^.s <> nil then
        listaScianPodpowiedzi^.s.destroy;
      pom := listaScianPodpowiedzi^.nast;
      dispose(listaScianPodpowiedzi);
      listaScianPodpowiedzi := pom;
    end;
  end;

  procedure graczSztuczny.zaznaczPodpowiedz(t : TWinControl);
  //Procedure zaznaczająca podpowiedź.
  var
    kierunek : LongInt;
    x, y : LongInt;
    nowy : ListaScian;
    boiskos : ABoisko;
  begin
    randomize;
    x := Boisko.pilkax-1;
    y := Boisko.pilkay-1;
    listaScianPodpowiedzi := nil;
    skopiujBoisko(boiskos,Boisko.szerokosc-1,Boisko.wysokosc-1);
    while (y >= 0) and (y <= Boisko.wysokosc-1) and (boiskos[x][y].odwiedzony = true)  do
    begin
      kierunek := wybierzKierunek(boiskos,x,y);
      assert(kierunek >= 0);
      boiskos[x][y].ruch[kierunek] := true;
      if kierunek = 0 then
      begin
        x := x +1;
      end
      else if kierunek = 1 then
      begin
        x := x +1;
        y := y -1;
      end
      else if kierunek = 2 then
      begin
        y := y -1;
      end
      else if kierunek = 3 then
      begin
        x := x -1;
        y := y -1;
      end
      else if kierunek = 4 then
      begin
        x := x -1;
      end
      else if kierunek = 5 then
      begin
        x := x -1;
        y := y +1;
      end
      else if kierunek = 6 then
      begin
        y := y +1;
      end
      else if kierunek = 7 then
      begin
        y := y +1;
        x := x +1;
      end;
      new(nowy);
      if (y >= 0) and (y <= Boisko.wysokosc-1) then
        boiskos[x][y].ruch[przeciwny(kierunek)] := true;
      x := x+1;
      y := y+1;
      Boisko.polaczPodpowiedz(x,y,kierunek,t);
      nowy^.s := Boisko.sciany[x][y][kierunek+10];
      nowy^.nast := listaScianPodpowiedzi;
      listaScianPodpowiedzi := nowy;
      x := x-1;
      y := y-1;
    end;
  end;

end.

