build:
	gcc -shared -I../../lua/include -L../../lua/lib -o audio.dll audio/audio.c audio/stb_vorbis.c -llua -lwinmm -lole32
	gcc -shared -I../../lua/include -L../../lua/lib -o util.dll util/util.c -llua -lwinmm
