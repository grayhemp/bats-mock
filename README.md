# bats-mock

> NOTE: 
>
> This is a temporary fork of https://github.com/grayhemp/bats-mock and will be removed in case the changes are merged.

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

  # Execute the shell script under test
  # Make sure the path to the mock precedes system provided commands.
  PATH=$(path_override "${mock_wget}") run install-fancy-app.sh

  [[ "${status}" -eq 0 ]]
  [[ "$(mock_get_call_num ${mock_wget})" -eq 1 ]]
  [[ "$(mock_get_call_args "${mock_wget}")" =~ "-O fancy-app https://example.org/fancy-app.js" ]]
}
```

Following our example above, lets assume `install-fancy-app` tries to use
`wget` as fallback if `curl` is not installed. This behavior could not be
tested on a system with installed `curl`.

`mock_chroot` with `path_rm` and `path_override` may be used to provide a
deterministic test setup, regardless of the installed commands.

```bash
load bats-mock

@test "fallback to wget if curl is not installed" {
  # Mock wget to avoid downloading the file. The mock is placed in the same
  # directory with the commands provided by 'mock_chroot'.
  mock_wget="$(mock_create wget)"

  # Create a PATH so that system installed commands are not found.
  # `curl` is found via `/usr/bin` and `/bin`, so create a PATH without those directories.
  path_to_mock_chroot=$(path_override $(mock_chroot) $(path_rm /bin $(path_rm /usr/bin)))

  # Execute the shell script under test
  PATH="${path_to_mock_chroot}" run install-fancy-app.sh

  [[ "${status}" -eq 0 ]]
  [[ "$(mock_get_call_num ${mock_wget})" -eq 1 ]]
  [[ "$(mock_get_call_args "${mock_wget}")" =~ "-O fancy-app https://example.org/fancy-app.js" ]]
}
```

## Installation

```bash
./build install
```

Optionally accepts `PREFIX` and `LIBDIR` envs.

If you use the `git submodule` setup as described in the [bats-core quick installation guide](https://bats-core.readthedocs.io/en/stable/tutorial.html#quick-installation)

```bash
# From your git project root
git submodule add https://github.com/mh182/bats-mock.git test/test_helper/bats-mock
```

## Usage

### `mock_create`

```bash
mock_create [<command>]
```

Creates a mock program with a unique name in `BATS_TMPDIR` and outputs its path.

The mock tracks calls and collects their properties. The collected data is
accessible using methods described below.

If `command` is provided a symbolic link with the given name is created and returned.
The links is created in the same directory as the one created by `mock_chroot`.

> **NOTE**  
> `mock_create <command>` and `path_override` may be used to supply custom
> executables for your tests.
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

### `mock_chroot`

```bash
mock_chroot [cmd ...]
```

Creates a directory in `BATS_TMPDIR` containing the most basic commands found
on a system and outputs its path. The commands are symbolic links to the system
provided programs.

A list of space separated commands may be provided to define a more strict set
of commands.

`mock_create <command>` puts the mocked command in the same directory as the
directory provided with `mock_chroot`.

### `path_override`

```bash
path_override <mock | command | path_to_add> [path]
```

Outputs `$PATH` prefixed with the mocked command's directory. If the directory
is already part of `$PATH` nothing is done.

Works regardless if the provided mock is a file, link or a directory.

Use `path` instead of `$PATH` if specified.

### `path_rm`

```bash
path_rm <command | path_to_remove> [path]
```

Outputs `$PATH` where the directory of the given command or path is removed.

Use `path` instead of `$PATH` if specified.

## Testing

```bash
./build test
```

Requires [Bats][bats-core] to be installed and in `PATH`.

Optionally accepts the `BINDIR` env.

<!-- Links -->

[bats-core]: https://github.com/bats-core/bats-core
