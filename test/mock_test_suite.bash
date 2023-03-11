#!/usr/bin/env bash

set -euo pipefail

load ../src/bats-mock

setup() {
  bats_require_minimum_version 1.5.0
  mock="$(mock_create)"
}

teardown() {
  rm "${mock}"*
}
