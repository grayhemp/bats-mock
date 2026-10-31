# bats-mock

![Github Release](https://img.shields.io/github/v/release/mh182/bats-mock)
[![Tests](https://github.com/mh182/bats-mock/actions/workflows/tests.yml/badge.svg)](https://github.com/mh182/bats-mock/actions/workflows/tests.yml)
[![GitHub Actions Security Analysis with zizmor](https://github.com/mh182/bats-mock/actions/workflows/zizmor.yml/badge.svg)](https://github.com/mh182/bats-mock/actions/workflows/zizmor.yml)

A [Bats][bats-core] helper library providing mocking functionality.

```bash
bats_load_library bats-mock

@test "postgres.sh starts Postgres" {
  mock="$(mock_create)"
  mock_set_side_effect "${mock}" "echo $$ > /tmp/postgres_started"

  # Assuming postgres.sh expects the `_POSTGRES` variable to define a
  # path to the `postgres` executable
  _POSTGRES="${mock}" run postgres.sh

  [[ "${status}" -eq 0 ]]
  [[ "$(mock_get_call_num ${mock})" -eq 1 ]]
  [[ "$(mock_get_call_user ${mock})" == 'postgres' ]]
  [[ "$(mock_get_call_args ${mock})" =~ -D\ /var/lib/postgresql ]]
  [[ "$(mock_get_call_env ${mock} PGPORT)" -eq 5432 ]]
  [[ "$(cat /tmp/postgres_started)" -eq "$$" ]]
}
```

For changes and version history see [CHANGELOG](CHANGELOG.md).

## Table of contents

- [Tutorial](Tutorial.md)
- [Installation](#installation)
  - [Installation as a container image](#installation-as-a-container-image)
  - [Installation as a Git submodule](#installation-as-a-git-submodule)
  - [Installation into the Bats library path](#installation-into-the-bats-library-path)
- [Usage](#usage)
  - [Minimal test file example](#minimal-test-file-example)
  - Mock generation [`mock_create`](#mock_create)
  - Mock customization [`mock_set_status`](#mock_set_status), [`mock_set_output`](#mock_set_output), and
    [`mock_set_side_effect`](#mock_set_side_effect)
  - Mock observation [`mock_get_call_num`](#mock_get_call_num), [`mock_get_call_user`](#mock_get_call_user),
    [`mock_get_call_args`](#mock_get_call_args), and [`mock_get_call_env`](#mock_get_call_env)
  - Path utilities [`path_prepend`](#path_prepend), [`path_rm`](#path_rm)
  - Mock environment [`mock_bin_dir`](#mock_bin_dir)
- [Contributing](#contributing)
- [About this fork](#about-this-fork)

## Tutorial

The full tutorial is available in [Tutorial.md](Tutorial.md).

## Installation

You can use **bats-mock** in the following ways,
depending on how you organize your Bats tests:

1. Using a container image based on the official `bats/bats` image
2. As a Git submodule (project-local installation)
3. Installed into your system or user Bats library path

The latter two approaches require [Bats Core](https://github.com/bats-core/bats-core)
to be installed and available in your `PATH`.

### Installation as a container image

This repository includes a `Containerfile` that extends the official
[`bats/bats`](https://hub.docker.com/r/bats/bats) image and installs
`bats-mock` into the Bats library path.

Build the image with Docker:

```sh
git clone https://github.com/mh182/bats-mock.git
(cd bats-mock && docker build -f Containerfile -t bats-mock:latest .)
rm -rf bats-mock
```

Run your tests from the project directory with Docker:

```sh
# Assuming your tests are located in the directory 'test'
docker run --rm -it -v "$PWD:/code" -w /code bats-mock:latest test
```

Inside this image, `bats-mock` is available for `bats_load_library`.

```sh
# At the beginning of your test files
bats_load_library bats-mock
```

For additional runtime options and Docker usage patterns,
see the [Docker Usage Guide](https://bats-core.readthedocs.io/en/stable/docker-usage.html)
in the official Bats documentation.

### Installation as a Git submodule

This is the most common setup
when `bats-mock` is used within a project repository as `git submodule`
and described in the [bats-core quick installation guide](https://bats-core.readthedocs.io/en/stable/tutorial.html#quick-installation).
It keeps the dependency version-controlled and local to your project.

```sh
# From your project root
mkdir -p test/test_helper
git submodule add https://github.com/mh182/bats-mock.git test/test_helper/bats-mock
```

Export `BATS_LIB_PATH` so it points to the directory
where the Bats libraries are located;
otherwise, `bats_load_library` will not find `bats-mock`.

```sh
# From your project root
export BATS_LIB_PATH=$PWD/test/test_helper
```

### Installation into the Bats library path

If you prefer to have bats-mock available globally
for all Bats tests on your system or CI environment,
you can install it into the Bats library path.

First, clone the repository:

```sh
git clone https://github.com/mh182/bats-mock.git
cd bats-mock
```

Then, install [Bats][bats-core] if it's not already available:

```sh
# Install bats-core in /usr/local (may require sudo)
./script/install_bats

# Install bats-mock in /usr/local/lib
./build install
```

> **Note**: You may need to run `install_bats` with `sudo`
> if you do not have permission to write to `/usr/local`.

You can also install both Bats Core
and bats-mock under a custom prefix (e.g., `$HOME/.local`):

```sh
# Install bats in $HOME/.local/bin
PREFIX=$HOME/.local ./script/install_bats

# Install bats-mock in $HOME/.local/lib
PREFIX=$HOME/.local ./build install
```

Finally, make sure `BATS_LIB_PATH` points to the directory
where the Bats libraries are located.  
Following our example above:

```sh
export BATS_LIB_PATH=$HOME/.local/lib
```

Now your tests can simply load the library by name:

```bash
bats_load_library bats-mock

@test "Create a simple mock object" {
  mock=$(mock_create)

  ${mock}

  [[ $(mock_get_call_num "${mock}") -eq 1 ]]
}
```

## Usage

### Minimal Test File Example

Here is an example of a typical test file using `bats-mock`.
For a more detailed introduction on how to use `bats-mock`,
refer to the [bats-mock tutorial](Tutorial.md).

```bash
# Load Bats Mock library for mocking commands
bats_load_library bats-mock

setup() {
  # Get the containing directory of this file. Use $BATS_TEST_FILENAME instead
  # of ${BASH_SOURCE[0]} or $0, as those will point to the bats executable's
  # location or the preprocessed file respectively.
  DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" >/dev/null 2>&1 && pwd)"
  # Make executables in src/ visible to PATH
  PATH=$(path_prepend "${DIR}/../src")

  # Set the path to mocked binaries directory as the first location in PATH to
  # lookup in mock directories first. This change lives only for the duration of
  # the test and will be reset after. It does not modify the PATH outside of the
  # running test.
  PATH=$(path_prepend "${BATS_TEST_TMPDIR}")
}

@test "Example test with mock" {
  # Mock call to wget
  mock_wget="$(mock_create wget)"

  # Run a shell script which uses wget
}
```

### `mock_create`

```bash
mock_create [<command>]
```

Creates a mock program with a unique name in `BATS_TEST_TMPDIR`
and outputs its path.
The mock tracks calls and collects their properties.
The collected data is accessible using methods described below.

If `command` is provided, a symbolic link with the given name is created
and returned.

> **NOTE**  
> The [Minimal test file example](#minimal-test-file-example) shows how
> combining `mock_command` and `path_prepend` may be used
> to supply custom executables for your tests.
>
> It is self-explanatory that this approach doesn't work for shell scripts
> with commands having hard-coded absolute paths.

```bash
setup() {
  # Set the path to mocked binaries directory as the first location in PATH to
  # lookup in mock directories first. This change lives only for the duration of
  # the test and will be reset after. It does not modify the PATH outside of the
  # running test.
  PATH=$(path_prepend "${BATS_TEST_TMPDIR}")

  # NOTE: no cleanup since all mocks are created in ${BATS_TEST_TMPDIR}
}

@test "mock call to wget" {
  mock=$(mock_create wget)

  # Calls the mock instead of the system installed wget
  wget
  [[ $(mock_get_call_num "${mock}") -eq 1 ]]
}
```

### `path_prepend`

```bash
path_prepend <mock | command | path_to_add> [path]
```

Outputs `$PATH` prefixed with the mocked command's directory.
If the directory is already part of `$PATH` nothing is done.

Works regardless of whether the provided mock is a file, link, or directory.

Use `path` instead of `$PATH` if specified.

Example:

```bash
@test "prepend directory containing a mock" {
  mock_ls=$(mock_create ls)

  new_path=$(path_prepend "${mock_ls}")
  [[ "${new_path}" == "$(dirname "${mock_ls}")":* ]]
}
```

### `path_rm`

```bash
path_rm <command | path_to_remove> [path]
```

Outputs `$PATH` with directories removed
that contain the specified command or path.

- If a command name is provided,
  all directories in which that command can be found are removed.
- If an absolute path to the command is provided (e.g. `/usr/bin/ls`),
  only the directory containing that executable (e.g. `/usr/bin`) is removed.
- If an absolute path is provided, the given path is removed.

Use `path` instead of `$PATH` if specified.

If a relative path is provided, the function exits with an error.

Example:

```bash
@test "remove command directory from PATH" {
  # Same as $(path_rm /usr/bin)
  cleaned_path=$(path_rm /usr/bin/ls)

  # ls is still available via '/bin/ls'
  PATH="${cleaned_path}" run which ls 
  [[ "${output}" == "/bin/ls" ]]

  # Removed all paths to 'ls'
  cleaned_path=$(path_rm ls)

  # Command not found
  PATH="${cleaned_path}" run -127 ls 
}
```

### `mock_set_status`

```bash
mock_set_status <mock> <status> [<n>]
```

Sets the exit status of the mock.

`0` status is set by default when mock is created.

If `n` is specified, the status will be returned on the `n`-th call.
The call indexing starts with `1`.
Multiple invocations can be used to mimic complex status sequences.

Example:

```bash
@test "return different statuses per call" {
  mock=$(mock_create)
  mock_set_status "${mock}" 22 1
  mock_set_status "${mock}" 0 2

  run -22 "${mock}"
  run -0 "${mock}"
}
```

### `mock_set_output`

```bash
mock_set_output <mock> (<output>|-) [<n>]
```

Sets the output of the mock. The mock outputs nothing by default.

If the output is specified as `-`, it is read from `STDIN`.

The optional `n` argument behaves similarly to the one in `mock_set_status`.

Example:

```bash
@test "emit configured output" {
  mock_cat=$(mock_create cat)
  mock_set_output "${mock_cat}" "hello from mock"

  run cat
  [[ "${output}" == "hello from mock" ]]
}
```

### `mock_set_side_effect`

```bash
mock_set_side_effect <mock> (<side_effect>|-) [<n>]
```

Sets the side effect of the mock. The side effect is Bash code to be
sourced by the mock when it is called.

No side effect is set by default.

If the side effect is specified as `-`, it is read from `STDIN`.

The optional `n` argument behaves similarly to the one in `mock_set_status`.

Example:

```bash
@test "execute side effect code" {
  mock_wget=$(mock_create wget)
  mock_set_side_effect "${mock_wget}" 'echo done > "${BATS_TEST_TMPDIR}/download.status"'

  "${mock_wget}"
  [[ -f "${BATS_TEST_TMPDIR}/download.status" ]]
}
```

### `mock_get_call_num`

```bash
mock_get_call_num <mock>
```

Returns the number of times the mock was called.

Example:

```bash
@test "count mock calls" {
  mock=$(mock_create)
  "${mock}"
  "${mock}"
  [[ "$(mock_get_call_num "${mock}")" -eq 2 ]]
}
```

### `mock_get_call_user`

```bash
mock_get_call_user <mock> [<n>]
```

Returns the user the mock was called as on the `n`-th call.
If no `n` is specified, the last call is assumed.

It requires the mock to be called at least once.

Example:

```bash
@test "inspect user used for call" {
  mock=$(mock_create)
  "${mock}"
  [[ "$(mock_get_call_user "${mock_id}")" == $USER ]]
}
```

### `mock_get_call_args`

```bash
mock_get_call_args <mock> [<n>]
```

Returns the argument list the mock was called with on the `n`-th call.
If no `n` is specified, the last call is assumed.

It requires the mock to be called at least once.

Example:

```bash
@test "inspect arguments of a call" {
  mock_cp=$(mock_create cp)

  cp source.txt target.txt
  [[ "$(mock_get_call_args "${mock_cp}")" == "source.txt target.txt" ]]
}
```

### `mock_get_call_env`

```bash
mock_get_call_env <mock> <variable> [<n>]
```

Returns the value of the environment variable the mock was called
with on the `n`-th call.
If no `n` is specified, the last call is assumed.

It requires the mock to be called at least once.

Example:

```bash
setup() {
}

@test "inspect environment variable of a call" {
  mock=$(mock_create)
  FOO=bar "${mock}"
  [[ "$(mock_get_call_env "${mock}" FOO)" == "bar" ]]
}
```

### `mock_bin_dir`

```bash
mock_bin_dir [cmd...]
```

Creates a directory containing the most basic commands found on a system
and outputs its path.
The commands are symbolic links to the system provided programs.
A list of space-separated commands may be provided
to define a stricter set of commands.
Any command created using `mock_create <command>`
will be placed inside the directory produced by `mock_bin_dir`,
ensuring that your mocked commands override the linked system commands.

Example:

```bash
setup() {
  pristine_bin=$(mock_bin_dir basename dirname)
}

@test "create deterministic command set" {
  PATH=$(path_prepend "${pristine_bin}" "")
  run basename /tmp/file.txt
  [[ "${output}" == "file.txt" ]]
}
```

`mock_bin_dir` with `path_rm` and `path_prepend` may be used in tests
to mock a pristine system.

```bash
bats_load_library bats-mock

@test "no HTTP download program installed shows error message" {
 # Mock a system where neither curl, wget, nor fetch is installed
 mock_pristine_system=$(mock_bin_dir)

 # Create a PATH so that system installed commands are not found
 path=$(path_prepend "${mock_pristine_system}" $(path_rm /bin $(path_rm /usr/bin)))

 # Execute the shell script under test
 # Provide the created PATH so we mock a pristine system with no download commands installed
 PATH="${path}" run install-fancy-app.sh

 [[ "${status}" -eq 1 ]]
 [[ "${output}" == "Error: couldn't find HTTP download program"]]
}
```

## Contributing

If you want to contribute to this project
check out [Contributing](CONTRIBUTING.md).

## About this fork

This repository is a **maintained fork** of
[grayhemp/bats-mock](https://github.com/grayhemp/bats-mock) at commit [48fce74](https://github.com/grayhemp/bats-mock/commit/48fce74482a4d2bb879b904ccab31b6bc98e3224).
The original project appears to be **unmaintained** —
the last commit was made over four years ago at the time of forking.

This fork was created to:

- Maintain compatibility with newer versions of [Bats](https://github.com/bats-core/bats-core)
- Apply fixes and quality improvements as needed
- Ensure continued availability for projects that depend on `bats-mock`

We highly appreciate the original author’s work
and intend to **reintegrate changes upstream**
if the original repository becomes active again.  
This fork’s goal is to preserve and maintain the library for the community,
not to diverge unnecessarily.

## Copyright

bats-mock is [public domain](https://en.wikipedia.org/wiki/Public_Domain).
For more information, please refer to <https://unlicense.org/>.

<!-- Links -->

[bats-core]: https://github.com/bats-core/bats-core
