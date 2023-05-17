#!/usr/bin/env bats

set -euo pipefail

load ../src/bats-mock

teardown() {
    rm -rf "${BATS_TMPDIR}"/bats-mock.$$.*
}

@test 'mock_chroot without argument creates directory with minimal set of commands' {
  run mock_chroot
  [[ "${status}" -eq 0 ]]
  [[ -x "${output}/awk" ]]
  [[ -x "${output}/basename" ]]
  [[ -x "${output}/bash" ]]
  [[ -x "${output}/cat" ]]
  [[ -x "${output}/chmod" ]]
  [[ -x "${output}/chown" ]]
  [[ -x "${output}/cp" ]]
  [[ -x "${output}/cut" ]]
  [[ -x "${output}/date" ]]
  [[ -x "${output}/env" ]]
  [[ -x "${output}/dirname" ]]
  [[ -x "${output}/getopt" ]]
  [[ -x "${output}/grep" ]]
  [[ -x "${output}/head" ]]
  [[ -x "${output}/id" ]]
  [[ -x "${output}/find" ]]
  [[ -x "${output}/hostname" ]]
  [[ -x "${output}/ln" ]]
  [[ -x "${output}/ls" ]]
  [[ -x "${output}/mkdir" ]]
  [[ -x "${output}/mktemp" ]]
  [[ -x "${output}/mv" ]]
  [[ -x "${output}/pidof" ]]
  [[ -x "${output}/readlink" ]]
  [[ -x "${output}/rm" ]]
  [[ -x "${output}/rmdir" ]]
  [[ -x "${output}/sed" ]]
  [[ -x "${output}/sh" ]]
  [[ -x "${output}/sleep" ]]
  [[ -x "${output}/sort" ]]
  [[ -x "${output}/split" ]]
  [[ -x "${output}/tail" ]]
  [[ -x "${output}/tee" ]]
  [[ -x "${output}/tempfile" ]]
  [[ -x "${output}/touch" ]]
  [[ -x "${output}/tty" ]]
  [[ -x "${output}/uname" ]]
  [[ -x "${output}/uniq" ]]
  [[ -x "${output}/unlink" ]]
  [[ -x "${output}/wc" ]]
  [[ -x "${output}/which" ]]
  [[ -x "${output}/xargs" ]]
  [[ $(find "${output}" -type l | wc -l) -eq 43 ]]
}

@test 'mock_chroot skips command if command not found' {
  # Provide empty PATH to make sure none of the basic system commands can be found
  PATH="" run mock_chroot
  [[ "${status}" -eq 0 ]]
  [[ $(find "${output}" -type l | wc -l) -eq 0 ]]
}

@test 'mock_chroot is idempotent' {
  run mock_chroot
  [[ "${status}" -eq 0 ]]
  run mock_chroot
  [[ "${status}" -eq 0 ]]
  [[ $(find "${output}" -type l | wc -l) -eq 43 ]]
}

@test 'mock_chroot and mock_create command use same directory' {
  run mock_create wget
  [[ "${status}" -eq 0 ]]
  mock_wget="${output}"
  run mock_chroot
  [[ "${status}" -eq 0 ]]
  [[ $(dirname "${mock_wget}") == "${output}" ]]
}

@test 'mock_chroot does not overwrite existing mock command' {
  run mock_create cat
  [[ "${status}" -eq 0 ]]
  mock_cat="${output}"
  run mock_chroot
  [[ "${status}" -eq 0 ]]
  echo "$(readlink "${mock_cat}")"
  [[ $(readlink "${mock_cat}") =~ ${BATS_TMPDIR}/bats-mock.$$. ]]
}

@test 'mock_chroot with defined set of commands' {
  run mock_chroot cat cut ls
  [[ "${status}" -eq 0 ]]
  echo "Comands in chroot: $(find "${output}" -type l | wc -l)"
  [[ $(find "${output}" -type l | wc -l) -eq 3 ]]
}

@test 'mock_chroot with defined set of commands fails if command not found' {
  run mock_chroot cat foo cut ls
  [[ "${status}" -eq 1 ]]
  echo "Output: [${output}]"
  [[ "${output}" == "foo: command not found" ]]
}

@test 'mock_chroot with defined set of commands fails on existing mock command' {
  run mock_create cat
  [[ "${status}" -eq 0 ]]
  mock_cat="${output}"
  LC_ALL=C run mock_chroot ls cat head
  [[ "${status}" -eq 1 ]]
  echo "Output: [${output}]"
  [[ "${output}" == "ln: failed to create symbolic link '${BATS_TMPDIR}/bats-mock.$$.bin/cat': File exists" ]]
}
