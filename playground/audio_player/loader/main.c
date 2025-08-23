/*
 * simple_runner.c - Simple Lua Script Runner
 *
 * Uses static linking with Lua libraries
 * Much simpler than dynamic loading
 *
 * Compile: gcc -o lua_loader.exe loader/main.c -I../../lua/include -L../../lua/lib -llua -lm
 * Usage: lua_loader.exe script.lua [args...]
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "lauxlib.h"
#include "lua.h"
#include "lualib.h"

// Set up command line arguments in Lua global 'arg' table
static void setup_lua_args(lua_State* L, int argc, char* argv[]) {
    lua_createtable(L, argc, 0);  // Create 'arg' table

    for (int i = 0; i < argc; i++) {
        lua_pushinteger(L, i);       // Index
        lua_pushstring(L, argv[i]);  // Argument value
        lua_settable(L, -3);         // arg[i] = argv[i]
    }

    lua_setglobal(L, "arg");  // Set global variable 'arg'
}

// Execute Lua script file
static int execute_lua_file(lua_State* L, const char* filename) {
    printf("Executing Lua script: %s\n", filename);

    int result = luaL_dofile(L, filename);
    if (result != LUA_OK) {
        // Error occurred
        const char* error_msg = lua_tostring(L, -1);
        printf("Lua Error: %s\n", error_msg ? error_msg : "Unknown error");
        lua_pop(L, 1);  // Remove error message from stack
        return result;
    }

    printf("Script executed successfully\n");
    return LUA_OK;
}

// Check if file exists
static int file_exists(const char* filename) {
    FILE* file = fopen(filename, "r");
    if (file) {
        fclose(file);
        return 1;
    }
    return 0;
}

// Main entry point
int main(int argc, char* argv[]) {
    printf("Simple Lua Runner v1.0\n");
    printf("======================\n");

    // Check arguments
    if (argc < 2) {
        printf("Usage: %s script.lua [args...]\n", argv[0]);
        printf("Examples:\n");
        printf("  %s test.lua\n", argv[0]);
        printf("  %s game.lua --fullscreen\n", argv[0]);
        return 1;
    }

    const char* script_file = argv[1];

    // Check if script file exists
    if (!file_exists(script_file)) {
        printf("Error: Script file '%s' not found\n", script_file);
        return 1;
    }

    // Create Lua state
    lua_State* L = luaL_newstate();
    if (!L) {
        printf("Error: Failed to create Lua state\n");
        return 1;
    }

    printf("Lua state created successfully\n");

    // Open standard libraries
    luaL_openlibs(L);
    printf("Lua standard libraries loaded\n");
    printf("Lua version: %s\n", LUA_VERSION);

    // Set up command line arguments
    setup_lua_args(L, argc, argv);
    printf("Command line arguments set up\n");

    // Execute the script
    int exit_code = execute_lua_file(L, script_file);

    // Cleanup
    printf("Cleaning up...\n");
    lua_close(L);

    if (exit_code == LUA_OK) {
        printf("Program completed successfully\n");
    } else {
        printf("Program completed with errors (exit code: %d)\n", exit_code);
    }

    return exit_code == LUA_OK ? 0 : 1;
}