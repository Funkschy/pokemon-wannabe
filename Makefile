SHELL := /bin/bash

BIN_NAME := game
SDL_DIR := vendor/SDL
SDL_BUILD_DIR := $(realpath $(SDL_DIR))/build

SDL_IMAGE_DIR := vendor/SDL_image
SDL_IMAGE_BUILD_DIR := $(realpath $(SDL_IMAGE_DIR))/build

EMCC_PRELOADS = --use-preload-plugins $(addprefix --preload-file ,$(shell find res -name '*.png'))

KANTAN_C ?= /usr/local/bin/kantan
KANTAN_FILES = $(shell find src -name '*.kan')
OBJ = game.o

$(BIN_NAME) : $(KANTAN_FILES) $(SDL_BUILD_DIR) $(SDL_IMAGE_BUILD_DIR)
	$(KANTAN_C) $(KANTAN_FILES) -o $(OBJ) -g && \
	LIBS=$$($(SDL_BUILD_DIR)/sdl2-config --static-libs) && \
	gcc $(OBJ) $$LIBS -lm -lSDL -L$(SDL_IMAGE_BUILD_DIR)/lib -lSDL2_image -o $(BIN_NAME)


$(SDL_BUILD_DIR) : $(SDL_DIR)
	mkdir -p $(SDL_BUILD_DIR)
	cd $(SDL_BUILD_DIR) && \
	../configure --prefix=$(SDL_BUILD_DIR) --exec-prefix=$(SDL_BUILD_DIR) && \
	make -j4 && make install; \


$(SDL_IMAGE_BUILD_DIR) : $(SDL_IMAGE_DIR)
	mkdir -p $(SDL_IMAGE_BUILD_DIR) ; \
	pushd $(SDL_IMAGE_BUILD_DIR) ; \
	cd .. ; \
	autoreconf --force --install ; \
	cd - ; \
	../configure --prefix=$(SDL_IMAGE_BUILD_DIR) --exec-prefix=$(SDL_IMAGE_BUILD_DIR) && \
	make -j4 && make install; \


dist/index.js : $(KANTAN_FILES)
	$(KANTAN_C) $(KANTAN_FILES) -o $(OBJ) -g -O2 --arch wasm32 && \
	source ~/Downloads/emsdk/emsdk_env.sh && \
	emcc $(OBJ) -s WASM=1 -s USE_SDL=2 -s USE_SDL_IMAGE=2 -s SDL2_IMAGE_FORMATS='["png"]' $(EMCC_PRELOADS) -o dist/index.js && \
	rm $(OBJ)


.PHONY: deploy
deploy : dist/index.js
	git add dist
	git commit -m "update dist"
	git subtree push --prefix dist origin gh-pages


.PHONY: run
run : dist/index.js
	cd dist && python3 -m http.server 8080
