#!/usr/bin/env bash

set -euo pipefail

load ../src/bats-mock

setup() {
  mock="$(mock_create)"
}

teardown() {
  rm "${mock}"*
}
