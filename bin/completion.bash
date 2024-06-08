# alfons completion                                        -*- shell-script -*-

_alfons_completions() {
  local cur prev opts
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"
  opts="--help --file -f --bash-list --bash-list-options"

  echo "cur: ${cur}\nprev: ${prev}" >> /tmp/alfons.log

  tasks=($(compgen -W "$(alfons --bash-list)" -- "$cur"))
  if [[ ${COMP_CWORD} -gt 1 ]] ; then
    task_options=($(compgen -W "$(alfons --bash-list-options $prev)" -- "$cur"))
    COMPREPLY+=( "${task_options[@]}" )
  fi
  COMPREPLY+=( "${tasks[@]}" )
}

complete -o nosort -F _alfons_completions alfons

# ex: filetype=sh
