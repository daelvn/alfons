# alfons completion                                        -*- shell-script -*-

# This bash completions script was generated by
# completely (https://github.com/dannyben/completely)
# Modifying it manually is not recommended

_alfons_completions_filter() {
  local words="$1"
  local cur=${COMP_WORDS[COMP_CWORD]}
  local result=()

  if [[ "${cur:0:1}" == "-" ]]; then
    echo "$words"
  
  else
    for word in $words; do
      [[ "${word:0:1}" != "-" ]] && result+=("$word")
    done

    echo "${result[*]}"

  fi
}

_alfons_completions() {
  local cur=${COMP_WORDS[COMP_CWORD]}
  local compwords=("${COMP_WORDS[@]:1:$COMP_CWORD-1}")
  local compline="${compwords[*]}"

  case "$compline" in
    '--file'*)
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -A file -- "$cur" )
      ;;

    '-f'*)
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -A file -- "$cur" )
      ;;

    *)
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_alfons_completions_filter "--version --list --list-options --file -f $(alfons --list)")" -- "$cur" )
      ;;

  esac
} &&
complete -F _alfons_completions alfons

# ex: filetype=sh