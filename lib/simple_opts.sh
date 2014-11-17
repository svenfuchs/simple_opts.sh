#!/bin/bash

declare -a OPTS

puts() {
  echo $@ >&2
}

__opt_parse() {
  local _opts=$1
  local _args=" $ARGS "
  local _flag _negated _name _value

  for opt in $_opts; do
    _name=$(__opt_name $opt "$_opts")
    _flag=$(__opt_is_flag $_name "$_opts")
    _name=$(echo $_name | tr - _)
    [[ $opt =~ ^--no- ]] && _negated=true || _negated=false
    opt=${opt%=}
    opt=${opt%:*}
    # puts _name: $_name, _flag: $_flag, _negated: $_negated, opt: $opt, _args: \"$_args\"

    count=$(grep -o $(echo $opt | sed 's/-/\\-/g') <<< $_args | wc -l)
    if (( count > 1 )); then
      local _type_$_name=array
    fi

    while [[ " $_args " =~ " $opt" || $_negated = true ]]; do
      if [ -n "$_flag" ]; then
        [[ " $_args " =~ " $opt" ]] && _value=true || _value=false
        [[ $_negated = true ]] && _value=$(__opt_negate $_value)
      else
        _value=$([[ " $_args " =~ $opt( |=)([^ ]+) ]] && echo ${BASH_REMATCH[2]} || echo '')
      fi

      eval " __opt_set $_name \"$_value\" \$_type_$_name"
      _args=$(__opt_strip $_name "$_value" $opt $_args)

      [[ $_negated = false ]] || break
    done
  done
  ARGS=$_args
}

__opt_negate() {
  [[ $1 = true ]] && echo false || echo true
}

__opt_set() {
  local _name=$1
  local _value=$2
  local _type=$3

  if [[ $_name =~ ^no_ ]]; then
    _name=${_name#no_}
  fi

  # puts _name: $_name, _value: $_value, _type: $_type

  if [ "$_type" = 'array' ]; then
    _name=${_name}s
    eval "$_name=\$( echo \"\$$_name $_value\" | sed 's/^ //' )"
  else
    eval "$_name=\"$_value\""
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
    echo $args | sed "s/$opt[ =]*$(echo $value | sed s-/-\\\\/-g)//" | sed 's/(^ *| *$)//g'
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
