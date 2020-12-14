<!-- markdownlint-disable MD013 -->

# Rem

`rem` is a quick and simple recyle bin, I've tried a few other scripts and they were clunky and, at times, a little broken.

## Description

The simplicity of `rem` is in its core functionality, it base64 encodes full filepaths and moves them to a storage location (`$STORE_DIR`), that's it.

At runtime, the contents of this location are taken and decoded and a list of the removed files can be used.

## Usage

There are five subcommands (so `rem <subcom>`):

- `remove`: Moves the given file to the storage location
- `delete`: Which deletes files in the storage location
- `restore`: Which restores files from the storage location
- `search`: List files in the storage location matching a `grep` pattern
- `research`: This first performs a search and if any results are found, restores them
- `clean`: Empty the storage location

`search` can be useful when `delete`ing to save writing full paths, eg:

    $ rem dl $(rem sr "myfile")

alternatively, `rem research` can be used

    $ rem rr "myfile"

this will `[yn]` prompt you, if you don't want this, pass `-p` for "no prompt".

Nothing more to it really.

### CLI

```txt
Rem usage:

    rem [(--help|--version)] (remove|restore|delete|clean|search) [<args>]

  remove:
    aliases: rm, rem, remove
    desc:    moves specified file(s) to $STORE_DIR

  restore:
    aliases: rs, res, restore
    desc:    restore file(s) from $STORE_DIR (args either with or with $STORE_DIR prefix)

  delete:
    alias:   dl, del, delte
    desc:    delete files from $STORE_DIR

  search:
    aliases: sr, sear, search
    desc:    search files added to \$STORE_DIR, grep expressions as optional args

  research:
    aliases: rr, resear, rrch
    desc:    restore via search, file(s) from \$STORE_DIR (args either with or
             without \$STORE_DIR prefix)

  clean:
    aliases: cl, cln, clean
    desc:    empty $STORE_DIR, you will be prompted for assurance
```
