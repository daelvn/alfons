-- Install Alfons on CC
print "==> Alfons installer"
print "->  Installing bsrocks..."
shell.run "pastebin run LYAxmSby get 6ced21eb437a776444aacef4d597c0f7/bsrocks.min.lua bsrocks"
print "->  Installing ansicolors with bsrocks"
shell.run "bsrocks install ansicolors"
print "->  Installing alfons with bsrocks"
shell.run "bsrocks install alfons"
print "->  Placing wrapper in /alfons.lua"
shell.run "pastebin get Ry0C9j47 /alfons.lua"

