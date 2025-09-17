#include <stdio.h>

#include "lua.h"
#include "lauxlib.h"

int say_goodbye(lua_State *L) {
    const char *name = luaL_checkstring(L, 1);
    printf("Goodbye %s!!\n", name);
    return 1;
}