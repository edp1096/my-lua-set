/*
 * player.c - DLL용 모듈화된 오디오 재생기
 *
 * 컴파일: gcc -o player.exe player.c .\stb_vorbis.c -lwinmm -lole32
 * DLL 컴파일: gcc -shared -o audio.dll player.c .\stb_vorbis.c -lwinmm -lole32
 */

#define STB_VORBIS_HEADER_ONLY
#include "stb_vorbis.c"

#define MA_HAS_VORBIS
#define MA_ENABLE_VORBIS
#define MINIAUDIO_IMPLEMENTATION
#include <stdio.h>
#include <stdlib.h>

#include "miniaudio.h"

// 전역 오디오 엔진
static ma_engine* g_engine = NULL;
static int g_initialized = 0;

// DLL export용 함수들
#ifdef _WIN32
#define EXPORT __declspec(dllexport)
#else
#define EXPORT
#endif

// 오디오 시스템 초기화
EXPORT int audio_init() {
    if (g_initialized) {
        return 1;  // 이미 초기화됨
    }

    g_engine = malloc(sizeof(ma_engine));
    if (!g_engine) {
        return 0;
    }

    if (ma_engine_init(NULL, g_engine) != MA_SUCCESS) {
        free(g_engine);
        g_engine = NULL;
        return 0;
    }

    g_initialized = 1;
    return 1;
}

// 오디오 시스템 종료
EXPORT void audio_shutdown() {
    if (g_initialized && g_engine) {
        ma_engine_uninit(g_engine);
        free(g_engine);
        g_engine = NULL;
        g_initialized = 0;
    }
}

// 음악 파일 재생 (간단한 원샷 재생)
EXPORT int audio_play_file(const char* filename, float volume) {
    if (!g_initialized) {
        return 0;
    }

    if (volume < 0.0f) volume = 0.0f;
    if (volume > 1.0f) volume = 1.0f;

    ma_result result = ma_engine_play_sound(g_engine, filename, NULL);
    return (result == MA_SUCCESS) ? 1 : 0;
}

// 음악 파일 재생 (제어 가능한 버전)
EXPORT void* audio_load_file(const char* filename) {
    if (!g_initialized) {
        return NULL;
    }

    ma_sound* sound = malloc(sizeof(ma_sound));
    if (!sound) {
        return NULL;
    }

    if (ma_sound_init_from_file(g_engine, filename, 0, NULL, NULL, sound) != MA_SUCCESS) {
        free(sound);
        return NULL;
    }

    return sound;
}

// 사운드 재생
EXPORT int audio_play(void* sound_handle) {
    if (!sound_handle) return 0;

    ma_sound* sound = (ma_sound*)sound_handle;
    ma_result result = ma_sound_start(sound);
    return (result == MA_SUCCESS) ? 1 : 0;
}

// 사운드 정지
EXPORT int audio_stop(void* sound_handle) {
    if (!sound_handle) return 0;

    ma_sound* sound = (ma_sound*)sound_handle;
    ma_sound_stop(sound);
    return 1;
}

// 볼륨 설정
EXPORT int audio_set_volume(void* sound_handle, float volume) {
    if (!sound_handle) return 0;

    if (volume < 0.0f) volume = 0.0f;
    if (volume > 1.0f) volume = 1.0f;

    ma_sound* sound = (ma_sound*)sound_handle;
    ma_sound_set_volume(sound, volume);
    return 1;
}

// 재생 상태 확인
EXPORT int audio_is_playing(void* sound_handle) {
    if (!sound_handle) return 0;

    ma_sound* sound = (ma_sound*)sound_handle;
    return ma_sound_is_playing(sound) ? 1 : 0;
}

// 사운드 해제
EXPORT void audio_free(void* sound_handle) {
    if (!sound_handle) return;

    ma_sound* sound = (ma_sound*)sound_handle;
    ma_sound_uninit(sound);
    free(sound);
}

// 간단한 재생 함수 (EXE 테스트용)
int simple_play(const char* filename, float volume) {
    printf("Loading: %s\n", filename);

    if (!audio_init()) {
        printf("Audio init failed\n");
        return 0;
    }

    void* sound = audio_load_file(filename);
    if (!sound) {
        printf("File load failed\n");
        audio_shutdown();
        return 0;
    }

    audio_set_volume(sound, volume);
    audio_play(sound);

    printf("Playing... Press Enter to stop.\n");
    getchar();

    audio_free(sound);
    audio_shutdown();
    return 1;
}

// 간단한 테스트용 main 함수
int main(int argc, char* argv[]) {
    const char* filename = (argc > 1) ? argv[1] : "guitar.ogg";
    const float volume = 0.8f;

    printf("Simple Audio Player Test\n");

    if (!simple_play(filename, volume)) {
        printf("Playback failed\n");
        return 1;
    }

    printf("Test completed\n");
    return 0;
}