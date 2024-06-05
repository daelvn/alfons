#compdef alfons

_alfons() {
  local state
  
  _arguments \
    '--list[list available tasks]::' \
    '--list-options[list available options for a task]:listopt:->listopt' \
    '(--file -f)'{--file=,-f}"[taskfile to use]:taskfile:_files" \
    '*:task:->task'

  case "$state" in
    task)
      args=($(alfons --list | xargs))
      _describe -t args 'task name' args && return 0
      ;;
  esac
}
