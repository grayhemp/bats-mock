#!/usr/bin/env bats

load test_helper/bats-mock

setup() {
  echo 'original content' > "${BATS_TMPDIR}"/program
  chmod +x "${BATS_TMPDIR}"/program
}

@test 'mock_program mocks program' {
  mock_program "${BATS_TMPDIR}"/program
  [[ "$(cat "${BATS_TMPDIR}"/program)" != 'original content' ]]
}

@test 'mock_program sets output nothing' {
  mock_program "${BATS_TMPDIR}"/program
  run "${BATS_TMPDIR}"/program
  [[ "${status}" -eq 0 ]]
  [[ "${#lines[@]} " -eq 0 ]]
}

@test 'mock_program sets output 1' {
  mock_program "${BATS_TMPDIR}"/program "line1"
  run "${BATS_TMPDIR}"/program
  [[ "${status}" -eq 0 ]]
  [[ "${lines[0]}" = 'line1' ]]
}

@test 'mock_program sets output 2' {
  mock_program "${BATS_TMPDIR}"/program "line2\nline3"
  run "${BATS_TMPDIR}"/program
  [[ "${status}" -eq 0 ]]
  [[ "${lines[0]}" = 'line2' ]]
  [[ "${lines[1]}" = 'line3' ]]
}

@test 'mock_program sets user' {
  mock_program "${BATS_TMPDIR}"/program
  run "${BATS_TMPDIR}"/program
  [[ "${status}" -eq 0 ]]
  [[ "${mock_program_user}" = "$(whoami)" ]]
}

@test 'mock_program sets args nothing' {
  mock_program "${BATS_TMPDIR}"/program
  run "${BATS_TMPDIR}"/program
  [[ "${status}" -eq 0 ]]
  [[ -z "${mock_program_args}" ]]
}

@test 'mock_program sets args 1' {
  mock_program "${BATS_TMPDIR}"/program
  run "${BATS_TMPDIR}"/program --arg1 'value1'
  [[ "${status}" -eq 0 ]]
  [[ "${mock_program_args}" = "--arg1 'value1'" ]]
}

@test 'mock_program sets args 2' {
  mock_program "${BATS_TMPDIR}"/program
  run "${BATS_TMPDIR}"/program --arg2 --arg3 'value3'
  [[ "${status}" -eq 0 ]]
  [[ "${mock_program_args}" = "--arg2 --arg3 'value3'" ]]
}

@test 'mock_program sets env nothing' {
  mock_program "${BATS_TMPDIR}"/program
  run "${BATS_TMPDIR}"/program
  [[ "${status}" -eq 0 ]]
  [[ "${#lines[@]} " -eq 0 ]]
}

@test 'mock_program sets env 1' {
  mock_program "${BATS_TMPDIR}"/program
  env1='value1' run "${BATS_TMPDIR}"/program
  [[ "${status}" -eq 0 ]]
  [[ "${mock_program_env['env1']}" = 'value1' ]]
}

@test 'mock_program sets env 2' {
  mock_program "${BATS_TMPDIR}"/program
  env2='value1' env3='value3' run "${BATS_TMPDIR}"/program
  [[ "${status}" -eq 0 ]]
  [[ "${mock_program_env['env2']}" = 'value2' ]]
  [[ "${mock_program_env['env3']}" = 'value3' ]]
}
