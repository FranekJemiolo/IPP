{Franciszek Jemioło - nr indeksu 346919, moduł Drzewo}
unit Drzewo;

interface

type 
	MyType = record
		key : LongInt;
		val : LongInt;
		ref : LongInt;
		sum : LongInt;
	end;
	Tree = ^Node;
	Node = record
		v : MyType;
		left,right : Tree;
	end;
	TreeTab = array [1..1000001] of Tree; 
	procedure inicjuj;
	function przypisanie(argument, wartosc : LongInt) : LongInt;
	function suma(nr_funkcji, lewy_argument, prawy_argument : LongInt) : LongInt;
	function czysc(nr_funkcji : LongInt) : LongInt;
	procedure zwolnijPamiecNaKoniec;
	
implementation

var
	tablicaDrzew : TreeTab;
	indeksPrzypisania : LongInt;
	wezlow : LongInt;

procedure inicjuj;
{Procedura inicjująca tablicę drzew.}
var
	i : LongInt;
begin
	wezlow := 0;
	indeksPrzypisania := 0;
	for i:=1 to 1000001 do
	begin
		tablicaDrzew[i] := nil;
	end;
end;

function czyIstniejeWezel(t : Tree; argument, wartosc : LongInt) : Boolean;
{W tej funkcji sprawdzamy czy istnieje węzeł w drzewie o podanym argumencie i wartości.}
var
	zwroc : Boolean;
begin
	zwroc := false;
	while t <> nil do
	begin
		if t^.v.key > argument then
			t := t^.left
		else if t^.v.key < argument then
			t := t^.right
		else
		begin
			zwroc := (wartosc = t^.v.val);
			break;
		end;
	end;
	czyIstniejeWezel := zwroc;
end;

function tworzNowyWezel (arg,val : LongInt) : Tree;
{Tworzymy nowy wezel ktory ma puste poddrzewa.}
var
	newt : Tree;
begin
	new(newt);
	newt^.v.key := arg;
	newt^.v.val := val;
	newt^.v.sum := val;
	newt^.v.ref := 1;
	newt^.left := nil;
	newt^.right := nil;
	tworzNowyWezel := newt;
	wezlow := wezlow + 1;	
end;

function zwrocWartoscWezla(t : Tree; argument : LongInt) : LongInt;
{Funkcja zwraca wartość węzła o podanym argumencie (kluczu).}
begin
	zwrocWartoscWezla := 0;
	while t <> nil do
	begin
		if t^.v.key > argument then
			t := t^.left
		else if t^.v.key < argument then
			t := t^.right
		else
		begin
			zwrocWartoscWezla := t^.v.val;
			break;
		end
	end;
end;

function zwrocMinWartosc(t : Tree) : MyType;
{Zwraca MyType z węzła, który ma najmniejszy klucz w drzewie.}
var
	v : MyType;
begin
	v.key := -1;
	v.val := -1;
	if t <> nil then
	begin
		while t^.left <> nil do
		begin
			t := t^.left;
		end;
		zwrocMinWartosc := t^.v;
	end
	else
		zwrocMinWartosc := v;
end;

function stworzNowyWezel(poprzedniaWartosc,wstawianaWartosc : LongInt; t : Tree): Tree;
{Funkcja zwracająca nowy węzeł drzewa ze zmienioną sumą i referencją ustawioną na 1}
var
	newt : Tree;
begin
	if t <> nil then
	begin	
		new(newt);
		newt^.v.key := t^.v.key;
		newt^.v.val := t^.v.val;
		newt^.v.sum := t^.v.sum + wstawianaWartosc - poprzedniaWartosc;
		newt^.v.ref := 1;
		newt^.left := t^.left;
		newt^.right := t^.right;
		stworzNowyWezel := newt; 
		wezlow := wezlow + 1;
	end
	else
		stworzNowyWezel := nil;
end;

procedure zwiekszRef(var t : Tree);
{W tej procedurze zwiekszamy referencję podanego węzła.}
begin
	if t <> nil then
		t^.v.ref := t^.v.ref + 1;
end;

function zmienWartoscWezla(val : LongInt;var t : Tree) : Tree;
{Zmieniamy wartość węzła.}
begin
	if t <> nil then
	begin
		t^.v.val := val;
		t^.v.ref := 1;
		zmienWartoscWezla := t; 
	end
	else
		zmienWartoscWezla := nil;
end;

function wstawDoDrzewa(arg,val : LongInt;var t : Tree): Tree;
{W tej procedurze tworzymy drzewo Dt wstawiajac do drzewa Dt-1}
var
	parent : Tree;
	root : Tree;
	pop : LongInt;
	stop : Boolean;
begin
	root := t;
	parent := t;
	pop := zwrocWartoscWezla(t,arg);
	{Pamiętamy poprzednią wartość węzła o danym kluczu, jeśli takowa istniała.}
	t^.v.sum := t^.v.sum - pop;
	stop := false;
	while (t <> nil) and (not stop) do
	{W tej pętli tworzymy nowe węzły i w zależności czy musimy tworzyc nowe czy nie podczepiamy elementy drzewa D t-1}
	begin
		if t^.v.key < arg then
		begin
			parent := t;
			t^.right := stworzNowyWezel(pop,val,t^.right);
			zwiekszRef(t^.left);
			t := t^.right;
		end
		else if t^.v.key > arg then
		begin
			parent := t;
			t^.left := stworzNowyWezel(pop,val,t^.left);
			zwiekszRef(t^.right);
			t := t^.left;
		end
		else
		begin
			{Zmieniamy węzeł w drzewie na daną wartość.}
			if parent^.v.key < arg then
			begin
				parent^.right := zmienWartoscWezla(val, t);
			end
			else if parent^.v.key > arg then
			begin
				parent^.left := zmienWartoscWezla(val, t);
			end
			else
			{Zmieniamy korzen}
			begin
				t := zmienWartoscWezla(val,t);
				root := t;
			end;
			zwiekszRef(t^.right);
			zwiekszRef(t^.left);
			stop := true;
		end;
	end;
	if (t = nil) and (not stop) then
	{Doszliśmy na koniec drzewa, bądź było ono puste.}
	begin
		if root <> nil then
		begin
			{Wstawiamy węzeł i podpinamy go do jego ojca.}
			if parent^.v.key < arg then
			begin
				parent^.right := tworzNowyWezel(arg,val);
			end
			else
			begin
				parent^.left := tworzNowyWezel(arg,val);
			end;	
		end
		else
		begin
			{Drzewo było puste, więc tworzymy nowy korzeń.}
			t := tworzNowyWezel(arg,val);
			root := t;
		end;
	end;
	wstawDoDrzewa := root;
end;

function usunMin(var t : Tree) : Tree;
{Ta funkcja zwraca zmienione drzewo t z usuniętą najmniejszą wartością.}
var
	root : Tree;
	parent : Tree;
	min : MyType;
begin
	if t <> nil then
	begin
		min := zwrocMinWartosc(t);
		t := stworzNowyWezel(min.val,0,t);
		root := t;
		parent := t;
		while t^.left <> nil do
		begin
			if t^.left <> nil then
				parent := t;
			t^.left := stworzNowyWezel(min.val,0,t^.left);
			zwiekszRef(t^.right);
			t := t^.left;
		end;
		{Musimy sprawdzić czy usuwany węzeł jest korzeniem tego drzewa czy nie.}
		if parent^.v.key <> min.key then
		begin
			if t^.right <> nil then
				parent^.left := t^.right
			else
				parent^.left := nil;
			usunMin := root;			
		end
		else
			usunMin := parent^.right;
		zwiekszRef(t^.right);
		{Usuwamy nadmierny węzeł.}
		dispose(t);
		wezlow := wezlow -1;
	end
	else
		usunMin := nil;
end;



function stworzUsuniete(arg,val : LongInt;var t : Tree) : Tree;
{W tej procedurze tworzymy drzewo Dt z usunietym wezlem z drzewa Dt-1}
var
	parent : Tree;
	root : Tree;
	pom : Tree;
begin
	root := t;
	parent := t;
	if t <> nil then
		t^.v.sum := t^.v.sum - val;
	while t <> nil do
	{Tworzymy nowe węzły dopóki nie natrafimy na węzeł o danym argumencie.}
	begin
		if t^.v.key < arg then
		begin
			parent := t;
			t^.right := stworzNowyWezel(val,0,t^.right);
			zwiekszRef(t^.left);
			t := t^.right;
		end
		else if t^.v.key > arg then
		begin
			parent := t;
			t^.left := stworzNowyWezel(val,0,t^.left);
			zwiekszRef(t^.right);
			t := t^.left;
		end
		else
		begin
			{W zależności od tego czy usuwany element ma puste prawe poddrzewo }
			{zamieniamy je na jego lewe poddrzewo bądź ustawiamy je na minimalną}
			{wartość z prawego poddrzewa. Sprawdzamy też czy usuwany węzeł jest}
			{lewym czy prawym synem swojego ojca.}
			if parent^.v.key < arg then
			begin
				if t^.right <> nil then
				begin
					t^.v := zwrocMinWartosc(t^.right);
					t^.v.ref := 1;
					t^.right := usunMin(t^.right);
					t^.v.sum := t^.v.val;
					if t^.left <> nil then
						t^.v.sum := t^.v.sum + t^.left^.v.sum;
					if t^.right <> nil then
						t^.v.sum := t^.v.sum + t^.right^.v.sum;
					zwiekszRef(t^.left);
				end
				else
				begin
					zwiekszRef(t^.left);
					parent^.right := t^.left;
					dispose(t);
					wezlow := wezlow - 1;
				end;
			end
			else if parent^.v.key > arg then
			begin
				if t^.right <> nil then
				begin
					t^.v := zwrocMinWartosc(t^.right);
					t^.v.ref := 1;
					t^.right := usunMin(t^.right);
					t^.v.sum := t^.v.val;
					if t^.left <> nil then
						t^.v.sum := t^.v.sum + t^.left^.v.sum;
					if t^.right <> nil then
						t^.v.sum := t^.v.sum + t^.right^.v.sum;
					zwiekszRef(t^.left);
				end
				else
				begin
					zwiekszRef(t^.left);
					parent^.left := t^.left;
					dispose(t);
					wezlow := wezlow - 1;
				end;
			end
			else
			{Usuwamy korzeń.}
			begin
				if t^.right <> nil then
				begin
					t^.v := zwrocMinWartosc(t^.right);
					t^.v.ref := 1;
					t^.right := usunMin(t^.right);
					t^.v.sum := t^.v.val;
					if t^.left <> nil then
						t^.v.sum := t^.v.sum + t^.left^.v.sum;
					if t^.right <> nil then
						t^.v.sum := t^.v.sum + t^.right^.v.sum;
					root := t;
					zwiekszRef(t^.left);
				end
				else
				begin
					zwiekszRef(t^.left);
					pom := t^.left;
					dispose(t);
					wezlow := wezlow - 1;
					t := pom;
					root := t;
				end;
			end;
			break;
		end;
	end;
	stworzUsuniete := root;
end;


function przypisanie(argument, wartosc : LongInt) : LongInt;
{Funkcja tworząca i zapisująca w tablicy drzewo Dt.}
var
	t : Tree;
	root : Tree;
	atrapa : Tree;
	usuwanaWartosc : LongInt;
begin
	{Tworzymy atrapę, która będzie pamiętać wskaźnik na korzeń drzewa Dt.}
	new(atrapa);
	if (indeksPrzypisania > 0) and (tablicaDrzew[indeksPrzypisania] <> nil) then
	{Tworzymy korzeń drzewa Dt.}
	begin
		new(t);
		t^.v := tablicaDrzew[indeksPrzypisania]^.v;
		t^.v.ref := 1;
		t^.left := tablicaDrzew[indeksPrzypisania]^.left;
		t^.right := tablicaDrzew[indeksPrzypisania]^.right;
		wezlow := wezlow + 1;
		root := t;
	end
	else
	begin
		t := nil;
	end;
	atrapa^.left := t;
	if wartosc > 0 then
	{Jeśli musimy wstawić wartość przypisania dla drzewa Dt.}
	begin
		if t <> nil then
		{Wstawiamy do drzewa Dt-1.}
		begin
			if not czyIstniejeWezel(t,argument, wartosc) then
			{Jeśli nie istnieje węzeł w drzewie o danym argumencie i wartości to musimy go stworzyć.}
			begin
				t^.v.sum := t^.v.sum + wartosc;
				root := wstawDoDrzewa(argument,wartosc,t);
				atrapa^.left := root;
			end
			else
			begin
			{W przeciwnym przypadku przekierowujemy wskaznik na drzew Dt-1.}
				dispose(t);
				atrapa^.left := tablicaDrzew[indeksPrzypisania];
				zwiekszRef(atrapa^.left);
				wezlow := wezlow -1;
			end;
		end
		else
		{Tworzymy drzewo Dt od nowa}
		begin
			t := tworzNowyWezel(argument, wartosc);
			atrapa^.left := t;
		end;	
	end
	else
	{Jeśli musimy usunąć przypisanie w drzewie Dt}
	begin
		usuwanaWartosc := zwrocWartoscWezla(t, argument);
		if usuwanaWartosc > 0 then
		begin
			t := stworzUsuniete(argument, usuwanaWartosc,t);
			root := t;
			atrapa^.left := root;
		end
		else
		begin
			{Jeśli nie było węzła o podanym argumencie w drzewie usuwamy nowy korzen.}
			if t <> nil then
			begin
				dispose(t);
				wezlow := wezlow -1;
				t := nil;
			end;
			if indeksPrzypisania > 0 then
			begin
				atrapa^.left := tablicaDrzew[indeksPrzypisania];
				zwiekszRef(atrapa^.left);
			end
			else
				atrapa^.left := nil;
		end;	
	end;
	indeksPrzypisania := indeksPrzypisania +1;
	tablicaDrzew[indeksPrzypisania] := atrapa^.left;
	przypisanie := wezlow;
	dispose(atrapa);
	{Usuwamy atrapę.}
end;




function suma(nr_funkcji, lewy_argument, prawy_argument : LongInt) : LongInt;
{Funkcja zliczająca sumę od lewego argumentu do prawego w funkcji o podanym numerze.}

procedure zlicz(t : Tree; var suma : LongInt; n : LongInt);
{Zliczamy sumę od 1 do n}
begin
	if t <> nil then
	begin
		if t^.v.key <= n then
		begin
			suma := suma + t^.v.val;
			if t^.left <> nil then
				suma := suma + t^.left^.v.sum;
			zlicz(t^.right, suma,n);
		end
		else
		begin
			zlicz(t^.left, suma,n);
		end;
	end;
end;

var
	t : Tree;
	lewy, prawy : Tree;
	sumal, sumap, zwroc : LongInt;
begin
	{Musimy sprawdzić czy istnieje funkcja o podanym numerze.}
	if nr_funkcji > indeksPrzypisania then
	begin
		suma := -1;
	end
	else if nr_funkcji > 0 then
	begin
		t := tablicaDrzew[nr_funkcji];
		if t <> nil then
		begin
			lewy := t;
			prawy := t;
			sumap := 0;
			sumal := 0;
			zwroc := 0;
			zlicz(prawy, sumap, prawy_argument);
			zlicz(lewy,sumal,(lewy_argument -1 ));
			zwroc := sumap - sumal;
			suma := zwroc;
		end
		else
		begin
			suma := 0;
		end;
	end
	else if nr_funkcji = 0 then
		suma := 0
	else
		suma := -1;

end;

function czysc(nr_funkcji : LongInt) : LongInt;

procedure usun(var d : Tree);
{Usuwamy nowo tworzone węzły dla drzewa Dt i zmniejszamy licznik referencji dla podpiętych z Dt-1.}
begin
	if d <> nil then
	begin

		if d^.v.ref = 1 then
		begin
			usun(d^.left);
			usun(d^.right);
			dispose(d);
			d := nil;
			wezlow := wezlow - 1;
		end
		else if d^.v.ref > 1 then
			d^.v.ref := d^.v.ref - 1
		else
			writeln('niezamierzony blad');
	end;
end;

var
	t : Tree;
begin
	{Sprawdzamy czy usuwamy poprawną funkcję.}
	if nr_funkcji > indeksPrzypisania then
		czysc := -1
	else if nr_funkcji > 0 then
	begin
		t := tablicaDrzew[nr_funkcji];
		if t <> nil then
		begin
			usun(t);
			tablicaDrzew[nr_funkcji] := nil;
			czysc := wezlow;
		end
		else
			czysc := wezlow;
	end
	else if nr_funkcji = 0 then
		czysc := wezlow
	else
		czysc := -1;
end;

procedure zwolnijPamiecNaKoniec;
{Procedura zwalniająca pamięć na koniec działania programu.}
var
	i : LongInt;
begin
	for i := indeksPrzypisania downto 1 do
	begin
		czysc(i);
	end;
end;

end.
