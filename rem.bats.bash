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

  run test -f "$FILES_DIR/a"
  assert_failure
  run test -f "$FILES_DIR/b"
  assert_failure
  run test -f "$FILES_DIR/c"
  assert_success
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

  run test -f "$FILES_DIR/a"
  assert_success
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

  run test -f "$FILES_DIR/z-$_rnd"
  assert_success

  run ./rem search
  assert_output "$PWD/$FILES_DIR/a"
}

########################## DELETE ###########################

@test "Delete:   file outside STORE_DIR" {
  yes | run ./rem dl "$FILES_DIR/a"
  assert_success

  run test -f "$FILES_DIR/a"
  assert_failure
}

@test "Delete:   file outside STORE_DIR with force" {
  run ./rem dl -f "$FILES_DIR/a"
  assert_success

  run test -f "$FILES_DIR/a"
  assert_failure
}

@test "Delete:   file within STORE_DIR" {
  run ./rem "$FILES_DIR/a"
  assert_success
  run test -f "$FILES_DIR/a"
  assert_failure

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
  assert_output "No last file in history, exiting..."
}

@test "Last:     should restore iteratively" {
  run ./rem "$FILES_DIR/"{a,b,c}
  assert_success

  run ./rem last
  assert_success
  run test -f "$FILES_DIR/c"
  assert_success

  run ./rem last
  assert_success
  run test -f "$FILES_DIR/b"
  assert_success

  run test -f "$FILES_DIR/a"
  assert_failure
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
