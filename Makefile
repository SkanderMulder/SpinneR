# Detect OS
ifeq ($(OS), Windows_NT)
    OS_TYPE := Windows
else
    UNAME_S := $(shell uname -s)
    ifeq ($(UNAME_S), Linux)
        OS_TYPE := Linux
    endif
    ifeq ($(UNAME_S), Darwin)
        OS_TYPE := macOS
    endif
endif

# Compilers and flags
ifeq ($(OS_TYPE), Windows)
    # Use x886_64-w64-mingw32-g++ for cross-compilation on Linux, or g++ on Windows with MinGW
    CXX ?= x86_64-w64-mingw32-g++
    LDFLAGS := -static -lws2_32 # -lws2_32 for Winsock if needed, -static to bundle runtime
    EXT := .exe
else
    CXX ?= g++
    LDFLAGS := -pthread -lrt
    EXT :=
endif

all: spinner sem_post_helper

spinner: csource/spinner.cpp
	$(CXX) -o exec/spinner$(EXT) csource/spinner.cpp $(LDFLAGS)

sem_post_helper: csource/sem_post_helper.cpp
	$(CXX) -o exec/sem_post_helper$(EXT) csource/sem_post_helper.cpp $(LDFLAGS)

clean:
	rm -f exec/spinner$(EXT) exec/sem_post_helper$(EXT)

.PHONY: all clean spinner sem_post_helper