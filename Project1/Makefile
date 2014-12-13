MAIN = zad1 drzewo
FPCOPT =-g -gl -gv -Sa -Cior -FEDebug

all: $(MAIN)

$(MAIN): %: %.pas
	mkdir -p Debug
	fpc $(FPCOPT) $<

clean:
	rm -f Debug/$(MAIN) Debug/*.o Debug/*.ppu
	rmdir Debug
