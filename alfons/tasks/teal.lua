return {
  tasks = {
    always = function(self)
      load("fetch")
      if not (store.install == false) then
        return tasks.install()
      end
    end,
    install = function(self)
      if exists("teal_preinstall") then
        prints("%{cyan}Teal:%{white} Running pre-install hook.")
        tasks.teal_preinstall()
      end
      prints("%{cyan}Teal:%{white} Installing dependencies.")
      local _list_0 = store.dependencies
      for _index_0 = 1, #_list_0 do
        local dep = _list_0[_index_0]
        prints("%{green}+ " .. tostring(dep))
        sh("luarocks install " .. tostring(dep))
      end
      if exists("teal_postinstall") then
        prints("%{cyan}Teal:%{white} Running post-install hook.")
        return tasks.teal_postinstall()
      end
    end,
    build = function(self)
      if exists("teal_prebuild") then
        prints("%{cyan}Teal:%{white} Running pre-build hook.")
        tasks.teal_prebuild()
      end
      prints("%{cyan}Teal:%{white} Building project.")
      sh("tl build")
      if exists("teal_postbuild") then
        prints("%{cyan}Teal:%{white} Running post-build hook.")
        return tasks.teal_postbuild()
      end
    end,
    typings = function(self)
      print("hey")
      local json = require("dkjson")
      local fetchdefs
      fetchdefs = function(mod)
        print(tasks.fetch({
          url = "https://google.com"
        }))
        return print(tasks.fetch({
          url = "https://api.github.com/repos/teal-language/teal-types/contents/types/" .. tostring(mod)
        }))
      end
      local mod = self.m or self.module
      if mod then
        prints("%{cyan}Teal:%{white} Fetching type definitions for " .. tostring(mod) .. ".")
        return fetchdefs(mod)
      else
        return prints("%{cyan}Teal:%{white} Fetching type definitions.")
      end
    end
  }
}
