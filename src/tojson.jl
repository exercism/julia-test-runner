using Test
using JSON

"""
Testsets with more than this number of tests will have all of their passing
tests collapsed into a single report.
"""
const TEST_RESULT_COLLAPSE_THRESHOLD = 2
const MAX_REPORTED_FAILURES_PER_TESTSET = 5
const MAX_REPORTED_PASSING_TEST_CODE_PER_COLLAPSE = 5

"""
    tojson(output::String, ts::ReportingTestSet)

Takes user output and a ReportingTestSet and converts it to a JSON string as
expected by the interface.

Here's a brief summary of the schema we're following:

{
    version: 2
    status: pass | fail | error
    message?: "a descriptive message emitted only if none of the tests ran (e.g. a syntax error in the file)"
    tests: [
        {
            name: "a human-readable name"
            status: pass | fail | error
            message?: "Describes the result of the test if it did not pass"
            output?: "the stdout for this test"
            test_code?: "snippet of code that failed that student can try locally"
                (required for failing or erroring concept exercise tests)
            task_id?: "a concept exercise thing we don't support yet"
                (bump version to 3 if we support this)
        },
    ]
}

Note:
    We currently populate test_code only with the type of failure, the failing 
    or erroring `@test` expression and what was evaluated (i.e. the Test.Report
    output). This means that we don't give all the necessary information if the 
    test relies on definitions outside of that expression, e.g.

    ```julia
    @testset begin
        robot = Robot()
        @test robot.rename!()
    end
    ```

    For that to make sense, the student would really need the entirety of the
    enclosing testset.

For more information, check the reference:

https://github.com/exercism/docs/blob/main/building/tooling/test-runners/interface.md
"""
# TODO: Capture output per-test
function tojson(output::String, ts::ReportingTestSet)
    if length(ts.results) == 1 && ts.results[1] isa Test.Error
        # There has been a syntax error or similar and no tests have run.
        # Otherwise ts.results[1] will be a ReportingTestSet.
        return JSON.json(Dict(
            "version" => 2,
            "status" => "error",
            "message" => ts.results[1].backtrace,
            "tests" => [],
        ), 4)
    end

    "Rules say we truncate with a warning message or emit an error if output is too long"
    function truncate_output(output)
        truncation_message = "Output was truncated. Please limit to 500 chars\n\n"
        if isempty(output)
            nothing
        elseif length(output) > 500
            truncation_message * first(output, 500 - length(truncation_message))
        else
            output
        end
    end

    # Flag set in push_result!(), used for top-level status property
    any_failed = false
    # All stdout from the top level test set, used for all tests.
    output = truncate_output(output)

    function test_code(result::Test.Result)
        if hasproperty(result, :test_type) && startswith(string(result.test_type), "test_throws")
            "@test_throws $(result.data) $(result.orig_expr)"
        elseif result isa Test.LogTestFailure
            "@test_logs $(join(result.patterns, ' ')) $(result.orig_expr)"
        elseif hasproperty(result, :test_type) && result.test_type == :test_unbroken
            "@test_broken $(result.orig_expr)"
        elseif result isa Test.Broken
            macro_name = result.test_type === :skipped ? "@test_skip " : "@test_broken "
            "$macro_name $(result.orig_expr)"
        else
            if hasproperty(result, :backtrace)
                # For test failure, return full Test.Result output minus the source and stacktrace.
                strip(replace(string(result), r" at .+\n" => "\n", r"\n  Stacktrace[\s\S]*" => "", count=2))
            else 
                # For test success, return the evaluated expression.
                "@test $(result.orig_expr)"
            end
        end
    end

    """
        push_result!(tests, result, name)

    Push a test result called `name` to `tests`. Returns the pushed Dict or `nothing` if the test was not pushed.
    """
    function push_result!(tests, result::Test.Result, name)
        status = nothing
        message = nothing

        if result isa Test.Pass
            status = "pass"
        elseif result isa Test.Fail
            status = "fail"
            message = string(result)
        elseif result isa Test.LogTestFailure
            status = "fail"
            message = string(result)
        elseif result isa Test.Error
            status = "error"
            message = result.backtrace
        elseif result isa Test.Broken
            if result.test_type === :skipped
                return nothing
            end
            # TODO: In the future we might have a new `status = skip`
            message = string(result)
        else
            error("Unknown testset.results item: $result")
        end

        any_failed = any_failed || status in ("fail", "error")

        return push!(tests, Dict(filter( ((k, v),) -> !isnothing(v), (
            "name" => name,
            "status" => status,
            "message" => message,
            "test_code" => test_code(result),
            "output" => output,
        ))))
    end

    """
        walk!(tests, prefix, testset)

    Walk the tree of testsets, pushing Dicts to `tests` describing each test
    result. Returns nothing.
    """
    function walk!(tests, prefix, testset)
        name = testset.verbose ? "" : isempty(prefix) ? testset.description : "$prefix » $(testset.description)"

        num_results = count(x -> x isa Test.Result, testset.results)

        function test_name(result, idx)
            if name == "" # Tests that aren't in a testset
                string(result.orig_expr)
            else
                # If there's more than one test in the testset, distinguish
                # them with numbers.
                num_results > 1 ? "$name.$idx" : name
            end
        end

        # Should we collapse all passing tests into one report?
        passing_tests = filter(x -> x isa Test.Pass, testset.results)
        num_passing = length(passing_tests)
        collapse_passing_tests = num_results >= TEST_RESULT_COLLAPSE_THRESHOLD && num_passing > 1 && name != ""

        if collapse_passing_tests
            collapsed_name = num_passing == num_results ? name : "$name » $num_passing tests"
            # If many tests pass then the reported test_code will be excessively large, so we truncate it.
            if num_passing > MAX_REPORTED_PASSING_TEST_CODE_PER_COLLAPSE
                code = join(map(test_code, passing_tests[1:MAX_REPORTED_PASSING_TEST_CODE_PER_COLLAPSE]), '\n') * "\n..."
            else
                code = join(map(test_code, passing_tests), '\n')
            end
            push!(tests, Dict(
                "name" => collapsed_name,
                "status" => "pass",
                "test_code" => code,
            ))
        end

        # Push up to MAX_REPORTED_FAILURES_PER_TESTSET failing test results.
        # Also recurse into any test sets and report passing test results if
        # they weren't collapsed.
        num_reported_failures = 0
        for (n, result) in enumerate(testset.results)
            if result isa Test.AbstractTestSet
                walk!(tests, name, result)
            elseif result isa Test.Pass
                collapse_passing_tests || push_result!(tests, result, test_name(result, n))
            else
                num_reported_failures >= MAX_REPORTED_FAILURES_PER_TESTSET && continue
                num_reported_failures += !isnothing(push_result!(tests, result, test_name(result, n)))
            end
        end
        return nothing
    end

    tests = Dict{String, Union{String, Nothing}}[]

    walk!(tests, "", ts)

    JSON.json(Dict(
        "version" => 2,
        "status" => any_failed ? "fail" : "pass",
        "tests" => tests,
    ), 4)
end
