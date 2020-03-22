# `bibu`

A Bitbucket command line client written in Python3.

## Ideas

### bibu configuration

- use git config to store e.g. username

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

## Dependencies

- `requests` (rather: `atlassian-python-api`)
- `gitpython` (or: `sh`)

## Authentication

### bitbucket.org web interface

- Bitbucket settings -> Access management -> OAuth -> Add consumer
- enter name and callback URL (e.g. https://google.com)
- adjust permissions
- save
- copy key and secret to environment variable `$BITBUCKET_REST_API_AUTH`

### Request access token via command line (one-off)

From [4.4](https://developer.atlassian.com/bitbucket/api/2/reference/meta/authentication):

    mkdir -p ~/.config/bibu
    curl -X POST "$BITBUCKET_REST_API_AUTH" https://bitbucket.org/site/oauth2/access_token -d grant_type=client_credentials > ~/.config/bibu/credentials.json

This functionality is provided by the library:

    source lib.bash
    _bb_obtain_access

### Refresh access token

From [here](https://developer.atlassian.com/bitbucket/api/2/reference/meta/authentication#refresh-tokens)

> Our access tokens expire in one hour. When this happens you'll get 401 responses.

Hence

    curl -X POST -u "$BITBUCKET_REST_API_AUTH" https://bitbucket.org/site/oauth2/access_token -d grant_type=refresh_token -d refresh_token="$(jq -r .refresh_token ~/.config/bibu/credentials.json)"

## TODO

[x] check how to authenticate with Bitbucket (also [this](https://community.atlassian.com/t5/Answers-Developer-Questions/Bitbucket-REST-API-POST-using-token-instead-of-basic-auth/qaq-p/474823) or [this](https://developer.atlassian.com/cloud/bitbucket/oauth-2/))

## Contributing

### Testing

Fetch the Docker image

    docker pull pylipp/bibu:latest

Create Bitbucket REST API consumer key and secret from your Bitbucket account and save them as environment variable (see section 'Authentication' above).

Execute test suite

    ./run test
