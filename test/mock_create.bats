#!/usr/bin/env bats

# Load bats-mock library
load '../load'

bats_require_minimum_version 1.5.0

@test 'mock_create creates a program' {
  run mock_create
  [[ "${status}" -eq 0 ]]
  [[ -x "${output}" ]]
}

@test 'mock_create creates a program in BATS_TEST_TMPDIR' {
  run mock_create
  [[ "${status}" -eq 0 ]]
  [[ "$(dirname "${output}")" = "${BATS_TEST_TMPDIR}" ]]
}

@test 'mock_create names the program uniquely' {
  run mock_create
  [[ "${status}" -eq 0 ]]
  mock="${output}"
  run mock_create
  [[ "${status}" -eq 0 ]]
  [[ "${output}" != "${mock}" ]]
}

@test 'mock_create program names are not affected by deletion' {
  mock_0=$(mock_create)
  run mock_create
  [[ "${status}" -eq 0 ]]
  mock_1="${output}"
  # Delete first mock to check if the names are not reused
  rm "${mock_0}"
  run mock_create
  [[ "${status}" -eq 0 ]]
  mock_2="${output}"

  [[ "${mock_1}" != "${mock_2}" ]]
}

@test 'mock_create command creates a program with given name' {
  run mock_create example
  [[ "${status}" -eq 0 ]]
  [[ -x "${output}" ]]
  [[ "$(basename "${output}")" = example ]]
}

@test 'mock_create command is located in BATS_TEST_TMPDIR' {
  run mock_create example
  [[ "${status}" -eq 0 ]]
  echo "output: $output"
  [[ "$(dirname "${output}")" == "${BATS_TEST_TMPDIR}" ]]
}

@test 'mock_create command links to a mock' {
  run mock_create example
  [[ "${status}" -eq 0 ]]
  [[ "$(readlink "${output}")" =~ ${BATS_TEST_TMPDIR}/bats-mock\. ]]
}

@test 'mock_create command with absolute path creates mock in BATS_TEST_TMPDIR' {
  absolute_path=$(mktemp -u "${BATS_TMPDIR}/XXXXXX")
  run mock_create "${absolute_path}/example"
  [[ "${status}" -eq 0 ]]
  [[ "$(dirname "$(readlink "${output}")")" = "${BATS_TEST_TMPDIR}" ]]
}

@test 'mock_create command overwrites existing link in mock_bin_dir' {
  run mock_bin_dir
  [[ "${status}" -eq 0 ]]
  run mock_create cat
  [[ "${status}" -eq 0 ]]
  run readlink "${output}"
  [[ "${output}" =~ ${BATS_TEST_TMPDIR}/bats-mock\. ]]
}

@test 'mock_create command with absolute path' {
  absolute_path=$(mktemp --dry-run "${BATS_TMPDIR}/XXXXXX")
  run mock_create "${absolute_path}/example"
  [[ "${status}" -eq 0 ]]
  [[ "${output}" = "${absolute_path}/example" ]]
}

# Error cases

@test 'mock_create command twice with same command fails' {
  run mock_create example
  [[ "${status}" -eq 0 ]]
  # Set locale to C to get consistent error message
  LC_ALL=C run mock_create example
  [[ "${status}" -eq 1 ]]
  local regexp="mock_create: failed to create command 'example': command exists"
  [[ "${output}" =~ ${regexp} ]]
}

@test 'mock_create command with absolute path to existing command fails' {
  LC_ALL=C run mock_create /bin/ls
  [[ "${status}" -eq 1 ]]
  local regexp="mock_create: failed to create command '/bin/ls': command exists"
  [[ "${output}" =~ ${regexp} ]]
}

@test 'mock_create command to existing program does not create the mock' {
  LC_ALL=C run mock_create /bin/ls
  [[ "${status}" -eq 1 ]]
  [[ $(find "${BATS_TEST_TMPDIR}" -maxdepth 1 -name "bats-mock.*" 2>&1 | wc -l) -eq 0 ]]
}

# mocks should not call mocked commands needed for their creation

@test 'mock_create does not call a mocked ln' {
  ln_mock=$(mock_create ln)
  mock_set_status "${ln_mock}" 1

  # If the mock is called, a call to mock_create will fail
  PATH="${BATS_TEST_TMPDIR}:${PATH}" run -0 mock_create example
}

@test 'mock_create does not call a mocked find' {
  find_mock=$(mock_create find)
  # Since we already created a mock, mock the output of find to point to an existing mock
  mock_set_output "${find_mock}" "${BATS_TEST_TMPDIR}/bats-mock.0"

  PATH="${BATS_TEST_TMPDIR}:${PATH}" run -0 mock_create

  [[ "$(mock_get_call_num "${find_mock}")" -eq 0 ]]
}

@test 'mock_create does not call a mocked sed' {
  sed_mock=$(mock_create sed)
  # Mock the output of sed to return 0, the index of the last (sed) mock
  mock_set_output "${sed_mock}" '0'

  PATH="${BATS_TEST_TMPDIR}:${PATH}" run -0 mock_create

  [[ "$(mock_get_call_num "${sed_mock}")" -eq 0 ]]
}

@test 'mock_create does not call a mocked sort' {
  sort_mock=$(mock_create sort)
  # Mock the output of sort to return 0, the index of the last (sort) mock
  mock_set_output "${sort_mock}" '0'

  PATH="${BATS_TEST_TMPDIR}:${PATH}" run -0 mock_create

  [[ "$(mock_get_call_num "${sort_mock}")" -eq 0 ]]
}

@test 'mock_create does not call a mocked tail' {
  tail_mock=$(mock_create tail)
  # mock the output of tail to return 0, the index of the last (tail) mock
  mock_set_output "${tail_mock}" '0'

  PATH="${BATS_TEST_TMPDIR}:${PATH}" run -0 mock_create

  [[ "$(mock_get_call_num "${tail_mock}")" -eq 0 ]]
}

@test 'mock_create does not call a mocked cat' {
  # mock_create uses 'cat' for creating the mock
  cat_mock=$(mock_create cat)

  # If mock_create uses the mocked cat, we end up in an endless loop.
  # To avoid the endless loop, overwrite the mocked cat with the desired side effect.
  # In case the mocked cat is used, a call to the mock will output "mocked cat".
  cat <<EOF >"${cat_mock}"
  #!/usr/bin/env bash
  printf "#!/usr/bin/env bash\necho \"mocked cat\"\n"
EOF

  # shellcheck disable=SC2030
  PATH="${BATS_TEST_TMPDIR}:${PATH}"
  run -0 mock_create example

  run -0 example
  [[ "${output}" != "mocked cat" ]]
}

@test 'mock_create does not call a mocked chmod' {
  chmod_mock=$(mock_create chmod)

  # shellcheck disable=SC2030,SC2031
  PATH="${BATS_TEST_TMPDIR}:${PATH}" run -0 mock_create example

  [[ "$(mock_get_call_num "${chmod_mock}")" -eq 0 ]]
}

@test 'mock_create does not call a mocked mkdir' {
  mkdir_mock=$(mock_create mkdir)
  # Mocking a command with absolute path calls mkdir to assure the parent directory exists
  absolute_path=$(mktemp --dry-run "${BATS_TMPDIR}/XXXXXX")

  # shellcheck disable=SC2030,SC2031
  PATH="${BATS_TEST_TMPDIR}:${PATH}" run -0 mock_create "${absolute_path}/example"

  [[ "$(mock_get_call_num "${mkdir_mock}")" -eq 0 ]]
}

@test 'mock_create does not call a mocked readlink' {
  # Mocking a command invokes readlink to verify if the command was not mocked twice
  mock_create example >/dev/null
  readlink_mock=$(mock_create readlink)

  # shellcheck disable=SC2030,SC2031
  # Mocking a command twice should trigger an error
  PATH="${BATS_TEST_TMPDIR}:${PATH}" run -1 mock_create example

  [[ "$(mock_get_call_num "${readlink_mock}")" -eq 0 ]]
}

@test 'mock_create does not call a mocked rm' {
  # Create a symbolic link to /usr/bin/ls in the directory for mocked binaries
  mock_bin_dir ls
  rm_mock=$(mock_create rm)

  # shellcheck disable=SC2030,SC2031
  # Creating a mock on symbolic link should trigger rm to remove the existing link
  # If the mocked rm is called the link is not deleted and creating a mock for
  # 'ls' fails with "ln: ... : File exists"
  PATH="${BATS_TEST_TMPDIR}:${PATH}" run -0 mock_create ls

  [[ "$(mock_get_call_num "${rm_mock}")" -eq 0 ]]
}

@test 'mocks do not call a mocked id' {
  # Mocks use 'id' to track the user calling the mock
  id_mock=$(mock_create id)

  # If mocks use the mocked id, we end up in an endless loop.
  # To avoid this, overwrite the mocked cat with the desired side effect.
  cat <<EOF >"${id_mock}"
  #!/usr/bin/env bash
  echo john_doe
EOF

  example_mock=$(mock_create example)
  # shellcheck disable=SC2030,SC2031
  PATH="${BATS_TEST_TMPDIR}:${PATH}" example

  [[ "$(mock_get_call_user "${example_mock}")" != "john_doe" ]]
}

@test 'mocks do not call a mocked cat' {
  # Mocks use 'cat' to track the user calling the mock
  cat_mock=$(mock_create cat)

  # If mocks use the mocked cat, we end up in an endless loop.
  # To avoid this, overwrite the mocked cat with the desired side effect.
  cat <<EOF >"${cat_mock}"
  #!/usr/bin/env bash
  echo "call to mocked cat"
EOF

  _=$(mock_create example)
  # shellcheck disable=SC2030,SC2031
  PATH="${BATS_TEST_TMPDIR}:${PATH}" run -0 example

  [[ "${output}" != "call to mocked cat" ]]
}
