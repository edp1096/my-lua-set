#include <stdio.h>

#include "lauxlib.h"
#include "lua.h"

#if defined(_WIN32) && (defined(_MSC_VER) || defined(__MINGW64__))
#define EXPORT __declspec(dllexport)
#else
#define EXPORT
#endif

extern int say_goodbye(lua_State *L);

int say_hello(lua_State *L) {
    const char *name = luaL_checkstring(L, 1);
    printf("Hello %s!!\n", name);
    return 1;
}

static const luaL_Reg say_lib[] = {
    {"hello", say_hello},
    {"goodbye", say_goodbye},
    {NULL, NULL}};

EXPORT int luaopen_say(lua_State *L) {
    luaL_newlib(L, say_lib);
    return 1;
}