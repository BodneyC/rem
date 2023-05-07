#!/usr/bin/env ./test/libs/bats/bin/bats

########################## SETUP ############################

load "./test/libs/bats-support/load"
load "./test/libs/bats-assert/load"

setup() {
  FILES_DIR="test/files"
  export STORE_DIR="$FILES_DIR/.recycle"

  if [[ -d "$FILES_DIR" ]]; then
    rm -rf -- "$FILES_DIR"
  fi
  mkdir -p "$STORE_DIR"

  touch "$FILES_DIR/"{a,b,c}
}

teardown() {
  if [[ -d "$FILES_DIR" ]]; then
    rm -rf -- "$FILES_DIR"
  fi
}

########################## FLAGS ###########################

@test "Flags:    should take multiple args as one" {
  source ./rem

  run ./rem -v
  assert_success
  assert_output "Rem: $__REM_VERSION"

  run ./rem -qv
  assert_success
  assert_output ""
}

########################## SEARCH ###########################

@test "Search:   nothing in store dir" {
  run ./rem search
  assert_success
  assert_output "Recycle bin empty [$USER]"
}

########################## Flags ###########################

@test "Quiet:    flag suppresses output" {
  run ./rem search -q
  assert_success
  assert_output ""
}

@test "Quiet:    flag suppresses output" {
  run ./rem search -q
  assert_success
  assert_output ""
}

########################### REMOVE ##########################

@test "Remove:   files to store dir" {
  run ./rem "$FILES_DIR/"{a,b}
  assert_success

  refute [ -f "$FILES_DIR/a" ]
  refute [ -f "$FILES_DIR/b" ]
  assert [ -f "$FILES_DIR/c" ]
}

@test "Remove:   files show up in search" {
  run ./rem "$FILES_DIR/"{a,b}
  assert_success

  run ./rem sr
  assert_success
  echo -e "$PWD/$FILES_DIR/a\n$PWD/$FILES_DIR/b" \
    | assert_output
}

@test "Remove:   files over REM_MAX_REMOVE deleted if 'y'" {
  yes | REM_MAX_REMOVE=2 run ./rem "$FILES_DIR/"{a,b,c}
  assert_success

  run ./rem sr
  assert_success
  assert_output "Recycle bin empty [$USER]"
}

@test "Remove:   files over REM_MAX_REMOVE removed if 'n'" {
  yes "n" | REM_MAX_REMOVE=2 run ./rem "$FILES_DIR/"{a,b,c}
  assert_success

  run ./rem sr
  assert_success
  echo -e "$PWD/$FILES_DIR/a\n$PWD/$FILES_DIR/b\n$PWD/$FILES_DIR/c" \
    | assert_output
}

########################## RESTORE ##########################

@test "Restore:  files from store dir" {
  run ./rem "$FILES_DIR/"{a,b}
  assert_success
  run ./rem restore "$FILES_DIR/a"
  assert_success

  assert [ -f "$FILES_DIR/a" ]
}

@test "Restore:  files removed from search" {
  run ./rem "$FILES_DIR/"{a,b}
  assert_success
  run ./rem restore "$FILES_DIR/a"

  run ./rem search
  assert_success
  assert_output "$PWD/$FILES_DIR/b"
}

######################### RESEARCH ##########################

@test "Research: should accept a regex" {
  _rnd="$RANDOM"
  touch "$FILES_DIR/z-$_rnd"

  run ./rem "$FILES_DIR/"{a,"z-$_rnd"}
  assert_success

  yes | run ./rem research "$_rnd"
  assert_success

  assert [ -f "$FILES_DIR/z-$_rnd" ]

  run ./rem search
  assert_output "$PWD/$FILES_DIR/a"
}

########################## DELETE ###########################

@test "Delete:   file outside STORE_DIR" {
  yes | run ./rem dl "$FILES_DIR/a"
  assert_success

  refute [ -f "$FILES_DIR/a" ]
}

@test "Delete:   file outside STORE_DIR with force" {
  run ./rem dl -y "$FILES_DIR/a"
  assert_success

  refute [ -f "$FILES_DIR/a" ]
}

@test "Delete:   file within STORE_DIR" {
  run ./rem "$FILES_DIR/a"
  assert_success
  refute [ -f "$FILES_DIR/a" ]

  run ./rem dl "$FILES_DIR/a"
  assert_success

  run ./rem search
  assert_success
  assert_output "Recycle bin empty [$USER]"
}

########################### LAST ############################

@test "Last:     with nothing remmed should error" {
  run ./rem -n last
  assert_failure
  assert_output "No last file in history"
}

@test "Last:     should restore iteratively" {
  run ./rem "$FILES_DIR/"{a,b,c}
  assert_success

  run ./rem last
  assert_success
  assert [ -f "$FILES_DIR/c" ]

  run ./rem last
  assert_success

  assert [ -f "$FILES_DIR/b" ]
  refute [ -f "$FILES_DIR/a" ]
}

@test "Last:     shouldn't restore directory with -q" {
  mkdir "$FILES_DIR/some_dir"
  touch "$FILES_DIR/some_dir/a"

  run ./rem "$FILES_DIR/some_dir"
  assert_success

  mkdir "$FILES_DIR/some_dir"
  touch "$FILES_DIR/some_dir/b"

  run ./rem -q last
  assert_failure 3 # $EFILE

  refute [ -f "$FILES_DIR/some_dir/a" ]
  assert [ -f "$FILES_DIR/some_dir/b" ]

  run ./rem search
  echo -e "$PWD/$FILES_DIR/some_dir" | assert_output
}

@test "Last:     should restore directory with -qy" {
  mkdir "$FILES_DIR/some_dir"
  touch "$FILES_DIR/some_dir/a"

  run ./rem "$FILES_DIR/some_dir"
  assert_success

  mkdir "$FILES_DIR/some_dir"
  touch "$FILES_DIR/some_dir/b"

  run ./rem -qy last
  assert_success

  assert [ -f "$FILES_DIR/some_dir/a" ]
  refute [ -f "$FILES_DIR/some_dir/b" ]

  run ./rem search
  assert_success
  assert_output "Recycle bin empty [$USER]"
}

########################### CLEAN ###########################

@test "Clean:    should remove and recreate the recycle dir" {
  run ./rem "$FILES_DIR/"{a,b,c}
  assert_success

  run ./rem search
  echo -e "$PWD/$FILES_DIR/a\n$PWD/$FILES_DIR/b\n$PWD/$FILES_DIR/c" \
    | assert_output

  yes | run ./rem clean
  assert_success

  run ./rem search
  assert_success
  assert_output "Recycle bin empty [$USER]"
}
