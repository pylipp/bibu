load '/usr/local/libexec/bats-support/load.bash'
load '/usr/local/libexec/bats-assert/load.bash'

setup() {
    source bibu.bash

    # Obtain access only during initial setup
    if [ ! -f "$token_filepath" ]; then
        _bb_obtain_access
    fi
}

@test "Listing of issues" {
    run _list_all pylipp/test-rest-api-wrapper issues
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

@test "Listing of pipelines" {
    run _pipeline_list pylipp/test-rest-api-wrapper
    assert_success

    assert_line -n 0 '6  2020-03-13  10:43  pylipp  master  SUCCESSFUL'
    assert_line -n 1 '5  2020-03-12  18:35  pylipp  test    STOPPED'
    assert_line -n 2 '4  2020-03-12  18:30  pylipp  test    SUCCESSFUL'
    assert_line -n 3 '3  2020-03-12  13:09  pylipp  master  SUCCESSFUL'
    assert_line -n 4 '2  2020-03-12  13:09  pylipp  master  SUCCESSFUL'
    assert_line -n 5 '1  2020-03-12  13:06  pylipp  master  SUCCESSFUL'
    assert_equal ${#lines[@]} 6
}

@test "Running a pipeline" {
    run _pipeline_run pylipp/test-rest-api-wrapper master d54ee23ee9537d61200e9bb9fc36b02c82619d3c test
    assert_success

    assert_line -n 0 -p 'Started pipeline {'
}
