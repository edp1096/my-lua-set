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
    AUDIO_LIBS = -lwinmm -lole32
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
    
    AUDIO_LIBS = -lasound -lpthread -ldl -lm
endif

AUDIO_TARGET = audio$(EXT)
LOADER_TARGET = lua_loader$(EXT_BIN)

build: $(AUDIO_TARGET) $(LOADER_TARGET)

$(AUDIO_TARGET): audio/audio.c audio/stb_vorbis.c audio/util.c
	$(CC) $(CFLAGS) $(LUA_INCLUDE) -o $(AUDIO_TARGET) audio/audio.c audio/stb_vorbis.c audio/util.c $(LUA_LIB) $(AUDIO_LIBS)

$(LOADER_TARGET): loader/main.c
	$(CC) $(LUA_INCLUDE) -o $(LOADER_TARGET) loader/main.c $(LUA_LIB) $(LOADER_LIBS)


dist: build
	mkdir dist
ifeq ($(OS),Windows_NT)
	copy $(AUDIO_TARGET) dist
	copy $(LOADER_TARGET) dist
	copy player_full.lua dist
else
	cp $(AUDIO_TARGET) dist
	cp $(LOADER_TARGET) dist
	cp player_full.lua dist
endif

clean:
ifeq ($(OS),Windows_NT)
	-$(RM) *.dll 2>nul
	-$(RM) lua_loader.exe 2>nul
# 	-$(RM) dist 2>nul
# 	rmdir dist 2>nul
else
	-$(RM) *.so
	-$(RM) lua_loader
# 	-$(RM) dist
endif