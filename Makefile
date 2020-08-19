SHELL := /bin/bash

BIN_NAME := game
SDL_DIR := vendor/SDL
SDL_BUILD_DIR := $(realpath $(SDL_DIR))/build

SDL_IMAGE_DIR := vendor/SDL_image
SDL_IMAGE_BUILD_DIR := $(realpath $(SDL_IMAGE_DIR))/build
SDL_IMAGE_LIB_DIR := $(SDL_IMAGE_BUILD_DIR)/lib

KANTAN = kantan
KANTAN_FILES = src/config.kan \
			   src/graphics.kan \
			   src/main.kan \
			   src/player.kan \
			   src/input.kan \
			   src/sdl.kan \
			   src/math.kan
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
	$(KANTAN) $(KANTAN_FILES) -o $(OBJ) -g ; \
	LIBS=$$($(SDL_BUILD_DIR)/sdl2-config --static-libs); \
	gcc $(OBJ) $$LIBS -lm -lSDL -L$(SDL_IMAGE_LIB_DIR) -lSDL2_image -o $(BIN_NAME) ; \
	rm $(OBJ)
