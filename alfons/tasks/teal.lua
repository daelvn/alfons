return {
  tasks = {
    always = function(self)
      load("fetch")
      if not (store.teal_auto == true) then
        tasks.install()
        return tasks.typings({
          modules = store.typings
        })
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
      local json = require("dkjson")
      local fetchdefs
      fetchdefs = function(mod)
        prints("%{cyan}Teal:%{white} Fetching type definitions for " .. tostring(mod) .. ".")
        local unjson = tasks.fetch({
          url = "https://api.github.com/repos/teal-language/teal-types/contents/types/" .. tostring(mod)
        })
        local files = json.decode(unjson)
        for _index_0 = 1, #files do
          local _continue_0 = false
          repeat
            local file = files[_index_0]
            if not (file.type == "file") then
              _continue_0 = true
              break
            end
            local name = file.name
            local def = tasks.fetch({
              url = "https://raw.githubusercontent.com/teal-language/teal-types/master/types/" .. tostring(mod) .. "/" .. tostring(name)
            })
            writefile(name, def)
            _continue_0 = true
          until true
          if not _continue_0 then
            break
          end
        end
      end
      local mod = self.m or self.module
      local mods = self.modules
      if mod then
        return fetchdefs(mod)
      elseif mods then
        local _list_0 = mods
        for _index_0 = 1, #_list_0 do
          local md = _list_0[_index_0]
          fetchdefs(md)
        end
      end
    end
  }
}
