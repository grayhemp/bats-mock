#!/usr/bin/env bats

load mock_test_suite

@test 'path_rm requires a path or command to remove to be specified' {
  run path_rm
  [[ "${status}" -eq 1 ]]
  [[ "${output}" =~ Path\ or\ command\ to\ remove\ must\ be\ specified ]]
}

@test 'path_rm removes directory from PATH' {
  [[ ":${PATH}:" == *:/bin:* ]]
  [[ ":${PATH}:" == *:/usr/bin:* ]]

  run path_rm /usr/bin

  [[ "${status}" -eq 0 ]]
  [[ ! ":${output}:" == *:/usr/bin:* ]]
  # Verify that /bin is still present
  [[ ":${output}:" == *:/bin:* ]]
}

@test 'path_rm removes directory from given path - path head' {
  run path_rm "/a/b" "/a/b:/c/d:/e/f"

  [[ "${status}" -eq 0 ]]
  [[ "${output}" =~ /c/d:/e/f ]]
}

@test 'path_rm removes directory from given path - path middle' {
  run path_rm "/c/d" "/a/b:/c/d:/e/f"

  [[ "${status}" -eq 0 ]]
  [[ "${output}" =~ /a/b:/e/f ]]
}

@test 'path_rm removes directory from given path - path tail' {
  run path_rm "/e/f" "/a/b:/c/d:/e/f"

  [[ "${status}" -eq 0 ]]
  [[ "${output}" =~ /a/b:/c/d ]]
}

@test 'path_rm returns path unchanged if it is not contained' {
  run path_rm "/a/x" "/c/d:/a/b:/e/f"

  [[ "${status}" -eq 0 ]]
  [[ "${output}" =~ /c/d:/a/b:/e/f ]]
}

@test "path_rm removes directories of given command so that command is no longer found" {
  # Check precondition: date command is in /usr/bin and /bin
  # /bin is a symbolic link to /usr/bin on some systems.
  command -v date

  run path_rm date

  [[ "${status}" -eq 0 ]]
  PATH=${output} run ! command -v date
  ls -al /usr/bin
}

@test "path_rm terminates when a command's PATH entry has a trailing slash" {
  some_tool="$(mock_create sometool)"
  # Retains the leading / of the directory path
  some_tool_dir="${some_tool%/*}"

  # Trailing slash in PATH entry
  # shellcheck disable=SC2016 # expanded by the argument passed to bash -c
  run timeout 3 env PATH="${some_tool_dir}/:${PATH}" bash -c \
    'source "$0"; path_rm sometool' \
    "${BATS_TEST_DIRNAME}/../src/bats-mock.bash"

  [[ "${status}" -eq 0 ]]
  PATH="${output}" run ! command -v sometool
}

@test "path_rm doesn't accept relative paths" {
  run path_rm "relative/path" "/a/b:/a/b/relative/path:/c/d"

  [[ "${status}" -eq 1 ]]
  [[ "${output}" =~ Relative\ paths\ are\ not\ allowed ]]
}
