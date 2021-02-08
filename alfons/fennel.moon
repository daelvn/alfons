--alfons.fennel
-- Fennel compiler with syntax sugar macros

fennel = require "fennel"
{ :eval } = fennel
compiler = require "fennel.compiler"
specials = require "fennel.specials"
{ "make-compiler-env": makeCompilerEnv } = specials
{ "compile-string": compileString } = compiler
utils = require "fennel.utils"

macros = '(fn deftasks [body ...]
  "Define a new taskfile"
  (assert body "expected body")
  `(let [tasks# {}]
     (do ,body ,...)
   {:tasks tasks#}))

(fn task [name params ...]
  "Define a new task"
  (assert name "expected name")
  (assert (sequence? params) "expected parameters")
  `(tset tasks# ,name (fn ,params ,...)))

{:deftasks deftasks :task task}'

-- In order to provide macros that extend the regular way of
-- creating a taskfile into said file, we need to stick
-- these inside the compiler environment.
local env
with env = makeCompilerEnv nil, compiler.scopes.compiler, {}
  env.utils = utils
  env.fennel = fennel

builtins = eval macros, {
  :env
  scope: compiler.scopes.compiler
  allowedGlobals: false
  useMetadata: true
  filename: "alfons/fennel.moon"
  moduleName: "alfons.fennel"
}

for k, v in pairs builtins
  compiler.scopes.global.macros[k] = v

compileFennel = (str) -> compileString str

{ :compileFennel }