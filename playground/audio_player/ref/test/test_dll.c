/*
 * test_dll.c - DLL 테스트 프로그램
 * 
 * 컴파일: gcc -o test_dll.exe test_dll.c -L. -laudio
 * 실행: test_dll.exe
 */

#include <stdio.h>
#include <windows.h>

// DLL 함수 포인터 타입 정의
typedef int (*audio_init_func)();
typedef void (*audio_shutdown_func)();
typedef void* (*audio_load_file_func)(const char*);
typedef int (*audio_play_func)(void*);
typedef int (*audio_set_volume_func)(void*, float);
typedef int (*audio_is_playing_func)(void*);
typedef void (*audio_free_func)(void*);

int main() {
    printf("Loading audio.dll...\n");
    
    // DLL 로드
    HMODULE hDll = LoadLibrary("audio.dll");
    if (!hDll) {
        printf("Failed to load audio.dll\n");
        return 1;
    }
    
    // 함수 포인터 얻기
    audio_init_func audio_init = (audio_init_func)GetProcAddress(hDll, "audio_init");
    audio_shutdown_func audio_shutdown = (audio_shutdown_func)GetProcAddress(hDll, "audio_shutdown");
    audio_load_file_func audio_load_file = (audio_load_file_func)GetProcAddress(hDll, "audio_load_file");
    audio_play_func audio_play = (audio_play_func)GetProcAddress(hDll, "audio_play");
    audio_set_volume_func audio_set_volume = (audio_set_volume_func)GetProcAddress(hDll, "audio_set_volume");
    audio_is_playing_func audio_is_playing = (audio_is_playing_func)GetProcAddress(hDll, "audio_is_playing");
    audio_free_func audio_free = (audio_free_func)GetProcAddress(hDll, "audio_free");
    
    if (!audio_init || !audio_load_file) {
        printf("Failed to get function addresses\n");
        FreeLibrary(hDll);
        return 1;
    }
    
    printf("DLL functions loaded successfully!\n");
    
    // 오디오 시스템 초기화
    if (!audio_init()) {
        printf("Audio init failed\n");
        FreeLibrary(hDll);
        return 1;
    }
    
    printf("Audio system initialized\n");
    
    // 음악 파일 로드
    void* sound = audio_load_file("guitar.ogg");
    if (!sound) {
        printf("Failed to load guitar.ogg\n");
        audio_shutdown();
        FreeLibrary(hDll);
        return 1;
    }
    
    printf("File loaded successfully\n");
    
    // 재생
    audio_set_volume(sound, 0.8f);
    audio_play(sound);
    
    printf("Playing... Press Enter to stop.\n");
    getchar();
    
    // 정리
    audio_free(sound);
    audio_shutdown();
    FreeLibrary(hDll);
    
    printf("Test completed\n");
    return 0;
}