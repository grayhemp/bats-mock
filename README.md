# bats-mock

[![Build Status](https://travis-ci.org/grayhemp/bats-mock.svg?branch=master)](https://travis-ci.org/grayhemp/bats-mock)

A [Bats][bats-core] helper library providing mocking functionality.

```bash
load bats-mock

@test "postgres.sh starts Postgres" {
  mock="$(mock_create)"
  mock_set_side_effect "${mock}" "echo $$ > /tmp/postgres_started"

  # Assuming postgres.sh expects the `_POSTGRES` variable to define a
  # path to the `postgres` executable
  _POSTGRES="${mock}" run postgres.sh

  [[ "${status}" -eq 0 ]]
  [[ "$(mock_get_call_num ${mock})" -eq 1 ]]
  [[ "$(mock_get_call_user ${mock})" = 'postgres' ]]
  [[ "$(mock_get_call_args ${mock})" =~ -D\ /var/lib/postgresql ]]
  [[ "$(mock_get_call_env ${mock} PGPORT)" -eq 5432 ]]
  [[ "$(cat /tmp/postgres_started)" -eq "$$" ]]
}
```

Mock calls to commands by overriding the `PATH` variable.

```bash
load bats-mock

@test "download with wget" {
  # Mock wget to avoid downloading the file
  mock_wget="$(mock_create wget)"

  # Execute the shell script under test.
  # Make sure the path to the mock precedes system provided commands.
  PATH="$(dirname "${mock_wget}"):$PATH" run install-fancy-app.sh

  [[ "${status}" -eq 0 ]]
  [[ "$(mock_get_call_num ${mock_wget})" -eq 1 ]]
  [[ "$(mock_get_call_args ${mock_wget})" =~ "-O fancy-app https://example.org/fancy-app" ]]
}
```

## Installation

```bash
./build install
```

Optionally accepts `PREFIX` and `LIBDIR` envs.

## Usage

### `mock_create`

```bash
mock_create [<command>]
```

Creates a mock program with a unique name in `BATS_TMPDIR` and outputs its path.
If `command` is provided a symbolic link with the given name is created and
returned.

The mock tracks calls and collects their properties. The collected data is
accessible using methods described below.

> **NOTE**  
> `mock_create command` with overriding the `PATH` variable may be used to supply
> custom executables for your tests.
>
> It is self-explanatory that this approach doesn't work for shell scripts with
> commands having hard-coded absolute paths.

### `mock_set_status`

```bash
mock_set_status <mock> <status> [<n>]
```

Sets the exit status of the mock.

`0` status is set by default when mock is created.

If `n` is specified the status will be returned on the `n`-th
call. The call indexing starts with `1`. Multiple invocations can be
used to mimic complex status sequences.

### `mock_set_output`

```bash
mock_set_output <mock> (<output>|-) [<n>]
```

Sets the output of the mock.

The mock outputs nothing by default.

If the output is specified as `-` then it is going to be read from
`STDIN`.

The optional `n` argument behaves similarly to the one of `mock_set_status`.

### `mock_set_side_effect`

```bash
mock_set_side_effect <mock> (<side_effect>|-) [<n>]
```

Sets the side effect of the mock. The side effect is a bash code to be
sourced by the mock when it is called.

No side effect is set by default.

If the side effect is specified as `-` then it is going to be read
from `STDIN`.

The optional `n` argument behaves similarly to the one of `mock_set_status`.

### `mock_get_call_num`

```bash
mock_get_call_num <mock>
```

Returns the number of times the mock was called.

### `mock_get_call_user`

```bash
mock_get_call_user <mock> [<n>]
```

Returns the user the mock was called with the `n`-th time. If no `n`
is specified then assuming the last call.

It requires the mock to be called at least once.

### `mock_get_call_args`

```bash
mock_get_call_args <mock> [<n>]
```

Returns the arguments line the mock was called with the `n`-th
time. If no `n` is specified then assuming the last call.

It requires the mock to be called at least once.

### `mock_get_call_env`

```bash
mock_get_call_env <mock> <variable> [<n>]
```

Returns the value of the environment variable the mock was called with
the `n`-th time. If no `n` is specified then assuming the last call.

It requires the mock to be called at least once.


## Testing

```bash
./build test
```

Requires [Bats][bats-core] to be installed and in `PATH`.

Optionally accepts the `BINDIR` env.

<!-- Links -->

[bats-core]: https://github.com/bats-core/bats-core
