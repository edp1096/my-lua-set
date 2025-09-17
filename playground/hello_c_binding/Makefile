.PHONY: build clean test help

CC = gcc
LOADER_LIBS = -lm

ifeq ($(OS),Windows_NT)
    EXT = .dll
    EXT_BIN = .exe
    RM = del /Q
    CFLAGS = -shared -O2 -Wall
    LUA_INCLUDE = -I../../lua/include
    LUA_LIB = -L../../lua/lib -llua
else
    EXT = .so
    EXT_BIN =
    RM = rm -f
    CFLAGS = -fPIC -shared -O2 -Wall

    LUA_INCLUDE := $(shell pkg-config --cflags lua5.4 2>/dev/null)
    LUA_LIB := $(shell pkg-config --libs lua5.4 2>/dev/null)

    ifeq ($(LUA_INCLUDE),)
        LUA_INCLUDE := $(shell pkg-config --cflags lua 2>/dev/null)
        LUA_LIB := $(shell pkg-config --libs lua 2>/dev/null)
    endif

    ifeq ($(LUA_INCLUDE),)
        ifneq ($(wildcard /usr/include/lua5.4/lua.h),)
            LUA_INCLUDE := -I/usr/include/lua5.4
            LUA_LIB := -llua5.4
        else ifneq ($(wildcard /usr/include/lua/lua.h),)
            LUA_INCLUDE := -I/usr/include/lua
            LUA_LIB := -llua
        else
            LUA_INCLUDE := -I../../lua/include
            LUA_LIB := -L../../lua/lib -llua
        endif
    endif
endif

SAY_TARGET = say$(EXT)

$(SAY_TARGET): say/hello.c say/goodbye.c
	$(CC) $(CFLAGS) $(LUA_INCLUDE) -o $(SAY_TARGET) say/hello.c say/goodbye.c $(LUA_LIB)

build: $(SAY_TARGET)

dist: build
	mkdir dist
ifeq ($(OS),Windows_NT)
	copy $(SAY_TARGET) dist
	copy player_full.lua dist
else
	cp $(SAY_TARGET) dist
	cp player_full.lua dist
endif

clean:
ifeq ($(OS),Windows_NT)
	-$(RM) *.dll 2>nul
else
	-$(RM) *.so
endif