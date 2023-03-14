#!/usr/bin/env bash
#
# A Bats helper library providing mocking functionality

# Creates a mock program
# Globals:
#   BATS_TMPDIR
# Arguments:
#   1: Command to mock, optional
# Returns:
#   1: If the mock command already exists
#   1: If the command provided with an absoluth path already exists
# Outputs:
#   STDOUT: Path to the mock
#   STDERR: Corresponding error message
mock_create() {
  local cmd="${1-}"
  local index
  index="$(find "${BATS_TMPDIR}" -name "bats-mock.$$.*" 2>&1 | \
           grep -c "${BATS_TMPDIR}/bats-mock\.$$\." | tr -d ' ')"
  local mock
  mock="${BATS_TMPDIR}/bats-mock.$$.${index}"

  # Don't create the mock if the command already exits
  if [[ -n "${cmd}" ]]; then
    cmd=$(mock_set_command "${mock}" "${cmd}") || exit $?
  fi

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

  if [[ -n "${cmd}" ]]; then
    echo "${cmd}"
  else
    echo "${mock}"
  fi
}

# Performs cleanup of mock objects
# Globals:
#   BATS_TMPDIR
mock_teardown() {
    rm -rf "${BATS_TMPDIR}"/bats-mock.$$.*
}

# Creates a symbolic link with given name to a mock program
# Globals:
#   BATS_TMPDIR
# Arguments:
#   1: Path to the mock
#   2: Command name
# Outputs:
#   STDOUT: Path to the mocked command
mock_set_command() {
  local mock="${1?'Mocked command must be specified'}"
  local cmd="${2?'Command must be specified'}"

  # Parameter expansion to get the folder portion of the mock's path
  local mock_path="${mock%/*}/bats-mock.$$.bin"

  if [[ "${cmd}" = /* ]]; then
    # Parameter expansion to get the folder portion of the command's path
    mock_path="${cmd%/*}"
  else
    cmd="${mock_path}/${cmd}"
  fi

  # Create command stub by linking it to the mock
  mkdir -p "${mock_path}"
  ln -s "${mock}" "${cmd}" && echo "${cmd}"
}

# Sets the exit status of the mock
# Arguments:
#   1: Path to the mock
#   2: Status
#   3: Index of the call, optional
mock_set_status() {
  local mock="${1?'Mock must be specified'}"
  local status="${2?'Status must be specified'}"
  local n="${3-}"

  mock_set_property "${mock}" 'status' "${status}" "${n}"
}

# Sets the output of the mock
# Arguments:
#   1: Path to the mock
#   2: Output or - for STDIN
#   3: Index of the call, optional
mock_set_output() {
  local mock="${1?'Mock must be specified'}"
  local output="${2?'Output must be specified'}"
  local n="${3-}"

  mock_set_property "${mock}" 'output' "${output}" "${n}"
}

# Sets the side effect of the mock
# Arguments:
#   1: Path to the mock
#   2: Side effect or - for STDIN
#   3: Index of the call, optional
mock_set_side_effect() {
  local mock="${1?'Mock must be specified'}"
  local side_effect="${2?'Side effect must be specified'}"
  local n="${3-}"

  mock_set_property "${mock}" 'side_effect' "${side_effect}" "${n}"
}

# Returns the number of times the mock was called
# Arguments:
#   1: Path to the mock
# Outputs:
#   STDOUT: Number of calls
mock_get_call_num() {
  local mock="${1?'Mock must be specified'}"
  # Make sure to resolve links in case we received a mock command
  mock=$(readlink -f "${mock}")

  cat "${mock}.call_num"
}

# Returns the user the mock was called with
# Arguments:
#   1: Path to the mock
#   2: Index of the call, optional
# Outputs:
#   STDOUT: User name
mock_get_call_user() {
  local mock="${1?'Mock must be specified'}"
  # Make sure to resolve links in case we received a mock command
  mock=$(readlink -f "${mock}")

  local n
  n="$(mock_default_n "${mock}" "${2-}")" || exit "$?"

  cat "${mock}.user.${n}"
}

# Returns the arguments line the mock was called with
# Arguments:
#   1: Path to the mock
#   2: Index of the call, optional
# Outputs:
#   STDOUT: Arguments line
mock_get_call_args() {
  local mock="${1?'Mock must be specified'}"
  # Make sure to resolve links in case we received a mock command
  mock=$(readlink -f "${mock}")

  local n
  n="$(mock_default_n "${mock}" "${2-}")" || exit "$?"

  cat "${mock}.args.${n}"
}

# Returns the value of the environment variable the mock was called with
# Arguments:
#   1: Path to the mock
#   2: Variable name
#   3: Index of the call, optional
# Outputs:
#   STDOUT: Variable value
mock_get_call_env() {
  local mock="${1?'Mock must be specified'}"
  local var="${2?'Variable name must be specified'}"
  # Make sure to resolve links in case we received a mock command
  mock=$(readlink -f "${mock}")

  local n
  n="$(mock_default_n "${mock}" "${3-}")" || exit "$?"

  source "${mock}.env.${n}"
  echo "${!var-}"
}

# Sets a specific property of the mock
# Arguments:
#   1: Path to the mock
#   2: Property name
#   3: Property value or - for STDIN
#   4: Index of the call, optional
# Inputs:
#   STDIN: Property value if 2 is -
mock_set_property() {
  local mock="${1?'Mock must be specified'}"
  local property_name="${2?'Property name must be specified'}"
  local property_value="${3?'Property value must be specified'}"
  local n="${4-}"

  if [[ "${property_value}" = '-' ]]; then
    property_value="$(cat -)"
  fi

  # Make sure to resolve links in case we received a mock command
  mock=$(readlink -f "${mock}")

  if [[ -n "${n}" ]]; then
    echo -e "${property_value}" > "${mock}.${property_name}.${n}"
  else
    echo -e "${property_value}" > "${mock}.${property_name}"
  fi
}

# Defaults call index to the last one if not specified explicitly
# Arguments:
#   1: Path to the mock
#   2: Index of the call, optional
# Returns:
#   1: If mock is not called enough times
# Outputs:
#   STDOUT: Call index
#   STDERR: Corresponding error message
mock_default_n() {
  local mock="${1?'Mock must be specified'}"
  local call_num
  call_num="$(cat "${mock}.call_num")"
  local n="${2:-${call_num}}"

  if [[ "${n}" -eq 0 ]]; then
    n=1
  fi

  if [[ "${n}" -gt "${call_num}" ]]; then
    echo "$(basename "$0"): Mock must be called at least ${n} time(s)" >&2
    exit 1
  fi

  echo "${n}"
}

# Returns a path prefixed with the mock's directory
# Arguments:
#   1: Path to the mock which may be a file, directory or link
#   2: Path to be prefixed by the path from the 1st argument. Defaults to $PATH if not provided.
# Outputs:
#   STDOUT: the path prefixed with the mock's directory
path_override() {
  local mock="${1?'Mock must be specified'}"
  local path=${2:-${PATH}}
  local mock_path="${mock}"

  if [[ -f "${mock}" ]]; then
    # Parameter expansion to get the folder portion of the mock's path
    local mock_path="${mock%/*}"
  fi

  # Putting the directory with the mocked comands at the beginning of the PATH
  # so it gets picked up first
  if [[ :${path}: == *:${mock_path}:* ]]; then
      echo "${path}"
  else
      echo "${mock_path}:${path}"
  fi
}

# Returns $PATH without a provided path
# Arguments:
#   1: Path to be removed
#   2: Path from which the 1st argument is removed. Defaults to $PATH if not provided.
# Outputs:
#   STDOUT: a path without the path provided in ${1}
path_rm() {
  local path_to_remove=${1?'Path or command to remove must be specified'}
  local path=${2:-${PATH}}
  if [[ -f "${path_to_remove}" ]]; then
      # Parameter expansion to get the folder portion of the temp mock's path
      path_to_remove=${path_to_remove%/*}
  fi
  path=":$path:"
  path=${path//":"/"::"}
  path=${path//":${path_to_remove}:"/}
  path=${path//"::"/":"}
  path=${path#:}
  path=${path%:}
  echo "${path}"
}

# Returns a path to directory populated with symolic links to basic commands
# Globals:
#   BATS_TMPDIR
# Arguments:
#   1: List of commands to be added to the directory, optional
# Returns:
#   1: If one of the commands provided in the argument can't be found
# Outputs:
#   STDOUT: Path to the directory
#   STDERR: Corresponding error message
mock_chroot() {
  local commands=( "$@" )
  local chroot_path="${BATS_TMPDIR}/bats-mock.$$.bin"
  local customized_chroot=true

  # Use absoluth paths for mkdir and ln, since '/bin' may be not in $PATH anymore.
  command -p mkdir -p "${chroot_path}"
  if [[ ${#commands[@]} -eq 0 ]]; then
    customized_chroot=false
    commands=( awk basename bash cat chmod chown cp cut date env \
               dirname getopt grep head id find hostname ln ls mkdir \
               mktemp mv pidof readlink rm rmdir sed sh sleep sort \
               split tail tee tempfile touch tr tty uname uniq unlink \
               wc which xargs )
  fi
  for c in "${commands[@]}";
  do
    if ! target=$(command -v "$c" 2>&1) && ${customized_chroot}; then
      echo "$c: command not found" && exit 1
    elif ! error_msg=$(command -p ln -s "${target}" "${chroot_path}/${c}" 2>&1) && ${customized_chroot}; then
      echo "${error_msg}" && exit 1
    fi
  done
  echo "${chroot_path}"
}
