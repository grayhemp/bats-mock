#!/usr/bin/env bats

set -euo pipefail

load ../src/bats-mock

@test 'path_rm requires a path or command to remove to be specified' {
  run path_rm
  [[ "${status}" -eq 1 ]]
  [[ "${output}" =~ 'Path or command to remove must be specified' ]]
}

@test 'path_rm removes directory from PATH' {
  [[ ":${PATH}:" == *:/usr/bin:* ]]
  run path_rm /usr/bin
  [[ "${status}" -eq 0 ]]
  [[ ! ":${output}:" == *:/usr/bin:* ]]
}

@test 'path_rm removes directory from given path' {
  run path_rm "/a/b" "/c/d:/a/b:/e/f"
  [[ "${status}" -eq 0 ]]
  [[ "${output}" =~ '/c/d:/e/f' ]]
}

@test 'path_rm returns path unchanged if it is not contained' {
  run path_rm "/a/x" "/c/d:/a/b:/e/f"
  [[ "${status}" -eq 0 ]]
  [[ "${output}" =~ '/c/d:/a/b:/e/f' ]]
}

@test 'path_rm removes directory of given command from path' {
  cmd=$(command -v bash)
  path_to_cmd=$(dirname "${cmd}")
  run path_rm "${cmd}"
  [[ "${status}" -eq 0 ]]
  [[ ! ":${output}:" == *":${path_to_cmd}:"* ]]
}
