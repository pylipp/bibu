load '/usr/local/libexec/bats-support/load.bash'
load '/usr/local/libexec/bats-assert/load.bash'

setup() {
    source lib.bash

    # Obtain access only during initial setup
    if [ ! -f "$token_filepath" ]; then
        _bb_obtain_access
    fi
}

@test "Listing of issues" {
    run _bb_issue_list pylipp/test-rest-api-wrapper
    assert_success

    assert_line -n 0 '12 Test issue 10'
    assert_line -n 1 '11 Test issue 9'
    assert_line -n 2 '10 Test issue 8'
    assert_line -n 3 '9 Test issue 7'
    assert_line -n 4 '8 Test issue 6'
    assert_line -n 5 '7 Test issue 5'
    assert_line -n 6 '6 Test issue 4'
    assert_line -n 7 '5 Test issue 3'
    assert_line -n 8 '4 Test issue 2'
    assert_line -n 9 '3 Test issue 1'
    assert_line -n 10 '2 Test issue 0'
    assert_line -n 11 '1 This is the title'
    assert_equal ${#lines[@]} 12
}
