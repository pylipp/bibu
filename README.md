# `bibu`

A Bitbucket command line client written in Python3.

## Ideas

### bibu configuration

- use git config to store e.g. username

### Pipelines

- trigger
- status

### Pull requests

- add
- list
- review

## Dependencies

- `requests`
- `gitpython`

## Authentication

### bitbucket.org web interface

- Bitbucket settings -> Access management -> OAuth -> Add consumer
- enter name and callback URL (e.g. https://google.com)
- adjust permissions
- save
- copy key and secret

### Request access token via command line

- from [4.4](https://developer.atlassian.com/bitbucket/api/2/reference/meta/authentication):

    curl -X POST KEY:SECRET https://bitbucket.org/site/oauth2/access_token -d grant_type=client_credentials

## TODO

[x] check how to authenticate with Bitbucket (also [this](https://community.atlassian.com/t5/Answers-Developer-Questions/Bitbucket-REST-API-POST-using-token-instead-of-basic-auth/qaq-p/474823) or [this](https://developer.atlassian.com/cloud/bitbucket/oauth-2/))
