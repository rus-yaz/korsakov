FASM_FLAGS = -m 131072
DATADIR = /usr/share
BINDIR = /usr/bin
PREFIX = $(DATADIR)/korsakov

.PHONY: all build debug test install clean

all: build

build: clean
	fasm $(FASM_FLAGS) korsakov.asm korsakov.o
	ld korsakov.o -o korsakov
	ld korsakov.o -o корсаков

debug: FASM_FLAGS += -d DEBUG=
debug: clean build

install: korsakov корсаков
	sudo mkdir -p $(PREFIX)
	sudo cp -r core modules lib korsakov $(PREFIX)
	sudo ln -sf $(PREFIX)/korsakov $(BINDIR)/korsakov
	sudo ln -sf $(PREFIX)/korsakov $(BINDIR)/корсаков

uninstall: clean
	sudo rm -rf $(PREFIX)

test: clean
	fasm $(FASM_FLAGS) tests.asm tests.o
	ld tests.o -o tests
	./tests

clean:
	rm -f *.o $(TARGETS) $(TESTS)

macros:
	rm core/generated_macros.asm
	sh ./hooks/generate_macros.sh
