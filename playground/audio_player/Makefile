.PHONY: all clean test help

ifeq ($(OS),Windows_NT)
    CC = gcc
    EXT = .dll
    RM = del /Q
    CFLAGS = -shared -O2 -Wall
    LUA_INCLUDE = -I../../lua/include
    LUA_LIB = -L../../lua/lib -llua
    AUDIO_LIBS = -lwinmm -lole32
    UTIL_LIBS = -lwinmm
else
    CC = gcc
    EXT = .so
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
    UTIL_LIBS = 
endif

AUDIO_TARGET = audio$(EXT)
UTIL_TARGET = util$(EXT)

all: $(AUDIO_TARGET) $(UTIL_TARGET)

$(AUDIO_TARGET): audio/audio.c audio/stb_vorbis.c
	$(CC) $(CFLAGS) $(LUA_INCLUDE) -o $(AUDIO_TARGET) audio/audio.c audio/stb_vorbis.c $(LUA_LIB) $(AUDIO_LIBS)

$(UTIL_TARGET): util/util.c
	$(CC) $(CFLAGS) $(LUA_INCLUDE) -o $(UTIL_TARGET) util/util.c $(LUA_LIB) $(UTIL_LIBS)

clean:
ifeq ($(OS),Windows_NT)
	-$(RM) *.dll 2>nul
else
	-$(RM) *.so
endif
