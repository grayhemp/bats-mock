<!-- omit in toc -->

# Contributing to [bats-mock](README.md)

First off, thanks for taking the time to contribute! ❤️

All types of contributions are encouraged and valued.
See the [Table of Contents](#table-of-contents) for different ways to help
and details about how this project handles them.
Please make sure to read the relevant section before making your contribution.
It will make it a lot easier for us maintainers
and smooth out the experience for all involved.
The community looks forward to your contributions. 🎉

> And if you like the project,
> but just don't have time to contribute, that's fine.
> There are other easy ways to support the project and show your appreciation,
> which we would also be very happy about:
>
> - Star the project
> - Tweet about it
> - Refer this project in your project's readme

<!-- omit in toc -->

## Table of contents

- [Code of conduct](#code-of-conduct)
- [I have a question](#i-have-a-question)
  - [I want to contribute](#i-want-to-contribute)
  - [Reporting bugs](#reporting-bugs)
  - [Suggesting enhancements](#suggesting-enhancements)
  - [Your first code contribution](#your-first-code-contribution)
  - [Improving the documentation](#improving-the-documentation)
- [Branching and merging strategy](#branching-and-merging-strategy)
  - [Branch Types](#branch-types)
  - [Pull Requests](#pull-requests)
- [Styleguides](#styleguides)
  - [Coding conventions](#coding-conventions)
  - [Commit messages](#commit-messages)
- [Release management](#release-management)
  - [Release bats-mock](#release-bats-mock)
  - [Release a devcontainer image](#release-a-devcontainer-image)

## Code of conduct

This project and everyone participating in it is governed by the
[bats-mock Code of Conduct](CODE_OF_CONDUCT.md).
By participating, you are expected to uphold this code.
Please report unacceptable behavior to [mh182](https://github.com/mh182).

## I have a question

> If you want to ask a question, we assume that you have read the available [Documentation](README.md).

Before you ask a question,
it is best to search for existing [Issues](https://github.com/mh182/bats-mock/issues) that might help you.
In case you have found a suitable issue and still need clarification,
you can write your question in this issue.
It is also advisable to search the internet for answers first.

If you then still feel the need to ask a question and need clarification,
we recommend the following:

- Open an [Issue](https://github.com/mh182/bats-mock/issues/new).
- Provide as much context as you can about what you're running into.
- Provide project and platform versions (nodejs, npm, etc),
  depending on what seems relevant.

We will then take care of the issue as soon as possible.

## I want to contribute

> ### Legal notice <!-- omit in toc -->
>
> When contributing to this project,
> you must agree that you have authored 100% of the content,
> that you have the necessary rights to the content
> and that the content you contribute may be provided under the project licence.

### Reporting bugs

<!-- omit in toc -->

#### Before submitting a bug report

A good bug report shouldn't leave others needing
to chase you up for more information.
Therefore, we ask you to investigate carefully, collect information
and describe the issue in detail in your report.
Please complete the following steps in advance
to help us fix any potential bug as fast as possible.

- Make sure that you are using the latest version.
- Determine if your bug is really a bug and not an error on your side
  e.g. using incompatible environment components/versions
  (Make sure that you have read the [documentation](README.md).
  If you are looking for support, you might want to check [this section](#i-have-a-question)).
- To see if other users have experienced
  (and potentially already solved) the same issue you are having,
  check if there is not already a bug report existing for your bug
  or error in the [bug tracker](https://github.com/mh182/bats-mock/issues?q=label%3Abug).
- Also make sure to search the internet (including Stack Overflow) to see
  if users outside of the GitHub community have discussed the issue.
- Collect information about the bug:
  - Stack trace (Traceback)
  - OS, Platform and Version (Windows, Linux, macOS, x86, ARM)
  - Version of the interpreter, compiler, SDK, runtime environment,
    package manager, depending on what seems relevant.
  - Possibly your input and the output
  - Can you reliably reproduce the issue?
    And can you also reproduce it with older versions?

<!-- omit in toc -->

#### How do I submit a good bug report?

> You must never report security related issues, vulnerabilities or bugs
> including sensitive information to the issue tracker, or elsewhere in public.
> Instead sensitive bugs must be sent by email to <>.

<!-- You may add a PGP key to allow the messages to be sent encrypted as well. -->

We use GitHub issues to track bugs and errors.
If you run into an issue with the project:

- Open an [Issue](https://github.com/mh182/bats-mock/issues/new).
  (Since we can't be sure at this point whether it is a bug or not,
  we ask you not to talk about a bug yet and not to label the issue.)
- Explain the behavior you would expect and the actual behavior.
- Please provide as much context as possible
  and describe the _reproduction steps_ that someone else can follow
  to recreate the issue on their own.
  This usually includes your code.
  For good bug reports you should isolate the problem
  and create a reduced test case.
- Provide the information you collected in the previous section.

Once it's filed:

- The project team will label the issue accordingly.
- A team member will try to reproduce the issue with your provided steps.
  If there are no reproduction steps or no obvious way to reproduce the issue,
  the team will ask you for those steps and mark the issue as `needs-repro`.
  Bugs with the `needs-repro` tag will not be addressed
  until they are reproduced.
- If the team is able to reproduce the issue, it will be marked `needs-fix`,
  as well as possibly other tags (such as `critical`),
  and the issue will be left to be [implemented by someone](#your-first-code-contribution).

<!-- You might want to create an issue template for bugs and errors that can be used as a guide and that defines the structure of the information to be included. If you do so, reference it here in the description. -->

### Suggesting enhancements

This section guides you through submitting an enhancement suggestion,
**including completely new features
and minor improvements to existing functionality**.
Following these guidelines will help maintainers and the community
to understand your suggestion and find related suggestions.

<!-- omit in toc -->

#### Before submitting an enhancement

- Make sure that you are using the latest version.
- Read the [documentation](README.md) carefully
  and find out if the functionality is already covered,
  maybe by an individual configuration.
- Perform a [search](https://github.com/mh182/bats-mock/issues) to see
  if the enhancement has already been suggested.
  If it has, add a comment to the existing issue instead of opening a new one.
- Find out whether your idea fits with the scope and aims of the project.
  It's up to you to make a strong case to convince the project's developers
  of the merits of this feature.
  Keep in mind that we want features that will be useful
  to the majority of our users and not just a small subset.
  If you're just targeting a minority of users,
  consider writing an add-on/plugin library.

<!-- omit in toc -->

#### How do I submit a good enhancement suggestion?

Enhancement suggestions are tracked as [GitHub issues](https://github.com/mh182/bats-mock/issues).

- Use a **clear and descriptive title** for the issue
  to identify the suggestion.
- Provide a **step-by-step description of the suggested enhancement**
  in as many details as possible.
- **Describe the current behavior** and
  **explain which behavior you expected to see instead** and why.
  At this point you can also tell which alternatives do not work for you.
- **Explain why this enhancement would be useful** to most bats-mock users.
  You may also want to point out the other projects that solved it better
  and which could serve as inspiration.

<!-- You might want to create an issue template for enhancement suggestions that can be used as a guide and that defines the structure of the information to be included. If you do so, reference it here in the description. -->

### Your first code contribution

<!-- TODO
include Setup of env, IDE and typical getting started instructions?
-->

Your development environment should provide the following tooling:

- [Bats][bats-core] to be installed and in `PATH`.
  Optionally accepts the `BINDIR` env to provide the location of `bats`.
- [codespell](https://github.com/codespell-project/codespell) to check spelling
- [lychee](https://github.com/lycheeverse/lychee) to check links in documentation
- [rumdl](https://github.com/rvben/rumdl) to format/check Markdown documentation
- [ShellCheck][shellcheck] for static code analysis
- [shfmt][shfmt] to format/check the style guide

The recommended way to set up a consistent development environment is
to use a container image.
This allows you to run quality checks and the test suite
in a fully isolated and reproducible environment.

This repository already provides a VS Code devcontainer configuration in
`.devcontainer/vscode/devcontainer.json`.
If you are using VS Code, follow the official guide to open and use a
devcontainer: <https://code.visualstudio.com/docs/devcontainers/containers>.

If you are using another editor and it supports devcontainers,
feel free to contribute an editor-specific `devcontainer.json` in
`.devcontainer/<editor>/devcontainer.json`.

Using an editor with devcontainer support is optional.
You can use the regular command line for all development tasks,
including building the container image and running checks.

To enable container-based development from the command line,
define the environment variable `BATS_MOCK_DEV_CONTAINER`
with the name of the image you want to build:

```bash
# Create a development container with all required tools
export BATS_MOCK_DEV_CONTAINER=bats-mock-dev
```

When `BATS_MOCK_DEV_CONTAINER` is set,
the first invocation of `./build` will automatically build the container image
using the `.devcontainer/Containerfile`.

```bash
# Run all tests
./build test

# Check style guide and static code analysis
./build check

# Check only style guide
./build check --style-only

# Check only static code analysis
./build check --analysis-only
```

You can also build the development image explicitly:

```bash
# Uses BATS_MOCK_DEV_CONTAINER as image name
./build image

# Uses the provided image name
./build image my-bats-mock-dev
```

If a test fails and you want to investigate the issue interactively,
you can start a shell inside the development container:

```bash
# Bind-mount the project root into /code inside the container
podman run -it --rm -v "$PWD:/code" --entrypoint /bin/bash $BATS_MOCK_DEV_CONTAINER
```

As an alternative for containers, use `script/install_bats install`
which will install `bats-core` in `/usr/local`.

> **Note**: You may need to run `install_bats` with `sudo`
> if you do not have permission to write to the installation prefix.

### Improving the documentation

Our documentation is written in **Markdown**
and follows the **Semantic Line Breaks** convention.
This approach places each sentence on its own line
and breaks lines at meaningful boundaries.
The goal is to make documentation easier to read, review,
and edit—especially in diffs and pull requests.

To learn more about this style, see:

- Semantic Line Breaking specification: [https://sembr.org/](https://sembr.org/)
- Rationale for one-sentence-per-line: [Semantic Linefeeds][semantic-linefeeds]

When contributing documentation:

- Use clear and concise Markdown.
- Apply semantic line breaks to all new or updated text.
- Keep lines short and break at natural semantic boundaries.
- Avoid hard-wrapping text purely for visual width.

This ensures consistent formatting and improves collaboration for everyone.

<!-- Links -->

[semantic-linefeeds]: https://rhodesmill.org/brandon/2012/one-sentence-per-line/

<!-- TODO:
Tools to check out:
- [dprint](https://dprint.dev/) a pluggable and configurable code formatting platform written in Rust.
-->

## Branching and merging strategy

This project follows a [**Trunk-Based Development**](https://trunkbaseddevelopment.com/) workflow.
The `main` branch is the single long-lived branch
and always reflects the latest stable state.

### Branch Types

<!-- omit in toc -->

#### **Main Branch**

- Long-lived branch: `main`
- Always stable and releasable
- All releases are created from `main`

<!-- omit in toc -->

#### **Feature Branches**

- Short-lived branches created for each change
- Must branch off from `main`
- **Must be rebased on top of the latest `main` before opening a pull request**
- We aim for a **linear commit history** (no merge commits)

### Pull Requests

- Every change must be submitted through a pull request
- Pull request titles must follow the Conventional Commits format
- Before opening or updating a pull request, run `./build check`.
  This is the same check command used in the CI pipeline.
- Pull requests require:
  - Successful CI checks
  - Review and approval by **at least one maintainer**
- Pull requests are merged **without merge commits**
  to keep the history linear (fast-forward or squash merges)

## Styleguides

### Coding conventions

Use the [bats coding conventions](https://github.com/bats-core/bats-core/blob/master/docs/CONTRIBUTING.md#coding-conventions).

Use [shfmt][shfmt] and [ShellCheck][shellcheck]. The CI will enforce this.

### Commit messages

Use [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) with the following structure:

```text
<type>(optional scope): <description>

[optional body]

[optional footer(s)]
```

The `<description>` must start with an uppercase letter.

The commit `type` can be:

- `feat`: Commits, which adds a new feature or new functionality
- `fix`: Commits, that fixes a bug
- `refactor`: Refactored code that neither fixes a bug nor adds a feature
  but rewrites/restructures your code.
- `perf`: Commits are special type of `refactor` commits
  that specifically improve performance
- `style`: Changes that do not affect the meaning of the code,
  likely related to code formatting such as white-space,
  missing semi-colons, etc.
- `test`: Commits that add missing tests or correct existing tests
- `docs`: Commits, that affect documentation, such as the README.
- `build`: Changes that affect the build system build tool, ci pipeline,
  dependencies, project version, …
- `chore`: Changes that do not relate to a fix or feature
  and don’t modify src or test files basically miscellaneous commits
  (for example, updating dependencies or modifying .gitignore file)
- `revert`: Reverts a previous commit.

The `scope` provides additional contextual information:

- The scope is an **optional part**
- **Do not** use issue identifiers as scope

A commit that has a footer `BREAKING CHANGE:`,
or appends a `!` after the type/scope in the subject line,
introduces a breaking API change
(correlating with MAJOR in Semantic Versioning).
A BREAKING CHANGE can be part of commits of any type.

Here some examples:

- `feat: Add optional command argument to mock_create`
- `feat(api): Add teardown_mock for easy cleanup of mock objects`
- `feat(api)!: Remove deprecated path_override`

Rules for creating a great commit message:

- Subject line:
  - Try to keep the subject line below 50 characters
  - Capitalize the subject/description line
  - Do not end the subject line with a period
  - **Use imperative mood in the subject line**:
    A common instinct when writing commit messages is
    to describe what you did in the **past tense**,
    e.g. "Fixed bugs and improved code".
    Another one is to describe the content of the commit,
    e.g. "bug fixes and code improvements".
    Instead, write the subject line as if **giving a command or instruction**,
    e.g. "Fix bugs and improve code".
    A simple rule of thumb is that the subject should complete the sentence
    "If applied, this commit will...".
    The resulting history will be more natural to read.
    Note that this primarily applies to the subject,
    the style of the body can be more flexible.
- Separate the subject from the body with a blank line
- Body:
  - Wrap the body at 72 characters
  - **Use the body to explain what and why**:
    The target audience for your commit messages are
    future readers of the project history.
    They are trying to understand **what** your changes did and **why**.
    They can always read the content changes directly for how they did that,
    so the ideal commit message should complement that.
    Great candidates include information that's
    not present in the content itself
    as well as guidance to understand the changes more quickly.

## Release management

### Release bats-mock

Releases have three phases.
The release pull request is prepared manually,
the draft is staged automatically after the pull request is merged,
and publishing remains a manual step.

The following steps show the release process using [Jujutsu](https://docs.jj-vcs.dev/latest/).

1. **Prepare a release pull request manually.**

   ```bash
   # We release the main branch
   jj new -r main@origin

   # Retrieve the bumped version for unreleased changes
   export RELEASE_VERSION=$(git cliff --bumped-version)
   echo $RELEASE_VERSION

   # The commit message has to start with an uppercase letter
   jj describe -m "chore: Release $RELEASE_VERSION"

   # Create a new revision, so git-cliff picks up the release changes
   jj new
   ./build changelog
   jj squash

   # Verify if everything is OK, and create the release PR
   ./build check
   jj bookmark create "release/$RELEASE_VERSION" -r @-
   jj git push --bookmark "release/$RELEASE_VERSION"
   ```

   Open a pull request from `release/$RELEASE_VERSION` to `main`.
   Do not create or push the release tag before merging.
   The pull request check skips only the not-yet-created tag comparison link;
   all other links are still checked.

2. **Stage the draft automatically after merge.**
   The `Stage Release` workflow creates the version tag at the merge commit,
   runs the full check with the tag available,
   downloads the tag's source archives,
   creates and verifies a SHA-256 checksum manifest,
   and attaches the manifest to a GitHub draft release.
   GitHub provides the source archives for the tag;
   the workflow uploads the checksum manifest.

3. **Review and publish manually.**
   Check the draft's notes, tag, and checksum manifest
   on the [GitHub releases page](https://github.com/mh182/bats-mock/releases).
   After verifying everything, publish the draft manually.
   Published releases are immutable,
   so verify all release details and assets before publishing.

### Release a devcontainer image

The devcontainer image is versioned with Semantic Versioning in
`.devcontainer/image-version`.
The CI workflow builds and publishes the image tag as
`ghcr.io/mh182/bats-mock-dev:<version>`.

The `Tests` workflow selects validation based on the changed files.
Changes to `.devcontainer/Containerfile`, `.devcontainer/image-version`,
or `.github/workflows/devcontainer-image.yml` build the image once
through the reusable `Devcontainer Image` workflow.
Other changes use the published image without building it.
Both routes run container checks and tests, followed by the Linux/macOS matrix.
For manual runs, enable `build_image` to select a local build;
the default is to use the published image.

Follow these steps to create a new devcontainer image release:

1. Update `.devcontainer/Containerfile` with your image changes.
2. Bump `.devcontainer/image-version` to the next semantic version.
3. Open a pull request to `main`.
   Image changes and source, test, or documentation changes
   can be included in the same PR.
   Validation uses the locally built image without waiting for publication.
4. Approve the `container-publish` environment deployment when prompted
   (if required reviewers are configured).
5. Wait for the `Tests` workflow to pass:
   - The guard job fails the PR if `Containerfile` changed
     without a corresponding version bump.
   - The build job runs `./build check` and Bats tests
     inside the new image.
   - PRs to `main` from the same repository publish the validated image.
     Fork PRs validate the image but cannot publish it to GHCR.
   - The Linux/macOS matrix runs after container validation succeeds.
   - `CI Status` verifies that the selected validation route
     and the complete test matrix succeeded.

Use `CI Status` as the required branch-protection check,
rather than requiring either mutually exclusive validation job.
For fork image changes, a maintainer must arrange publication
through a same-repository PR before subsequent ordinary runs
can pull the new version.

<!-- omit in toc -->

## Attribution

This guide is based on the [contributing.md](https://contributing.md/generator/)!

<!-- Links -->

[bats-core]: https://github.com/bats-core/bats-core
[shfmt]: https://github.com/mvdan/sh
[shellcheck]: https://www.shellcheck.net
