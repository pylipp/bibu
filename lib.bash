response_body=/tmp/bb-response.json
token_filepath=~/.bb-tokens.json

_http_get() {
    # Execute HTTP GET request to given URL
    # Args: URL
    _http_request GET "$@"
}

_http_post() {
    # Execute HTTP POST request to given URL. Any additional arguments are
    # forwarded to _http_request
    # Args: URL [CURL-OPTIONS]
    _http_request POST "$@"
}

_http_request() {
    # Execute HTTP request of specified method (upper-case name) to given URL.
    # Any additional arguments are forwarded to curl.
    # The response is written to $response_body.
    # If a 401 response is returned, refresh access token, and repeat request.
    # Args: METHOD URL [CURL-OPTIONS]
    # Return: 0 if response ok
    #         1 if error in response
    #         2 if refreshing access failed

    local method url rc access_token http_status
    method="$1";  shift
    url="$1"; shift

    access_token=$(jq -r .access_token $token_filepath)

    http_status=$(curl -X "$method" -sL \
        -w "%{http_code}" \
        -o $response_body \
        -H 'Content-Type: application/json' \
        -H "Authorization: Bearer {$access_token}" \
        "$@" \
        "$url"
    )

    if [ "$http_status" -lt 300 ]; then
        rc=0

    elif [ "$http_status" -eq 401 ]; then
        if _bb_refresh_access; then
            _http_request "$method" "$url" "$@"
            rc=$?
        else
            rc=2
        fi

    else
        echo "Error ($http_status):" >&2
        jq -r . $response_body >&2
        rc=1
    fi

    return $rc
}

trigger_bb_pipeline() {
    # Trigger Bitbucket Pipeline via REST API
    # Optionally, pass a pipeline name to run (default: all_tests_and_style)
    # More info:
    # https://community.atlassian.com/t5/Bitbucket-Pipelines-questions/How-to-trigger-pipeline-through-API-based-on-a-tag/qaq-p/875182
    # https://developer.atlassian.com/bitbucket/api/2/reference/resource/repositories/%7Bworkspace%7D/%7Brepo_slug%7D/pipelines/#post
    repo=$(git remote -v | cut -d: -f2 | cut -d. -f1 | tail -n1)

    pipeline_name=${1:-'01_all_tests_and_style'}

    echo "Requesting to run pipeline \"$pipeline_name\" on current branch in $repo..." >&2

    args=("$(git rev-parse --abbrev-ref HEAD)" "$(git rev-parse HEAD)" "$pipeline_name")
    _pipeline_run "$repo" "${args[@]}"
}

_pipeline_run() {
    local repo branch revision pipeline_name url data rc
    repo="$1"
    branch="$2"
    revision="$3"
    pipeline_name="$4"

    url=https://api.bitbucket.org/2.0/repositories/$repo/pipelines/
    data="{
      \"target\": {
        \"commit\": {
          \"type\": \"commit\",
          \"hash\": \"$revision\"
        },
        \"selector\": { \"type\": \"custom\", \"pattern\": \"$pipeline_name\" },
        \"ref_type\": \"branch\",
        \"type\": \"pipeline_ref_target\",
        \"ref_name\": \"$branch\"
      }
    }"

    if _http_post "$url" -d "$data"; then
        rc=0
        printf "Started pipeline " >&2
        jq -r .uuid $response_body >&2

    else
        rc=1
    fi

    return $rc
}

bb_issues() {
    repo=$(git remote -v | cut -d: -f2 | cut -d. -f1 | tail -n1)
    echo "Listing open/new issues in $repo..." >&2

    _bb_issue_list "$repo"
}

_bb_issue_list() {
    local rc url repo
    repo="$1"

    rc=0
    url=https://api.bitbucket.org/2.0/repositories/"$repo"/issues

    while true; do
        if _http_get "$url"; then
            local state title id
            while IFS=  read -r; do
                state=$(echo "$REPLY" | jq -r .state)

                if [[ $state = new ]] || [[ $state = open ]]; then
                    title=$(echo "$REPLY" | jq -r .title)
                    id=$(echo "$REPLY" | jq -r .id)
                    printf '%s %s\n' "$id" "$title"
                fi
            done < <(jq -cr '.values[] | {title: .title, state: .state, id: .id}' $response_body)

            url=$(jq -r .next $response_body)
            if [[ "$url" = null ]]; then
                break
            fi

        else
            rc=1
            break
        fi
    done | sort -n -r

    return $rc
}

bb_pipelines() {
    repo=$(git remote -v | cut -d: -f2 | cut -d. -f1 | tail -n1)
    echo "Listing open/new pipelines in $repo..." >&2

    _pipeline_list "$repo"
}

_pipeline_list() {
    local rc url repo
    repo="$1"

    url=https://api.bitbucket.org/2.0/repositories/$repo/pipelines/'?sort=-created_on'

    rc=0
    if _http_get "$url"; then
        local state

        while IFS=  read -r; do
            printf '%d ' "$(echo "$REPLY" | jq -r .build_number)"
            # Convert '2020-03-05T08:56:29.204Z' to '2020-03-05 08:56'
            printf '%s ' "$(echo "$REPLY" | jq -r .created_on | cut -d: -f1,2 | tr T ' ')"
            printf '%s ' "$(echo "$REPLY" | jq -r .creator.display_name | cut -d' ' -f1)"
            printf '%s ' "$(echo "$REPLY" | jq -r .target.ref_name)"

            state=$(echo "$REPLY" | jq -r .state.name)

            if [[ $state = IN_PROGRESS ]] || [[ $state = PENDING ]]; then
                printf '%s' "$state"
            elif [[ $state = COMPLETED ]]; then
                printf '%s' "$(echo "$REPLY" | jq -r .state.result.name)"
            fi
            printf '\n'
        done < <(jq -cr '.values[]' $response_body) | column -t

    else
        rc=1
    fi

    return $rc
}

inspect_bb_pipeline() {
    [[ $# -ne 1 ]] && { echo "Pipeline ID missing" >&2; return 1; }

    repo=$(git remote -v | cut -d: -f2 | cut -d. -f1 | tail -n1)
    url="https://bitbucket.org/$repo/addon/pipelines/home#!/results/$1"

    echo "Opening $url..."
    xdg-open "$url"
}

_bb_refresh_access() {
    echo "Refreshing access token..." >&2

    local http_status rc

    rc=0
    http_status=$(curl -X POST -s \
        -w "%{http_code}" \
        -o $response_body \
        -u "$BITBUCKET_REST_API_AUTH" \
        https://bitbucket.org/site/oauth2/access_token \
        -d grant_type=refresh_token \
        -d refresh_token="$(jq -r .refresh_token $token_filepath)")

    if [ $http_status -lt 300 ]; then
        # Store tokens
        mv $response_body $token_filepath
    else
        echo "Error refreshing access ($http_status):" >&2
        jq -r . $response_body >&2
        rc=1
    fi

    return $rc
}

_bb_obtain_access() {
    echo "Obtaining access token..." >&2
    local http_status rc

    http_status=$(curl -X POST -s \
        -w "%{http_code}" \
        -o $response_body \
        -u "$BITBUCKET_REST_API_AUTH" \
        https://bitbucket.org/site/oauth2/access_token \
        -d grant_type=client_credentials)

    if [ $http_status -lt 300 ]; then
        # Store tokens
        mv $response_body $token_filepath
        rc=0
    else
        echo "Error obtaining access ($http_status):" >&2
        jq -r . $response_body >&2
        rc=1
    fi

    return $rc
}
