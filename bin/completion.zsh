#compdef alfons

_alfons() {
  local state
  
  _arguments \
    '*:task:->task'

  case "$state" in
    task)
      args=($(alfons --list | xargs))
      _describe -t args 'task name' args && return 0
      ;;
  esac
}
