tasks:
  fetchs:  get "fetchs"
  always:  get "ms-compile"
  make:    (version) => sh "rockbuild -m --delete #{version}"
  release: (version) => sh "rockbuild -m -t #{version} u"
  lovebrew: =>
    print select 2, tasks.fetchs "https://github.com/TurtleP/LovePotion/releases/download/2.0.0-pre3/LovePotion-Switch-9751a2c.zip"