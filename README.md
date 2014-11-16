# simple\_opts.sh

Simple Bash options parser, no nonsense.

```shell
# define some options
opt --file-name= -f
opt --no-prompt # now defaults to prompt=true
opt --verbose -v
# or on one line: opt --file-name= -f --verbose -v --no-prompt

# run the parser
opt_parse --file-name path/to/file.sh -v --no-prompt foo bar
# or: parse foo bar --file-name=path/to/file.sh -v --no-prompt
# or: parse foo --file_name path/to/file.sh bar -v --no-prompt
# or: parse --file_name=path/to/file.sh foo -v bar --no-prompt

# will set the following variables
echo "file_name: $file_name"
echo "verbose: $verbose"
echo "prompt: $prompt"
echo "ARGS: ${ARGS[@]}"

# file_name: path/to/file.sh
# verbose: true
# prompt:
# ARGS: foo bar
```

It is possible to define alternate variable names for options:

```shell
opt --file:path= -f:path=
opt --quiet:silent
opt -p:prompt

opt_parse --file path/to/file.sh --quiet -p

echo "path: $path"
echo "silent: $silent"
echo "prompt: $prompt"

# path: path/to/file.sh
# silent: true
# prompt: true
```

Short options can only be given with a long option that starts with the same letter, or with an alternate name.

Options can be given multiple times:

```shell
opt --tag=
opt_parse --tag foo --tag bar
echo "tags: $tags"
# tags: foo bar
```
