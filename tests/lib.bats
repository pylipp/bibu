load '/usr/local/libexec/bats-support/load.bash'
load '/usr/local/libexec/bats-assert/load.bash'

setup() {
    source lib.bash
}

@test "Obtaining access downloads tokens to file" {
    [ ! -f "$token_filepath" ]

    run _bb_obtain_access
    assert_success
    assert_line -n 0 'Obtaining access token...'
    assert_equal ${#lines[@]} 1

    [ -f "$token_filepath" ]
}
