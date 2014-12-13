{Franciszek Jemioło - nr indeksu 346919, zad1}
program zad1;
uses drzewo;

const
	MAX_POLECEN = 1000000;
	MAX_KLUCZ = 1000000000;
	MAX_VAL = 1000;
	MAX_LONGINT = 2147483647;

procedure wypiszBlad();
{Procedura wypisująca zignorowano na wyjście.}
begin
	writeln('zignorowano');
end;

function chrToLongInt(c : Char) : LongInt;
{Pomocnicza funkcja zamieniajaca char na Longint}
begin
	chrToLongInt := ord(c)-48;
end;

function pusty(s : String; i : LongInt) : Boolean;
{Sprawdza czy wczytany string ma odpowiednią długość.}
begin
	if Length(s) < i then
		pusty := true
	else
		pusty := false;
end;


function strToLongInt(s : String; var liczba : LongInt) : Boolean;
{Pomocnicza funkcja zamieniajaca string na LongInt}
var
	pom : LongInt;
	potega10 : LongInt;
	i : LongInt;
	czyPoprawna : Boolean;
begin
	czyPoprawna := true;
	pom := 0;
	potega10 := 1;
	i := Length(s);
	while i > 0 do
	{Wczytujac liczbe musimy sprawdzić czy ma ona chociaż szansę zmieścić się w LongIntcie oraz w zakresie dla funkcji.}
	begin
		pom := potega10 * chrToLongInt(s[i]) + pom;
		i := i - 1;		
		if potega10 <= (MAX_KLUCZ div 10) then
			potega10 := potega10 * 10
		else
		begin
			if chrToLongInt(s[i+1]) <> 1 then
				czyPoprawna := false;
			break;
		end;

	end;
	liczba := pom;
	strToLongInt := czyPoprawna;
end;

function wczytujPokiLiczba(s : String; var i : LongInt) : Boolean;
{Funkcja zwiększająca iterator póki wczytywana jest liczba.}
var
	j : LongInt;
begin
	j := i;
	if ord(s[i]) = ord('0') then
	begin
		i := i+1;
		if pusty(s,i) or ((ord(s[i]) < ord('0')) or (ord(s[i]) > ord('9'))) then
			wczytujPokiLiczba := true
		else
			wczytujPokiLiczba := false;
	end
	else
	begin
		while (not pusty(s,i)) and (ord(s[i]) >= ord('0')) and (ord(s[i]) <= ord('9')) do
		begin
			i := i + 1;
		end;
		{Sprawdzamy czy liczba może sie zmieścić w zakresie}
		if i-j <= 10 then
			wczytujPokiLiczba := j <> i
		else
			wczytujPokiLiczba := false;
	end;
end;


var
	polecen : LongInt; {liczba poleceń}
	wejscie : String; {wczytywane polecenie}
	i, j : LongInt; {iteratory}
	{Pomocnicze wartości}
	wstawianyKlucz : LongInt;
	wstawianyArgument : LongInt;
	lewyArg : LongInt;
	prawyArg : LongInt;
	nrFunk : LongInt;
	wypisanaSuma : LongInt;
	wypisaneWezly : LongInt;
begin
	inicjuj;
	polecen := 0;
	while not eof do
	begin
		readln(wejscie);
		if polecen < MAX_POLECEN then
			begin
			if (not pusty(wejscie,2)) and (wejscie[1] = 'f') and (wejscie[2] = '(') then
			{Sprawdzamy poprawność przypisania funkcji f}
			begin
				i := 3;
				if not wczytujPokiLiczba(wejscie,i) then
				begin
					wypiszBlad();
				end
				else
				begin
					{Sprawdzamy czy wczytaliśmy poprawną liczbę i czy po niej jest nawias.}
					if (strToLongInt(Copy(wejscie, 3, i-3),wstawianyKlucz)) and (not pusty(wejscie, i)) and (wejscie[i] = ')') then
					begin
						i := i + 1;
						if (not pusty(wejscie, i+1)) and (Copy(wejscie, i, 2) = ':=') then
						begin
							i := i + 2;
							j := i;
							if not wczytujPokiLiczba(wejscie,i) then
							begin
								wypiszBlad();
							end
							else if Length(wejscie) <>i-1 then
							begin
								wypiszBlad();
							end
							else
							begin
								if strToLongInt(Copy(wejscie, j, i-j),wstawianyArgument) then
								begin
									if  ((0 <= wstawianyKlucz) and (wstawianyKlucz <= MAX_KLUCZ)) and ((0 <= wstawianyArgument) and (wstawianyArgument <= MAX_VAL)) then 
									begin
										{Jeśli polecenie było poprawne zwiekszamy ilość polecen oraz tworzymy Drzewo Dt.}
										polecen := polecen +1;
										writeln('wezlow: ',przypisanie(wstawianyKlucz,wstawianyArgument));
									end
									else
									begin
										wypiszBlad();
									end;
								end
								else
								begin
									wypiszBlad();
								end;
							end;
						end
						else
						begin
							wypiszBlad();
						end
					end
					else
					begin
						wypiszBlad();
					end;
				end
			end

			else if (not pusty(wejscie,5))and (Copy(wejscie,1,5) = 'suma(') then
			{Sprawdzamy poprawność wpisania polecenia dla sumy.}
			begin
				i := 6;
				if not wczytujPokiLiczba(wejscie,i) then
				begin
					wypiszBlad();
				end
				else
				begin
					if (StrToLongInt(Copy(wejscie, 6, i-6),nrFunk)) and (not pusty(wejscie,i)) and (wejscie[i] = ',') then
					begin
						i := i + 1;
						j := i;
						if not wczytujPokiLiczba(wejscie,i) then
						begin
							wypiszBlad();
						end
						else
						begin
							if (StrToLongInt(Copy(wejscie, j, i-j),lewyArg)) and (not pusty(wejscie, i+1)) and (Copy(wejscie,i,2) = '..') then
							begin
								i := i+2;
								j := i;
								if not wczytujPokiLiczba(wejscie,i) then
								begin
	 								wypiszBlad();
								end
								else
								begin
									if (StrToLongInt(Copy(wejscie, j, i-j), prawyArg)) and (Length(wejscie) = i) and (wejscie[i] = ')') then
									begin
										wypisanaSuma := suma(nrFunk, lewyArg, prawyArg);
										if wypisanaSuma >= 0 then
										begin
											{Jeśli suma była poprawna to ją wypisujemy.}
											writeln(wejscie,'=',wypisanaSuma);
											polecen := polecen +1;
										end
										else
										begin
											wypiszBlad();
										end;
									end
									else
									begin
										wypiszBlad();
									end;
								end;
							end
							else
							begin
								wypiszBlad();
							end
						end
					end
					else
					begin
						wypiszBlad();
					end;
				end
			end

			else if (not pusty(wejscie,6)) and (Copy(wejscie,1,6) = 'czysc(') then
			{Sprawdzamy poprawnosc wpisania polecenia dla czysc}
			begin
				i := 7;
				if not wczytujPokiLiczba(wejscie,i) then
				begin
					wypiszBlad();
				end
				else
				begin
					if (StrToLongInt(Copy(wejscie,7,i-7), nrFunk)) and (Length(wejscie) = i) and (wejscie[i] = ')') then
					begin
						wypisaneWezly := czysc(nrFunk);
						if wypisaneWezly >= 0 then
						begin
							{Jeśli czyść zwróciło poprawną ilość węzłów to wypisujemy.}
							writeln('wezlow: ',wypisaneWezly);
							polecen := polecen +1;
						end
						else
							wypiszBlad();
					end
					else
					begin
						wypiszBlad();
					end;
				end
			end

			else
			begin
				wypiszBlad();
			end;
		end
		else
			wypiszBlad();
	end;
	{Usuwamy wszystkie drzewa.}
	zwolnijPamiecNaKoniec;
end.
