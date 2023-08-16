
LIB_FILES=crypt.swift stderr.swift time.swift base32.swift
SOURCE_FILES=main.swift

all: totp

docs: trash.1

run: libutils.dylib
	swift main.swift -I . -lutils

libutils.dylib: $(LIB_FILES)
	swiftc -emit-library -olibutils.dylib $(LIB_FILES)

totp: $(SOURCE_FILES)
	@echo
	@echo ---- Compiling:
	@echo ======================================
	swiftc -Osize -remove-runtime-asserts -o $@ $(LIB_FILES) $(SOURCE_FILES)
	strip $@

clean:
	@echo
	@echo ---- Cleaning up:
	@echo ======================================
	-rm -Rf totp
