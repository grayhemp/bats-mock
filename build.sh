#!/usr/bin/env bash
#
# Build

set -ex

: ${PREFIX:=/usr/local/libexec}

build::install() {
  install -d "${PREFIX}"
  install src/bats-mock.bash "${PREFIX}"
}

build::test() {
  PREFIX=test/test_helper build::install
  bats --tap test
}

main() {
  build::"$@"
}

main "${@?}"
