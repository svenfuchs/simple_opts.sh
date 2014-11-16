# set -e

. lib/simple_opts.sh

end() {
  ((test_indent -= 2))
  if [ $test_indent -eq 0 ]; then
    [ $failures -eq 0 ]
  fi
}
