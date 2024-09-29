#include <subprocess.h>
#include <stdio.h>
#include <lua.h>
#include <lauxlib.h>

int process_spawn(lua_State *L) {
  // lua_String executable = luaL_checkstring(L, 1);
  const char *command_line[] = {"/usr/bin/echo", "\"Hello, world!\"", NULL};
  struct subprocess_s subprocess;
  int create_result = subprocess_create(command_line, subprocess_option_inherit_environment, &subprocess);
  if (0 != create_result) {
    luaL_error(L, "create error: %d", create_result);
  }
  // int subprocess_return;
  // int wait_result = subprocess_join(&subprocess, &subprocess_return);
  // if (0 != wait_result) {
  //   printf("wait error");
  // }
  // int destroy_result = subprocess_destroy(&subprocess);
  // if (0 != destroy_result) {
  //   printf("destroy error");
  // }
  return 0;
}

static const struct luaL_Reg functions [] = {
  {"process", process_spawn},
  {NULL, NULL},
};

int luaopen_alfons_spawn(lua_State *L) {
  #if LUA_VERSION_NUM >= 502
    lua_newtable(L);
    luaL_setfuncs(L, functions, 0);
  #else
    luaL_register(L, "spawn", functions);
  #endif
  return 1;
}
