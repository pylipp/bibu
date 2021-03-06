load '/usr/local/libexec/bats-support/load.bash'
load '/usr/local/libexec/bats-assert/load.bash'

setup() {
    source bibu.bash
}

@test "Show main usage" {
    run main
    assert_failure

    assert_line -n 0 'Usage: bibu COMMAND'
}

@test "Show issue usage" {
    run main issue
    assert_failure

    assert_line -n 0 'Usage: bibu issue list'
}

@test "Show pr usage" {
    run main pr
    assert_failure

    assert_line -n 0 'Usage: bibu pr list'
    assert_line -n 1 '       bibu pr create [-t TITLE]'
}

@test "Show pipeline usage" {
    run main pipeline
    assert_failure

    assert_line -n 0 'Usage: bibu pipeline list'
    assert_line -n 1 '       bibu pipeline run [-n NAME]'
}

@test "Show api usage" {
    run main api
    assert_failure

    assert_line -n 0 'Usage: bibu api RESOURCE'
}

@test "Parse issue list subcommand" {
    run parse_command_line issue list
    assert_success

    assert_line -n 0 'bb_issue_list'
}

@test "Parse pr list subcommand" {
    run parse_command_line pr list
    assert_success

    assert_line -n 0 'bb_pr_list'
}

@test "Parse pr create subcommand without options" {
    run parse_command_line pr create
    assert_success

    assert_line -n 0 "bb_pr_create"
}

@test "Parse pr create subcommand including title" {
    run parse_command_line pr create -t title
    assert_success

    assert_line -n 0 "bb_pr_create -t title"
}

@test "Parse issue list subcommand help option" {
    run parse_command_line issue list --help
    assert_failure

    assert_line -n 0 'usage_issue'
}

@test "Parse pipeline list subcommand" {
    run parse_command_line pipeline list
    assert_success

    assert_line -n 0 'bb_pipeline_list'
}

@test "Parse pipeline run subcommand" {
    run parse_command_line pipeline run -n testing
    assert_success

    assert_line -n 0 'bb_pipeline_run -n testing'
}

@test "Parse api command" {
    run parse_command_line api pullrequests/1
    assert_success

    assert_line -n 0 'bb_api pullrequests/1'
}
