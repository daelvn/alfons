# Autocompletion

Alfons 5.2 introduced dynamic shell autocompletion. That means that on most shells (but especially Zsh), you will get completions for tasks, task options and maybe even task values.

## Bash

The Bash completion script is very poor. This is because Bash's autocompletion is very poor. It will list the available tasks, and if it can detect a task, also suggest the options for that task.

### Installing

```
# cp bin/completion.bash /etc/bash_completion.d/alfons
```

## Zsh

Zsh will autocomplete tasks, task options, and for certain task options, also suggest values.

If a task option has a value of `<file>`, `<user>`, `<group>` or `<path>`, it will use Zsh's internal resolvers to complete suggestions.

### Installing

Move the completion file to anywhere in your `$FPATH`.

```sh
# Oh my Zsh!
$ cp bin/completion.zsh $HOME/.oh-my-zsh/completions/_alfons
# Hopefully cross platform
$ sudo cp bin/completion.zsh /usr/share/zsh/functions/Completion/_alfons
```
