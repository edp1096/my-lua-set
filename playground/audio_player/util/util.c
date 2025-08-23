/*
 * util.c - 시스템 유틸리티 DLL for Lua
 * 
 * 컴파일: gcc -shared -o util.dll util.c -I"lua/include" -L"lua/lib" -llua -lwinmm
 * 
 * 기능:
 * - sleep(seconds)
 * - msleep(milliseconds) 
 * - kbhit() - 키 입력 감지
 * - getch() - 키 입력 받기
 * - cls() - 화면 지우기
 * - beep() - 비프음
 */

#include "lua.h"
#include "lauxlib.h"
#include <stdio.h>
#include <stdlib.h>

#ifdef _WIN32
#include <windows.h>
#include <conio.h>
#else
#include <unistd.h>
#include <termios.h>
#include <fcntl.h>
#include <sys/select.h>
#include <time.h>      // clock_gettime용
#include <sched.h>     // sched_yield용
#endif

// 초 단위 sleep
static int l_sleep(lua_State* L) {
    double seconds = luaL_checknumber(L, 1);
    
#ifdef _WIN32
    Sleep((DWORD)(seconds * 1000));
#else
    usleep((useconds_t)(seconds * 1000000));
#endif
    
    return 0;
}

// 밀리초 단위 sleep
static int l_msleep(lua_State* L) {
    int milliseconds = luaL_checkinteger(L, 1);
    
#ifdef _WIN32
    Sleep((DWORD)milliseconds);
#else
    usleep((useconds_t)(milliseconds * 1000));
#endif
    
    return 0;
}

// 키 입력 감지 (non-blocking)
static int l_kbhit(lua_State* L) {
#ifdef _WIN32
    lua_pushboolean(L, _kbhit());
#else
    struct termios oldt, newt;
    int ch;
    int oldf;
    
    tcgetattr(STDIN_FILENO, &oldt);
    newt = oldt;
    newt.c_lflag &= ~(ICANON | ECHO);
    tcsetattr(STDIN_FILENO, TCSANOW, &newt);
    oldf = fcntl(STDIN_FILENO, F_GETFL, 0);
    fcntl(STDIN_FILENO, F_SETFL, oldf | O_NONBLOCK);
    
    ch = getchar();
    
    tcsetattr(STDIN_FILENO, TCSANOW, &oldt);
    fcntl(STDIN_FILENO, F_SETFL, oldf);
    
    if(ch != EOF) {
        ungetc(ch, stdin);
        lua_pushboolean(L, 1);
    } else {
        lua_pushboolean(L, 0);
    }
#endif
    
    return 1;
}

// 키 입력 받기 (extended key 지원)
static int l_getch(lua_State* L) {
#ifdef _WIN32
    int ch = _getch();
    
    // Extended key 체크 (화살표, Page Up/Down, Function keys 등)
    if (ch == 0 || ch == 224) {
        int extended = _getch();  // 실제 키코드 받기
        
        // Extended key는 1000번대로 변환하여 구분
        lua_pushinteger(L, 1000 + extended);
    } else {
        lua_pushinteger(L, ch);
    }
#else
    struct termios oldt, newt;
    int ch;
    
    tcgetattr(STDIN_FILENO, &oldt);
    newt = oldt;
    newt.c_lflag &= ~(ICANON | ECHO);
    tcsetattr(STDIN_FILENO, TCSANOW, &newt);
    
    ch = getchar();
    
    tcsetattr(STDIN_FILENO, TCSANOW, &oldt);
    
    if (ch == 27) {  // ESC 시퀀스 확인
        fd_set fds;
        struct timeval tv;
        
        FD_ZERO(&fds);
        FD_SET(STDIN_FILENO, &fds);
        tv.tv_sec = 0;
        tv.tv_usec = 100000;  // 100ms timeout
        
        if (select(STDIN_FILENO + 1, &fds, NULL, NULL, &tv) > 0) {
            int ch2 = getchar();
            if (ch2 == '[') {
                int ch3 = getchar();
                // 화살표 키 등을 1000번대로 변환
                switch (ch3) {
                    case 'A': lua_pushinteger(L, 1072); break;  // Up
                    case 'B': lua_pushinteger(L, 1080); break;  // Down  
                    case 'C': lua_pushinteger(L, 1077); break;  // Right
                    case 'D': lua_pushinteger(L, 1075); break;  // Left
                    default: lua_pushinteger(L, ch); break;
                }
            } else {
                lua_pushinteger(L, ch);
            }
        } else {
            lua_pushinteger(L, ch);
        }
    } else {
        lua_pushinteger(L, ch);
    }
#endif
    return 1;
}

// 화면 지우기
static int l_cls(lua_State* L) {
#ifdef _WIN32
    int ret = system("cls");
    (void)ret;  // 반환값 사용하지 않음을 명시
#else
    int ret = system("clear");
    (void)ret;  // 반환값 사용하지 않음을 명시
#endif
    return 0;
}

// 비프음
static int l_beep(lua_State* L) {
    int frequency = luaL_optinteger(L, 1, 800);    // 기본 800Hz
    int duration = luaL_optinteger(L, 2, 200);     // 기본 200ms
    
#ifdef _WIN32
    Beep(frequency, duration);
#else
    // Linux에서는 단순히 시스템 벨 사용 (frequency, duration 무시)
    (void)frequency;  // 경고 방지
    (void)duration;   // 경고 방지
    printf("\a");     // 시스템 벨
    fflush(stdout);
#endif
    
    return 0;
}

// 현재 시간 (밀리초)
static int l_tick(lua_State* L) {
#ifdef _WIN32
    lua_pushinteger(L, GetTickCount());
#else
    struct timespec ts;
    if (clock_gettime(CLOCK_MONOTONIC, &ts) == 0) {
        long long ms = (long long)ts.tv_sec * 1000LL + ts.tv_nsec / 1000000LL;
        lua_pushinteger(L, ms);
    } else {
        lua_pushinteger(L, 0);
    }
#endif
    return 1;
}

// CPU 사용량 최소화 대기
static int l_yield(lua_State* L) {
#ifdef _WIN32
    Sleep(0);  // 다른 스레드에게 시간 양보
#else
    sched_yield();
#endif
    return 0;
}

// 키 코드 상수 테이블
static void create_key_constants(lua_State* L) {
    lua_newtable(L);
    
    // 일반적인 키 코드들
    lua_pushinteger(L, 13); lua_setfield(L, -2, "ENTER");
    lua_pushinteger(L, 27); lua_setfield(L, -2, "ESC");
    lua_pushinteger(L, 32); lua_setfield(L, -2, "SPACE");
    lua_pushinteger(L, 8);  lua_setfield(L, -2, "BACKSPACE");
    lua_pushinteger(L, 9);  lua_setfield(L, -2, "TAB");
    lua_pushinteger(L, 45);  lua_setfield(L, -2, "MINUS");
    lua_pushinteger(L, 61);  lua_setfield(L, -2, "EQUAL");
    
    lua_setfield(L, -2, "KEY");
}

// 함수 테이블
static const luaL_Reg utillib[] = {
    {"sleep", l_sleep},
    {"msleep", l_msleep},
    {"kbhit", l_kbhit},
    {"getch", l_getch},
    {"cls", l_cls},
    {"beep", l_beep},
    {"tick", l_tick},
    {"yield", l_yield},
    {NULL, NULL}
};

// 모듈 초기화 함수
#ifdef _WIN32
__declspec(dllexport)
#endif
int luaopen_util(lua_State* L) {
    // util 모듈 테이블 생성
    luaL_newlib(L, utillib);
    
    // 키 상수 추가
    create_key_constants(L);
    
    // 버전 정보
    lua_pushstring(L, "1.0");
    lua_setfield(L, -2, "version");
    
    return 1;
}