load '/usr/local/libexec/bats-support/load.bash'
load '/usr/local/libexec/bats-assert/load.bash'

setup() {
    source lib.bash
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

@test "Show pipeline usage" {
    run main pipeline
    assert_failure

    assert_line -n 0 'Usage: bibu pipeline list'
    assert_line -n 1 '       bibu pipeline run'
}

@test "Parse issue list subcommand" {
    run parse_command_line issue list
    assert_success

    assert_line -n 0 'bb_issues'
}

@test "Parse pipeline list subcommand" {
    run parse_command_line pipeline list
    assert_success

    assert_line -n 0 'bb_pipelines'
}

@test "Parse pipeline run subcommand" {
    run parse_command_line pipeline run
    assert_success

    assert_line -n 0 'trigger_bb_pipeline'
}
