#!/usr/bin/env bats

set -euo pipefail

load ../src/bats-mock

teardown() {
  rm -rf "${BATS_TMPDIR}/bats-mock.$$."*
}

@test 'mock_create creates a program' {
  run mock_create
  [[ "${status}" -eq 0 ]]
  [[ -x "${output}" ]]
}

@test 'mock_create names the program uniquely' {
  run mock_create
  [[ "${status}" -eq 0 ]]
  mock="${output}"
  run mock_create
  [[ "${status}" -eq 0 ]]
  [[ "${output}" != "${mock}" ]]
}

@test 'mock_create creates a program in BATS_TMPDIR' {
  run mock_create
  [[ "${status}" -eq 0 ]]
  [[ "$(dirname "${output}")" = "${BATS_TMPDIR}" ]]
}

@test 'mock_create command creates a program with given name' {
  run mock_create example
  [[ "${status}" -eq 0 ]]
  [[ -x "${output}" ]]
  [[ "$(basename "${output}")" = example ]]
}

@test 'mock_create command is loacted in the same directory as the mock' {
  run mock_create example
  [[ "${status}" -eq 0 ]]
  echo "command: $(dirname "${output}")"
  echo "mock: $(dirname "$(readlink "${output}")")"
  [[ "$(dirname "${output}")" == "${BATS_TMPDIR}/bats-mock.$$.bin" ]]
}

@test 'mock_create command links to a mock' {
  run mock_create example
  [[ "${status}" -eq 0 ]]
  [[ "$(readlink "${output}")" =~ ${BATS_TMPDIR}/bats-mock\.$$\. ]]
}

@test 'mock_create command with absolute path' {
  absolute_path=$(mktemp -u "${BATS_TMPDIR}/bats-mock.$$.XXXX")
  run mock_create "${absolute_path}/example"
  [[ "${status}" -eq 0 ]]
  [[ "${output}" = "${absolute_path}/example" ]]
}

@test 'mock_create command with absolute path creates mock in BATS_TMPDIR' {
  absolute_path=$(mktemp -u "${BATS_TMPDIR}/bats-mock.$$.XXXX")
  run mock_create "${absolute_path}/example"
  [[ "${status}" -eq 0 ]]
  [[ "${output}" = "${absolute_path}/example" ]]
  [[ "$(dirname "$(readlink "${output}")")" = "${BATS_TMPDIR}" ]]
}

@test 'mock_create command does not change PATH' {
  saved_path=${PATH}
  run mock_create example
  [[ "${status}" -eq 0 ]]
  [[ "${saved_path}" = "${PATH}" ]]
}

@test 'mock_create command twice with same command fails' {
  run mock_create example
  [[ "${status}" -eq 0 ]]
  LC_ALL=C run mock_create example
  echo "output: $output"
  [[ "${status}" -eq 1 ]]
  [[ "${output}" == "ln: failed to create symbolic link '${BATS_TMPDIR}/bats-mock.$$.bin/example': File exists" ]]
}

@test 'mock_create command with absolute path to existing command fails' {
  LC_ALL=C run mock_create /usr/bin/ls
  [[ "${status}" -eq 1 ]]
  [[ "${output}" =~ "ln: failed to create symbolic link '/usr/bin/ls': File exists" ]]
}

@test 'mock_create comand to existing program does not create the mock' {
  LC_ALL=C run mock_create /usr/bin/ls
  [[ "${status}" -eq 1 ]]
  [[ $(find "${BATS_TMPDIR}" -maxdepth 1 -name "bats-mock.$$.*" 2>&1 | wc -l) -eq 0 ]]
}
