SHELL := /bin/bash

BIN_NAME := game
SDL_DIR := vendor/SDL
SDL_BUILD_DIR := $(realpath $(SDL_DIR))/build

SDL_IMAGE_DIR := vendor/SDL_image
SDL_IMAGE_BUILD_DIR := $(realpath $(SDL_IMAGE_DIR))/build
SDL_IMAGE_LIB_DIR := $(SDL_IMAGE_BUILD_DIR)/lib

EMCC_PRELOADS = --use-preload-plugins $(addprefix --preload-file ,$(shell find res -name '*.png'))

KANTAN = ~/Documents/programming/kantan/compiler/compiler
#KANTAN = kantan
KANTAN_FILES = $(shell find src -name '*.kan')
OBJ = game.o

index.js : $(KANTAN_FILES)
	$(KANTAN) $(KANTAN_FILES) -o $(OBJ) -g -O2 --arch wasm32 && \
	source ~/Downloads/emsdk/emsdk_env.sh && \
	emcc $(OBJ) -s WASM=1 -s USE_SDL=2 -s USE_SDL_IMAGE=2 -s SDL2_IMAGE_FORMATS='["png"]' $(EMCC_PRELOADS) -o index.js

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
		cd .. ; \
		autoreconf --force --install ; \
		cd - ; \
		../configure --prefix=$(SDL_IMAGE_BUILD_DIR) --exec-prefix=$(SDL_IMAGE_BUILD_DIR) && \
		make -j4 && make install; \
	fi ;
	$(KANTAN) $(KANTAN_FILES) -o $(OBJ) -g && \
	LIBS=$$($(SDL_BUILD_DIR)/sdl2-config --static-libs) && \
	gcc $(OBJ) $$LIBS -lm -lSDL -L$(SDL_IMAGE_LIB_DIR) -lSDL2_image -o $(BIN_NAME)


.PHONY: run
run : index.js
	python3 -m http.server 8080
