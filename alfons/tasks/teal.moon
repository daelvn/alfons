tasks:
  always: =>
    unless store.install == false
      tasks.install!
  install: =>
    --- pre-install hook ---
    -- as a global task
    if gexists "teal_preinstall"
      prints "%{cyan}Teal:%{white} Running pre-install hook."
      gtasks.teal_preinstall!
    -- as a store hook
    elseif store.hooks.teal_preinstall
      prints "%{cyan}Teal:%{white} Running pre-install hook."
      store.hooks.teal_preinstall!
    prints "%{cyan}Teal:%{white} Installing dependencies."
    for dep in *store.dependencies
      prints "%{green}+ #{dep}"
      sh "luarocks install #{dep}"