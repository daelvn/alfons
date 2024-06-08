#compdef alfons

_alfons() {
  local state
  
  _arguments \
    '--help[Show help message or help for a task]:help:->help' \
    '(--file -f)'{--file=,-f}"[taskfile to use]:taskfile:_files" \
    '*:Tasks:->task'

  case "$state" in
    task)
      echo "${words[-3]}::${words[-2]}" >> /tmp/alfons.log
      # Task values
      taskvals="$(alfons --zsh-get-option-type ${words[-3]}::${words[-2]})"
      echo "values: $taskvals" >> /tmp/alfons.log
      if [[ ! $(echo $taskvals | sed s/\n//g | sed s/\ //g) == "" ]]; then
        _arguments "*:Values for ${words[-2]}:$taskvals"
      fi
      # Task options
      taskopts=($(alfons --zsh-list-options ${words[-2]}))
      echo "options: $taskopts" >> /tmp/alfons.log
      _arguments "*:Task options:(($taskopts))"
      # Tasks
      tasks=("${(@f)$(alfons --zsh-list)}")
      _describe -t tasks 'Tasks' tasks
      return 0
      ;;
  esac
}
