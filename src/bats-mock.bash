#!/usr/bin/env bash
#
# A Bats helper library providing mocking functionality
#
# Written in 2018-2021 by Sergey Konoplev <gray dot ru at gmail dot com>,
# updated in 2025-2026 by Max Hofer <mh182 at chello dot at>.
#
# This is free and unencumbered software released into the public domain.
#
# Anyone is free to copy, modify, publish, use, compile, sell, or
# distribute this software, either in source code form or as a compiled
# binary, for any purpose, commercial or non-commercial, and by any
# means.
#
# For more information, please refer to <http://unlicense.org>
#

# Ensure test isolation by using BATS_TEST_TMPDIR introduced with bats 1.4.0
bats_require_minimum_version '1.4.0'

# Creates a mock program
# Globals:
#   BATS_TEST_TMPDIR
# Arguments:
#   1: Command to mock, optional
# Returns:
#   1: If the mock command already exists
#   1: If the command provided with an absolute path already exists
# Outputs:
#   STDOUT: Path to the mock
#   STDERR: Corresponding error message
mock_create() {
  local cmd="${1-}"
  local index
  local mock
  local prefix='bats-mock'

  # Find the next available index. Use sort+tail instead of wc -l to avoid name
  # collisions in case a mock is deleted in the test.
  index="$(command -p find "${BATS_TEST_TMPDIR}" -maxdepth 1 -type f -name "${prefix}.*" \
    2>/dev/null | command -p sed -E "s|.*/${prefix}\.([0-9]+)$|\1|" | command -p sort -n | command -p tail -n1)"
  if [[ -z "${index}" ]]; then
    index=0
  else
    ((index++))
  fi
  mock="${BATS_TEST_TMPDIR}/${prefix}.${index}"

  # If a command name is provided, create a symbolic link to the mock
  if [[ -n "${cmd}" ]]; then
    # Don't create the mock if we can't create the link
    cmd=$(mock_set_command "${mock}" "${cmd}") || return $?
  fi

  printf '%s' 0 >"${mock}.call_num"
  printf '%s' 0 >"${mock}.status"
  printf '%s' '' >"${mock}.output"
  printf '%s' '' >"${mock}.side_effect"

  command -p cat <<EOF >"${mock}"
#!/usr/bin/env bash

set -e

mock="${mock}"

IFS= read -r prev_call_num < "\${mock}.call_num" || true
call_num="\$(( prev_call_num + 1 ))"
echo "\${call_num}" > "\${mock}.call_num"

echo "\${_USER:-\$(command -p id -un)}" > "\${mock}.user.\${call_num}"

printf "%s" "\$*" > "\${mock}.args.\${call_num}"

for var in \$(compgen -e); do
  declare -p "\${var}"
done > "\${mock}.env.\${call_num}"

if [[ -e "\${mock}.output.\${call_num}" ]]; then
  command -p cat "\${mock}.output.\${call_num}"
else
  command -p cat "\${mock}.output"
fi

if [[ -e "\${mock}.side_effect.\${call_num}" ]]; then
  source "\${mock}.side_effect.\${call_num}"
else
  source "\${mock}.side_effect"
fi

if [[ -e "\${mock}.status.\${call_num}" ]]; then
  IFS= read -r status_value < "\${mock}.status.\${call_num}" || true
else
  IFS= read -r status_value < "\${mock}.status" || true
fi
exit "\${status_value}"
EOF
  command -p chmod +x "${mock}"

  if [[ -n "${cmd}" ]]; then
    echo "${cmd}"
  else
    echo "${mock}"
  fi
}

# Creates a symbolic link with the given name to a mock program
#
# This method is not meant to be called directly. Use mock_create instead.
#
# Arguments:
#   1: Path to the mock
#   2: Command name
# Returns:
#   1: If the mock command already exists
#   1: If the command provided with an absolute path already exists
# Outputs:
#   STDOUT: Path to the mocked command
#   STDERR: Corresponding error message
mock_set_command() {
  local mock="${1?'Mocked command must be specified'}"
  local cmd="${2?'Command must be specified'}"
  local link_name="${mock%/*}/${cmd}"

  if [[ "${cmd}" = /* ]]; then
    # Command with absolute path
    if [[ -e "${cmd}" ]]; then
      printf "mock_create: failed to create command '%s': command exists\n" "${cmd}" >&2
      return 1
    fi
    link_name=${cmd}
    command -p mkdir -p "${link_name%/*}/"
  elif [[ -e "${link_name}" ]]; then
    # Link already exists: either created by mock_create or mock_bin_dir
    if [[ $(command -p readlink "${link_name}") =~ ${BATS_TEST_TMPDIR} ]]; then
      # Link pointing to a mock (created by mock_create)
      printf "mock_create: failed to create command '%s': command exists\n" "${cmd}" >&2
      return 1
    else
      # Link pointing to outside $BATS_TEST_TMPDIR (created by mock_bin_dir).
      # We can safely delete it to create a new one.
      command -p rm "${link_name}"
    fi
  fi

  # Create command stub by linking it to the mock
  command -p ln -s "${mock}" "${link_name}" && echo "${link_name}"
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
  mock=$(command -p readlink -f "${mock}")

  command -p cat "${mock}.call_num"
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
  mock=$(command -p readlink -f "${mock}")

  local n
  n="$(mock_default_n "${mock}" "${2-}")" || return "$?"

  command -p cat "${mock}.user.${n}"
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
  mock=$(command -p readlink -f "${mock}")

  local n
  n="$(mock_default_n "${mock}" "${2-}")" || return "$?"

  command -p cat "${mock}.args.${n}"
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
  mock=$(command -p readlink -f "${mock}")

  local n
  n="$(mock_default_n "${mock}" "${3-}")" || return "$?"

  # shellcheck source=/dev/null
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
    property_value="$(command -p cat -)"
  fi

  # Make sure to resolve links in case we received a mock command
  mock=$(command -p readlink -f "${mock}")

  if [[ -n "${n}" ]]; then
    printf "%b" "${property_value}" >"${mock}.${property_name}.${n}"
  else
    printf "%b" "${property_value}" >"${mock}.${property_name}"
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
  IFS= read -r call_num <"${mock}.call_num" || true
  local n="${2:-${call_num}}"

  if [[ "${n}" -eq 0 ]]; then
    n=1
  fi

  if [[ "${n}" -gt "${call_num}" ]]; then
    printf "%s: Mock must be called at least %s time(s)\n" "${0##*/}" "${n}" >&2
    return 1
  fi

  echo "${n}"
}

# Returns a path prepended with the mock's directory
# Arguments:
#   1: Path to the mock which may be a file, directory or link
#   2: Path to be prepended by the path from the 1st argument. Defaults to $PATH if not provided.
# Outputs:
#   STDOUT: the path prepended with the mock's directory
path_prepend() {
  local mock="${1?'Mock must be specified'}"
  local path=${2:-${PATH}}
  local mock_path="${mock}"

  if [[ "${mock}" != /* ]]; then
    echo "Relative paths are not allowed"
    return 1
  fi

  if [[ -f "${mock}" ]]; then
    # Parameter expansion to get the folder portion of the mock's path
    local mock_path="${mock%/*}"
  fi

  # Putting the directory with the mocked commands at the beginning of the PATH
  # so it gets picked up first
  if [[ :${path}: == *:${mock_path}:* ]]; then
    echo "${path}"
  else
    echo "${mock_path}:${path}"
  fi
}

# Returns $PATH without the provided path
# Arguments:
#   1: Path to be removed
#   2: Path list from which the 1st argument is removed. Defaults to $PATH if not provided.
# Outputs:
#   STDOUT: a path without the path provided in ${1}
path_rm() {
  local path_or_cmd_to_remove=${1?'Path or command to remove must be specified'}
  local path=${2:-${PATH}}
  if [[ "${path_or_cmd_to_remove}" != /* ]] && [[ "${path_or_cmd_to_remove}" == *"/"* ]]; then
    echo "Relative paths are not allowed"
    return 1
  fi

  if [[ "${path_or_cmd_to_remove}" == /* ]]; then
    # Absolute path to a command or directory, remove the directory and return
    _remove_path "${path_or_cmd_to_remove}" "${path}" path
    echo "${path}"
    return
  fi

  # It's a command, resolve its path(s) and remove their directories from the path
  local path_to_remove="${path_or_cmd_to_remove}"
  local path_to_cmd

  while path_to_cmd=$(PATH=${path} command -v "${path_or_cmd_to_remove}"); do
    # We can resolve the command
    # Use parameter expansion to get the folder portion of the command
    path_to_remove=${path_to_cmd%/*}
    _remove_path "${path_to_remove}" "${path}" path
  done
  echo "${path}"
}

_remove_path() {
  local path_to_remove="${1?'Path to remove must be specified'}"
  local input_path="${2?'Path list must be specified'}"
  local output_var_name="${3?'Output variable name must be specified'}"
  # Wrap the path with colons to simplify removal
  local updated_path=":${input_path}:"
  # Remove trailing slashes from the path entries
  updated_path=${updated_path//"/:"/":"}
  # In case PATH contained / as a standalone entry we have a double colon, reinsert it again
  updated_path=${updated_path//"::"/":/:"}
  # Replace single colons with double colons for easier string substitution
  updated_path=${updated_path//":"/"::"}
  # Remove the path
  updated_path=${updated_path//":${path_to_remove}:"/}
  # Restore single colons
  updated_path=${updated_path//"::"/":"}
  # Clean up leading/trailing colons
  updated_path=${updated_path#:}
  updated_path=${updated_path%:}
  printf -v "${output_var_name}" '%s' "${updated_path}"
}

# Returns a path to directory populated with symbolic links to basic commands
# Globals:
#   BATS_TEST_TMPDIR
# Arguments:
#   1: List of commands to be added to the directory, optional
# Returns:
#   1: If one of the commands provided in the argument can't be found
# Outputs:
#   STDOUT: Path to the directory
#   STDERR: Corresponding error message
mock_bin_dir() {
  local commands=("$@")
  local bin_dir=${BATS_TEST_TMPDIR}
  local customized=true

  if [[ ${#commands[@]} -eq 0 ]]; then
    customized=false
    commands=(awk basename bash cat chmod chown cp cut date env
      dirname getopt grep head id find hostname ln ls mkdir
      mktemp mv pidof readlink rm rmdir sed sh sleep sort
      split tail tee tempfile touch tr tty uname uniq unlink
      wc which xargs)
  fi

  local c target error_msg
  for c in "${commands[@]}"; do
    if target=$(command -v "$c" 2>&1); then
      # Use 'command -p' to assure ln is found, since '/bin' or '/usr/bin' may be not in $PATH anymore.
      if ! error_msg=$(command -p ln -s "${target}" "${bin_dir}/${c}" 2>&1) && ${customized}; then
        echo "${error_msg}"
        return 1
      fi
    elif ${customized}; then
      printf "%s: command not found" "$c"
      return 1
    fi
  done
  echo "${bin_dir}"
}
