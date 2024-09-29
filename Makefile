LUA_DIR=/home/dael/.lenv/lua/5.4.6/lib/lua/5.4
SUBPROCESS_DIR=subprocess
LIBFLAG= -shared -fpic

spawn.so: alfons/spawn.c
	$(CC) -o alfons/spawn.so $(LIBFLAG) $(CFLAGS) alfons/spawn.c -I$(LUA_DIR) -I$(SUBPROCESS_DIR) -llua -lpthread -lm -g
