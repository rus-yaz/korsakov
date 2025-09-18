FASM_FLAGS = -m 131072
DATADIR = /usr/share
BINDIR = /usr/bin
PREFIX = $(DATADIR)/korsakov

DOCS_ROOT = docs

.PHONY: all compile debug test install clean

all: build_linux

# WIP
#
# build:

build_linux: FASM_FLAGS += -d LINUX=1
build_linux: clean compile
	ld korsakov.o -o korsakov
	ld korsakov.o -o корсаков

build_windows: FASM_FLAGS += -d WINDOWS=1
build_windows: clean compile
	cp korsakov.exe корсаков.exe

compile:
	fasm $(FASM_FLAGS) korsakov.asm

debug_linux: FASM_FLAGS += -d DEBUG=
debug_linux: clean build_linux

debug_windows: FASM_FLAGS += -d DEBUG=
debug_windows: clean build_windows

install: korsakov корсаков
	sudo mkdir -p $(PREFIX)
	sudo cp -r core modules lib korsakov корсаков config.inc $(PREFIX)
	sudo ln -sf $(PREFIX)/korsakov $(BINDIR)/korsakov
	sudo ln -sf $(PREFIX)/korsakov $(BINDIR)/корсаков

uninstall: clean
	sudo rm -rf $(PREFIX)

test: clean
	fasm $(FASM_FLAGS) tests.asm tests.o
	ld tests.o -o tests
	./tests

clean:
	rm -f *.o \
		korsakov корсаков \
		korsakov.exe корсаков.exe \
		tests

macros:
	rm core/generated_macros.asm
	sh ./hooks/generate_macros.sh

docs:
	rm -rf $(DOCS_ROOT)
	mkdir -p $(DOCS_ROOT)
	sh ./hooks/generate_docs_internal.sh $(DOCS_ROOT)
