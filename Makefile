SHELL := /bin/bash

BIN_NAME := game
SDL_DIR := vendor/SDL
SDL_BUILD_DIR := $(realpath $(SDL_DIR))/build

SDL_IMAGE_DIR := vendor/SDL_image
SDL_IMAGE_BUILD_DIR := $(realpath $(SDL_IMAGE_DIR))/build

EMCC_PRELOADS = --use-preload-plugins $(addprefix --preload-file ,$(shell find res -name '*.png'))

KANTAN = ~/Documents/programming/kantan/compiler/compiler
#KANTAN = kantan
KANTAN_FILES = src/dbg.kan \
			   src/config.kan \
			   src/graphics.kan \
			   src/input.kan \
			   src/main.kan \
			   src/math.kan \
			   src/npc.kan \
			   src/objects.kan \
			   src/physics.kan \
			   src/player.kan \
			   src/ptrvec.kan \
			   src/sdl.kan \
			   src/std.kan \
			   src/str.kan \
			   src/text.kan \
			   src/world.kan
OBJ = game.o

$(BIN_NAME) : $(KANTAN_FILES)
	if ! [ -d $(SDL_BUILD_DIR) ]; then \
		mkdir -p $(SDL_BUILD_DIR) ; \
		pushd $(SDL_BUILD_DIR) ; \
		../configure --prefix=$(SDL_BUILD_DIR) --exec-prefix=$(SDL_BUILD_DIR) && \
		make -j4 && make install; \
	fi ;
	if ! [ -d $(SDL_IMAGE_BUILD_DIR) ]; then \
		mkdir -p $(SDL_IMAGE_BUILD_DIR) ; \
		pushd $(SDL_IMAGE_BUILD_DIR) ; \
		../configure --prefix=$(SDL_IMAGE_BUILD_DIR) --exec-prefix=$(SDL_IMAGE_BUILD_DIR) && \
		make -j4 && make install; \
	fi ;
	$(KANTAN) $(KANTAN_FILES) -o $(OBJ) -g -O2 --arch wasm32 && \
	source ~/Downloads/emsdk/emsdk_env.sh && \
	emcc $(OBJ) -s WASM=1 -s USE_SDL=2 -s USE_SDL_IMAGE=2 -s SDL2_IMAGE_FORMATS='["png"]' $(EMCC_PRELOADS) -o index.js
