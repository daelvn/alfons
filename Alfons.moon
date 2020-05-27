tasks:
  always:  get "ms-compile"
  make:    (version) => sh "rockbuild -m --delete #{version}"
  release: (version) => sh "rockbuild -m -t #{version} u"