<!-- markdownlint-disable MD013 -->

# Rem

`rem` is a quick and simple recycle bin, I've tried a few other scripts and they were clunky and, at times, a little broken.

## Description

The simplicity of `rem` is in its core functionality, it base64 encodes full filepaths and moves them to a storage location (`$STORE_DIR`), that's it.

At runtime, the contents of this location are taken and decoded and a list of the removed files can be used.

## Installation

Included is a simple install script which will symlink `rem` to a suitable location on your `PATH`.

If you wish to copy the file, pass `"install"` as the first argument to this script

```sh
git clone https://github.com/BodneyC/rem.git
cd rem
./install.sh # "install"
```

### Tests

Currently using the [BATS](https://github.com/bats-core/bats-core) testing framework added as submodules, so either clone with:

```sh
git clone --recurse-submodules https://github.com/BodneyC/rem.git
```

or initialise them with:

```sh
git submodule update --init --recursive
```

then:

```sh
./rem.bats.bash
```

to run the tests.

## Usage

There are six subcommands (used as `rem {subcommand}`):

- `remove`: Moves the given file to the storage location
- `delete`: Which deletes files in the storage location
- `restore`: Which restores files from the storage location
- `search`: List files in the storage location matching a `grep` pattern
- `research` (`res`tore via `search`): This first performs a search and if any results are found, restores them
- `clean`: Empty the storage location
- `last`: Will restore the last file `remove`ed

`search` can be useful when `r`e`s`toring to save writing full paths, eg:

    $ rem rs $(rem sr "myfile")

alternatively, `rem research` can be used

    $ rem rr "myfile"

this will `[yn]` prompt you, if you don't want this, pass `-f` for "force".

Nothing more to it really.

### CLI

```txt
Rem, a simple recycle bin script; usage:

    rem [(--help|--version|--no-colors|--force|--quiet)]
        (remove|restore|research|delete|clean|search)
        [<args>]

Options:

  -h|--help:      show this help information
  -s|--version:   show version information
  -n|--no-colors: disable color output
  -f|--force:     disable yes/no prompts
  -q|--quiet:     disable prompts and output

Subcommands:

  remove:
    aliases: rm, rem, remove
    desc:    moves specified file(s) to $STORE_DIR

  restore:
    aliases: rs, res, restore
    desc:    restore file(s) from $STORE_DIR (args either with or without
             $STORE_DIR prefix)

  delete:
    alias:   dl, del, delte
    desc:    delete files from $STORE_DIR

  search:
    aliases: sr, sear, search
    desc:    search files added to $STORE_DIR, grep expressions as optional args

  research:
    aliases: rr, resear, rrch
    desc:    restore via search, file(s) from $STORE_DIR (args either with or
             without $STORE_DIR prefix)

  clean:
    aliases: cl, cln, clean
    desc:    empty $STORE_DIR, you will be prompted for assurance
```
