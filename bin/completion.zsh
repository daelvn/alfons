#compdef alfons

_alfons() {
  local state
  
  _arguments \
    '--help[Show help message or help for a task]:help:->help' \
    '(--file -f)'{--file=,-f}"[Taskfile to use]:taskfile:_files" \
    '--zsh-list[List loaded tasks]' \
    '--zsh-list-options[List loaded tasks for an option (ZSH)]' \
    '--zsh-get-option-type[Get option completion for an option (ZSH)]' \
    '*:Tasks:->task'

  case "$state" in
    task)
      # Task values
      taskvals="$(alfons --zsh-get-option-type ${words[-3]}::${words[-2]})"
      if [[ ! $(echo $taskvals | sed s/\n//g | sed s/\ //g) == "" ]]; then
        _arguments "*:Values for ${words[-2]}:$taskvals"
      fi
      # Task options
      taskopts=($(alfons --zsh-list-options ${words[-2]}))
      _arguments "*:Task options:(($taskopts))"
      # Tasks
      tasks=("${(@f)$(alfons --zsh-list)}")
      _describe -t tasks 'Tasks' tasks
      return 0
      ;;
  esac
}
