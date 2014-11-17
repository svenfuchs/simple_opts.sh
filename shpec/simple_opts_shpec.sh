. shpec/shpec_helper.sh

describe 'simple_opts'
  describe 'flags'
    describe 'long and short defined'
      it 'long given'
        verbose=
        opt --verbose -v
        opt_parse --verbose
        assert equal "$verbose" true

      it 'short given'
        verbose=
        opt --verbose -v
        opt_parse -v
        assert equal "$verbose" true
    end

    describe 'long defined'
      it 'long given'
        verbose=
        opt --verbose
        opt_parse --verbose
        assert equal "$verbose" true

      it 'alternate name'
        silent=
        opt --quiet:silent
        opt_parse --quiet
        assert equal "$silent" true
    end

    describe 'short defined'
      it 'short given'
        verbose=
        opt -v:verbose
        opt_parse -v
        assert equal "$verbose" true
  end

  describe 'vars'
    describe 'long and short defined'
      it 'long given, without ='
        file=
        opt --file= -f
        opt_parse --file path/to/file.sh
        assert equal "$file" path/to/file.sh

      it 'long given, with ='
        file=
        opt --file= -f
        opt_parse --file=path/to/file.sh
        assert equal "$file" path/to/file.sh

      it 'short given, without ='
        file=
        opt --file= -f
        opt_parse -f path/to/file.sh
        assert equal "$file" path/to/file.sh

      it 'short given, with ='
        file=
        opt --file= -f
        opt_parse -f=path/to/file.sh
        assert equal "$file" path/to/file.sh
    end

    describe 'long defined'
      it 'long given, without ='
        file=
        opt --file=
        opt_parse --file path/to/file.sh
        assert equal "$file" path/to/file.sh


      it 'long given, with ='
        file=
        opt --file=
        opt_parse --file=path/to/file.sh
        assert equal "$file" path/to/file.sh

      it 'alternate name'
        path=
        opt --file:path=
        opt_parse --file path/to/file.sh
        assert equal "$path" path/to/file.sh
    end

    describe 'short defined'
      it 'short given, without ='
        file=
        opt -f:file=
        opt_parse -f path/to/file.sh
        assert equal "$file" path/to/file.sh

      it 'short given, with ='
        file=
        opt -f:file=
        opt_parse -f=path/to/file.sh
        assert equal "$file" path/to/file.sh
    end

    it 'with underscored names'
      file_name=
      opt --file_name=
      opt_parse --file_name=path/to/file.sh
      assert equal "$file_name" path/to/file.sh

    it 'with dashed names'
      file_name=
      opt --file-name=
      opt_parse --file-name=path/to/file.sh
      assert equal "$file_name" path/to/file.sh

    it 'specified multiple times'
      opt --tag=
      opt_parse --tag foo --tag bar
      assert equal "$tags" 'foo bar'
  end

  describe 'multiple options'
    describe 'long and short defined'
      it 'long given, without ='
        file= verbose=
        opt --file= -f --verbose -v
        opt_parse --file path/to/file.sh --verbose
        assert equal "$file" path/to/file.sh
        assert equal "$verbose" true

      it 'long given, with ='
        file= verbose=
        opt --file= -f --verbose -v
        opt_parse --file=path/to/file.sh --verbose
        assert equal "$file" path/to/file.sh
        assert equal "$verbose" true

      it 'short given, without ='
        file= verbose=
        opt --file= -f --verbose -v
        opt_parse -f path/to/file.sh -v
        assert equal "$file" path/to/file.sh
        assert equal "$verbose" true

      it 'short given, with ='
        file= verbose=
        opt --file= -f --verbose -v
        opt_parse -f=path/to/file.sh -v
        assert equal "$file" path/to/file.sh
        assert equal "$verbose" true
    end

    describe 'long defined'
      it 'long given, without ='
        file= verbose=
        opt --file= --verbose
        opt_parse --file path/to/file.sh --verbose
        assert equal "$file" path/to/file.sh
        assert equal "$verbose" true

      it 'long given, with ='
        file= verbose=
        opt --file= --verbose
        opt_parse --file=path/to/file.sh --verbose
        assert equal "$file" path/to/file.sh
        assert equal "$verbose" true
    end
  end

  describe 'negated flags'
    it 'defaults to flag to true'
      prompt=
      opt --no-prompt
      opt_parse foo bar
      assert equal "$prompt" true

    it 'sets to false if given'
      prompt=
      opt --no-prompt
      opt_parse --no-prompt
      assert equal "$prompt" false

    it 'sets to true if given'
      prompt=
      opt --prompt --no-prompt
      opt_parse --prompt
      assert equal "$prompt" true

  describe 'remaining args'
    it 'given at the beginning'
      file= verbose=
      opt --file= --verbose
      opt_parse foo bar --verbose --file path/to/file.sh
      assert equal "${ARGS[0]}" foo
      assert equal "${ARGS[1]}" bar

    it 'given in the middle'
      file= verbose=
      opt --file= --verbose
      opt_parse --verbose foo bar --file path/to/file.sh
      assert equal "${ARGS[0]}" foo
      assert equal "${ARGS[1]}" bar

    it 'given at the end'
      file= verbose=
      opt --file= --verbose
      opt_parse --verbose --file path/to/file.sh foo bar
      assert equal "${ARGS[0]}" foo
      assert equal "${ARGS[1]}" bar

    it 'given at the beginning, middle, and end'
      file= verbose=
      opt --file= --verbose
      opt_parse foo --verbose bar --file path/to/file.sh baz
      assert equal "${ARGS[0]}" foo
      assert equal "${ARGS[1]}" bar

    it 'with an option with the same value given'
      name=
      opt --name=
      opt_parse --name main main
      assert equal "$name" main
      assert equal "${ARGS[0]}" main
  end

  describe 'quote'
    it 'in vars'
      file= verbose=
      opt --file= --verbose
      opt_parse --verbose --file "path/to/file.sh"
      assert equal "$file" 'path/to/file.sh'
      assert equal "$verbose" true

    # this seems wrong, not sure how to fix it
    it 'in args'
      file= verbose=
      opt --file= --verbose
      opt_parse --verbose --file path/to/file.sh "foo bar"
      assert equal "${ARGS[0]}" foo
      assert equal "${ARGS[1]}" bar
  end

  describe 'extra data separated by --'
    it 'keeps it in ARGS'
      file= verbose=
      opt --file= --verbose
      opt_parse --verbose --file path/to/file.sh foo bar -- baz buz
      assert equal "${ARGS[0]}" foo
      assert equal "${ARGS[1]}" bar
      assert equal "${ARGS[2]}" 'baz buz'
end
