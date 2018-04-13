#!/usr/bin/env bash
#
# A Bats helper library providing mocking functionality

# Creates a mock program
# Globals:
#   BATS_TMPDIR
# Outputs:
#   STDOUT: Path to the mock
mock_create() {
  local index
  index="$(find ${BATS_TMPDIR} -name bats-mock.$$.* | wc -l | tr -d ' ')"
  local mock
  mock="${BATS_TMPDIR}/bats-mock.$$.${index}"

  echo -n 0 > "${mock}.call_num"
  echo -n 0 > "${mock}.status"
  echo -n '' > "${mock}.output"
  echo -n '' > "${mock}.side_effect"

  cat <<EOF > "${mock}"
#!/usr/bin/env bash

set -e

mock="${mock}"

call_num="\$(( \$(cat \${mock}.call_num) + 1 ))"
echo "\${call_num}" > "\${mock}.call_num"

echo "\${_USER:-\$(id -un)}" > "\${mock}.user.\${call_num}"

echo "\$@" > "\${mock}.args.\${call_num}"

for var in \$(compgen -e); do
  declare -p "\${var}"
done > "\${mock}.env.\${call_num}"

if [[ -e "\${mock}.output.\${call_num}" ]]; then
  cat "\${mock}.output.\${call_num}"
else
  cat "\${mock}.output"
fi

if [[ -e "\${mock}.side_effect.\${call_num}" ]]; then
  source "\${mock}.side_effect.\${call_num}"
else
  source "\${mock}.side_effect"
fi

if [[ -e "\${mock}.status.\${call_num}" ]]; then
  exit "\$(cat \${mock}.status.\${call_num})"
else
  exit "\$(cat \${mock}.status)"
fi
EOF
  chmod +x "${mock}"

  echo "${mock}"
}

# Sets the exit status of the mock
# Arguments:
#   1: Path to the mock
#   2: Status
#   3: Index of the call, optional
mock_set_status() {
  local mock="${1?'Mock must be specified'}"
  local status="${2?'Status must be specified'}"
  local n="$3"

  if [[ -n "${n}" ]]; then
    echo "${status}" > "${mock}.status.${n}"
  else
    echo "${status}" > "${mock}.status"
  fi
}

# Sets the output of the mock
# Arguments:
#   1: Path to the mock
#   2: Output or - for STDIN
#   3: Index of the call, optional
# Inputs:
#   STDIN: Output if 2 is -
mock_set_output() {
  local mock="${1?'Mock must be specified'}"
  local output="${2?'Output must be specified'}"
  local n="$3"

  if [[ "${output}" = '-' ]]; then
    output="$(cat -)"
  fi

  if [[ -n "${n}" ]]; then
    echo -e "${output}" > "${mock}.output.${n}"
  else
    echo -e "${output}" > "${mock}.output"
  fi
}

# Sets the side effect of the mock
# Arguments:
#   1: Path to the mock
#   2: Side effect or - for STDIN
#   3: Index of the call, optional
# Inputs:
#   STDIN: Side effect if 2 is -
mock_set_side_effect() {
  local mock="${1?'Mock must be specified'}"
  local side_effect="${2?'Side effect must be specified'}"
  local n="$3"

  if [[ "${side_effect}" = '-' ]]; then
    side_effect="$(cat -)"
  fi

  if [[ -n "${n}" ]]; then
    echo -e "${side_effect}" > "${mock}.side_effect.${n}"
  else
    echo -e "${side_effect}" > "${mock}.side_effect"
  fi
}

# Returns the number of times the mock was called
# Arguments:
#   1: Path to the mock
# Outputs:
#   STDOUT: Number of calls
mock_get_call_num() {
  local mock="${1?'Mock must be specified'}"

  echo "$(cat ${mock}.call_num)"
}

# Returns the user the mock was called with
# Arguments:
#   1: Path to the mock
#   2: Index of the call, optional
# Returns:
#   1: If mock is not called enough times
# Outputs:
#   STDOUT: User name
#   STDERR: Corresponding error message
mock_get_call_user() {
  local mock="${1?'Mock must be specified'}"
  local n="$2"

  local call_num
  call_num="$(cat ${mock}.call_num)"

  local n="${2:-${call_num}}"
  if [[ "${n}" -eq 0 ]]; then
    n=1
  fi

  if [[ "${n}" -gt "${call_num}" ]]; then
    echo "Mock must be called at least ${n} time(s)" >&2
    exit 1
  fi

  echo "$(cat ${mock}.user.${n})"
}

# Returns the arguments line the mock was called with
# Arguments:
#   1: Path to the mock
#   2: Index of the call, optional
# Returns:
#   1: If mock is not called enough times
# Outputs:
#   STDOUT: Arguments line
#   STDERR: Corresponding error message
mock_get_call_args() {
  local mock="${1?'Mock must be specified'}"

  local call_num
  call_num="$(cat ${mock}.call_num)"

  local n="${2:-${call_num}}"
  if [[ "${n}" -eq 0 ]]; then
    n=1
  fi

  if [[ "${n}" -gt "${call_num}" ]]; then
    echo "Mock must be called at least ${n} time(s)" >&2
    exit 1
  fi

  echo "$(cat ${mock}.args.${n})"
}

# Returns the value of the environment variable the mock was called with
# Arguments:
#   1: Path to the mock
#   2: Variable name
#   3: Index of the call, optional
# Returns:
#   1: If mock is not called enough times
# Outputs:
#   STDOUT: Variable value
#   STDERR: Corresponding error message
mock_get_call_env() {
  local mock="${1?'Mock must be specified'}"
  local var="${2?'Variable name must be specified'}"

  local call_num
  call_num="$(cat ${mock}.call_num)"

  local n="${3:-${call_num}}"
  if [[ "${n}" -eq 0 ]]; then
    n=1
  fi

  if [[ "${n}" -gt "${call_num}" ]]; then
    echo "Mock must be called at least ${n} time(s)" >&2
    exit 1
  fi

  source "${mock}.env.${n}"

  echo "${!var}"
}
