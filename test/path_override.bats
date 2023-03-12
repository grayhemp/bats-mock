#!/usr/bin/env bats

set -euo pipefail

load mock_test_suite

@test 'path_override requires mock to be specified' {
  run path_override
  [[ "${status}" -eq 1 ]]
  [[ "${output}" =~ 'Mock must be specified' ]]
}

@test 'path_override returns PATH prefixed with the mock directory' {
  run path_override "${mock}"
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == "$(dirname "${mock}"):$PATH" ]]
}

@test 'path_override returns PATH prefixed with directory' {
  run path_override "${mock}"
  override_with_mock="${output}"
  run path_override "$(dirname "${mock}")"
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == "${override_with_mock}" ]]
}

@test 'path_override returns a given path prefixed with the mock directory' {
  run path_override '/x/y' '/a/b:/c/d'
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == "/x/y:/a/b:/c/d" ]]
}

@test 'path_override twice has not effect' {
  run path_override "${mock}"
  local path_after_first_call=${output}
  run path_override "${mock}"
  [[ "${path_after_first_call}" = "${output}" ]]
}
