# Pokemon wannabe

A small tech demo, which shows how you could use kantan for game development.

## Getting started
If you just want to check out the "game", you can try it on https://funkschy.github.io/pokemon-wannabe/

But if you want to build it, you have to do it in one of the following ways.

Since Kantan does not currently support conditional compilation, we have to change the source
code a bit.

Go into src/main.kan and make sure that `emscripten_set_main_loop_arg(&mainloop, &game, -1, 1)` is commented out
#### For the native version
```
git clone --recursive https://github.com/funkschy/pokemon-wannabe
make
./game

```

Go into src/main.kan and make sure that `emscripten_set_main_loop_arg(&mainloop, &game, -1, 1)` is not commented out.
and comment out the `while running {...}` loop
#### For the browser version
```
git clone --recursive https://github.com/funkschy/pokemon-wannabe
make run
# open localhost:8080 in you browser
```
