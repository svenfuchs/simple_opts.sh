#!/bin/bash

declare -a OPTS

puts() {
  echo $@ >&2
}

__opt_parse() {
  local opts=$1
  local args=" $ARGS "
  local flag negated name value

  for opt in $opts; do
    name=$(__opt_name $opt "$opts")
    flag=$(__opt_is_flag $name "$opts")
    name=$(echo $name | tr - _)
    [[ $opt =~ ^--no- ]] && negated=true || negated=false
    opt=${opt%=}
    opt=${opt%:*}
    # puts name: $name, flag: $flag, negated: $negated, opt: $opt, args: \"$args\"

    count=$(grep -o $(echo $opt | sed 's/-/\\-/g') <<< $args | wc -l)
    if (( count > 1 )); then
      local type_$name=array
    fi

    while [[ " $args " =~ " $opt" || $negated = true ]]; do
      if [ -n "$flag" ]; then
        [[ " $args " =~ " $opt" ]] && value=true || value=false
        [[ $negated = true ]] && value=$(__opt_negate $value)
      else
        value=$([[ " $args " =~ $opt( |=)([^ ]+) ]] && echo ${BASH_REMATCH[2]} || echo '')
      fi

      eval " __opt_set $name \"$value\" \$type_$name"
      args=$(__opt_strip $name "$value" $opt $args)

      [[ $negated = false ]] || break
    done
  done

  ARGS=$args
}

__opt_negate() {
  [[ $1 = true ]] && echo false || echo true
}

__opt_set() {
  local name=$1
  local value=$2
  local type=$3

  if [[ $name =~ ^no_ ]]; then
    name=${name#no_}
  fi

  # puts name: $name, value: $value

  if [ "$type" = 'array' ]; then
    name=${name}s
    eval "$name=\$( echo \"\$$name $value\" | sed 's/^ //' )"
  else
    eval "$name=\"$value\""
  fi
}

__opt_strip() {
  local name=$1
  local value=$2
  local opt=$3
  shift 3
  local args=$@

  if [[ $value = true || $value = false ]]; then
    echo $args | sed s/$opt// | sed 's/(^ *| *$)//g'
  else
    echo $args | sed "s/$opt.*$(echo $value | sed s-/-\\\\/-g)//g" | sed 's/(^ *| *$)//g'
  fi
}

__opt_is_flag() {
  local opt=${1#*:}
  shift
  for _opt in $@; do
    [[ $_opt =~ $opt=$ ]] && return
  done
  echo true
}

__opt_name() {
  local opt=$1
  shift

  if [[ $opt =~ : ]]; then
    echo ${opt#*:} | tr -d =
  elif [[ $opt =~ --([A-Za-z_-]+) ]]; then
    echo ${BASH_REMATCH[1]}
  else
    opt=$(echo $opt | sed s/^-//)
    [[ " $@ " =~ --($opt[A-Za-z_-]+)(=| ) ]] && echo ${BASH_REMATCH[1]}
  fi
}

opt() {
  OPTS[${#OPTS[@]}]="$@"
}

opt_parse() {
  ARGS=$@
  local data

  if [[ $ARGS =~ \ --\ (.*) ]]; then
    data=${BASH_REMATCH[1]}
    ARGS=${ARGS%\ --\ *}
  fi

  for opts in "${OPTS[@]}"; do
    __opt_parse "$opts"
  done
  OPTS=()

  ARGS=$(echo $ARGS | sed 's/(^ | $)//g')
  if [[ " $ARGS " =~ " -" ]]; then
    echo "Unknown options $ARGS" >&2
    exit 1
  fi

  IFS=' ' read -a ARGS <<< "$ARGS"
  if [[ -n $data ]]; then
    ARGS[${#ARGS[@]}]=$data
  fi
}
