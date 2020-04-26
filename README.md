# `bibu`
[![Build Status](https://travis-ci.org/pylipp/bibu.svg?branch=master)](https://travis-ci.org/pylipp/bibu)

A Bitbucket command line client written in bash.

## Installation

`bibu` is distributed as Python package. It's best downloaded from the Python Packaging Index PyPI by

    pip install --user bibu

Alternatively you can install the relevant bash files: the main executable `bibu` into `~/.local/bin` and the bash library `bibu.bash` into `~/.local/lib`.

In either case take care to add `~/.local/bin` to your `$PATH`.

### Bitbucket authentication

Obtain OAuth consumer key and secret from your Bitbucket profile settings:

- Bitbucket settings -> Access management -> OAuth -> Add consumer
- enter name and callback URL (e.g. https://google.com)
- adjust permissions (`team pipeline:variable webhook pullrequest:write snippet:write wiki repository:admin project issue:write account`)
- save
- copy key and secret to environment variable `$BITBUCKET_REST_API_AUTH` (separated by colon)

### Dependencies

`bibu` depends on `curl` and `jq`.

It's tested against `bash` 4.4.19, `curl` 7.64.0, `jq` 1.6 in an Alpine Linux Docker image.

## Usage

Consult `bibu --help`

    bibu operates on the repository of the current working directory, and derives
    information from 'git-remote'.

    Available commands:
        issue           Manage Bitbucket issues
        pipeline        Manage Bitbucket pipelines
        pr              Manage Bitbucket pullrequests
        api             Get resource via REST API

    General options:
        --help          Display help message

## Ideas

Future features... Feel free to contribute!

### Pipelines

- trigger
- list / status
- browse

### Pull requests

- create
- list
- review

### Issues

- create
- list
- update
- comment

## Contributing

### Set up

Fetch the Docker image

    docker pull pylipp/bibu:latest

Install development dependencies into Python venv

    pip install -U .[dev]

### Testing

Tests are written with bats. Execute test suite

    ./run test

or a dedicated test

    ./run test tests/cli.bats

### Development installation

Editable pip-install is not compatible with using the `data_files` option in `setup.py`. Hence apply the work-around

    ./run install

### Release

1. Tag latest commit on master by version number acc. to format `vX.Y.Z`.
1. `./run release`

## Related projects

- [gh](https://github.com/cli/cli)
- [hub](https://github.com/github/hub)
- [Python wrapper for Atlassian REST APIs](https://github.com/atlassian-api/atlassian-python-api)
- open an issue or a pull request to extend the list :)
