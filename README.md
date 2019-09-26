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

### Bash implementation for running pipeline of current HEAD

    # Trigger Bitbucket Pipeline via REST API
    # Optionally, pass a pipeline name to run
    # More info:
    # https://community.atlassian.com/t5/Bitbucket-Pipelines-questions/How-to-trigger-pipeline-through-API-based-on-a-tag/qaq-p/875182
    # https://developer.atlassian.com/bitbucket/api/2/reference/resource/repositories/%7Bworkspace%7D/%7Brepo_slug%7D/pipelines/#post
    repo=$(git remote -v | cut -d: -f2 | cut -d. -f1 | tail -n1)

    pipeline_name=$1

    echo "Requesting to run pipeline \"$pipeline_name\" on current branch in $repo..."

    token_filepath=~/.bb-tokens.json
    access_token=$(jq -r .access_token $token_filepath)
    response_body=/tmp/bb-response.json
    http_status=$(curl -X POST -s \
        -w "%{http_code}" \
        -o $response_body \
        -H 'Content-Type: application/json' \
        -H "Authorization: Bearer {$access_token}" \
        https://api.bitbucket.org/2.0/repositories/$repo/pipelines/ \
        -d "
    {
      \"target\": {
        \"commit\": {
          \"type\": \"commit\",
          \"hash\": \"$(git rev-parse HEAD)\"
        },
        \"selector\": { \"type\": \"custom\", \"pattern\": \"$pipeline_name\" },
        \"ref_type\": \"branch\",
        \"type\": \"pipeline_ref_target\",
        \"ref_name\": \"$(git rev-parse --abbrev-ref HEAD)\"
      }
    }")

    rc=0
    if [ $http_status -lt 300 ]; then
        printf "Started pipeline "
        jq -r .uuid $response_body
    else
        if [ $http_status -eq 401 ]; then
            echo "Refreshing access token..."

            http_status=$(curl -X POST -s \
                -w "%{http_code}" \
                -o $response_body \
                -u "$CONSUMER_KEY:$CONSUMER_SECRET" \
                https://bitbucket.org/site/oauth2/access_token \
                -d grant_type=refresh_token \
                -d refresh_token="$(jq -r .refresh_token $token_filepath)")

            if [ $http_status -lt 300 ]; then
                # Store tokens and re-request pipeline run
                mv $response_body $token_filepath
                trigger_bb_pipeline "$@"
            else
                echo "Error refreshing access ($http_status):"
                jq -r . $response_body
                rc=1
            fi
        else
            echo "Error ($http_status):"
            jq -r . $response_body
            rc=1
        fi
    fi

    return $rc

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
