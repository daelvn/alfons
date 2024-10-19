# alfons.init

API for running taskfiles
## API



| Element | Summary |
|---------|---------|
| **Functions** |  |
| [initEnv](#initEnv) | Initialize a new Alfons environment |
| [runString](#runString) | Executes a Taskfile from a string |
| [runStringT](#runStringT) | [`runString`](/alfons/init#runString) with table arguments |
| **Types** |  |
| [Environment](#Environment) | The environment returned by [`initEnv`](/alfons/init#initEnv). |
| [RunStringOptions](#RunStringOptions) | Arguments that can be passed to [`runString`](/alfons/init#runString) and [`runStringT`](/alfons/init#runStringT) |

<div markdown class='fir-symbol fancy-scrollbar'>
### <strong>initEnv</strong>&nbsp;
<span class='annotate'>:: run:?, base:table, genv:table, modname:string, pretty:boolean, debug_mode:boolean -> env:[Environment](/alfons/init#Environment)</span>
</div>


Initialize a new Alfons environment

- Initialize a new Alfons environment

<div markdown class='fir-symbol fancy-scrollbar'>
### <strong>runString</strong>&nbsp;
<span class='annotate'>:: ...args:RunStringOptions -> ...args:{string:any} -> env:[Environment](/alfons/init#Environment)</span>
</div>


Executes a Taskfile from a string

- Executes a Taskfile from a string

<div markdown class='fir-symbol fancy-scrollbar'>
### <strong>runStringT</strong>&nbsp;
<span class='annotate'>:: options:RunStringOptions -> ...args:any -> env:[Environment](/alfons/init#Environment)</span>
</div>


[`runString`](/alfons/init#runString) with table arguments

- [`runString`](/alfons/init#runString) with table arguments

<div markdown class='fir-symbol fancy-scrollbar'>
### <strong>Environment</strong>&nbsp;
</div>

The environment returned by [`initEnv`](/alfons/init#initEnv).


=== "Environment"

    ```hs
    Environment {
      tasks: {
        <metatable>: {
          __index: k:string -> task:Task
        }
      }
      <metatable>: {
        __index: k:string -> any
        __newindex: k:string, v:Task -> void
        __ran: number
      }
    }
    ```


<div markdown class='fir-symbol fancy-scrollbar'>
### <strong>RunStringOptions</strong>&nbsp;
</div>

Arguments that can be passed to [`runString`](/alfons/init#runString) and [`runStringT`](/alfons/init#runStringT)


#### Parameters

Parameters that have an alternative name, like `genv` or `global_environment`, only use their
longer name in [`runStringT`](/alfons/init#runStringT), not [`runString`](/alfons/init#runString).
 
| **Parameter** | **Type** | **Default** | **Meaning** |
|---------------|----------|-------------|-------------|
| `content` | string | None | Taskfile content |
| `environment` | table | `ENVIRONMENT` | Base environment table |
| `runAlways` | boolean | `true` | Whether to run the `always` task |
| `child` | number | `0` | Level of the Taskfile being run |
| `genv`/`global_environment` | table | `{}` | Shared environment between all Taskfiles |
| `rqueue`/`finalize_queue` | array | `{}` | Queue of `finalize` tasks to run from all Taskfiles |
| `pretty` | boolean | `false` | Whether to print using [ansikit](https://daelvn.github.io/ansikit) |
| `debug_mode` | boolean | `false` | Whether to include Lua's `debug` in the base environment |
