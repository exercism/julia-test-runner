using Test
using JSON

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
    We currently populate test_code only with the failing or erroring `@test`
    expression. This means that we don't give all the necessary information if
    the test relies on definitions outside of that expression, e.g.

    ```julia
    @testset begin
        robot = Robot()
        @test robot.rename!()
    end
    ```

    For that to make sense, the student would really need the entirety of the
    enclosing testset, but we will only give them the string
    `@test robot.rename!()`

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

    # Flag set in walk!(), used for top-level status property
    any_failed = false
    output = truncate_output(output)

    """
        walk!(prefix, tests, testset)

    Walk the tree of testsets, pushing Dicts to `tests` describing each test
    result. Returns nothing.
    """
    function walk!(tests, prefix, testset)
        name = isempty(prefix) ? testset.description : "$prefix » $(testset.description)"

        # Should we number the tests?
        number_tests = count(x -> x isa Test.Result, testset.results) > 1

        for (n, result) in enumerate(testset.results)
            status = nothing
            message = nothing
            test_code = nothing

            if result isa Test.Pass
                status = "pass"
                message = nothing
            elseif result isa Test.Fail
                status = "fail"
                message = string(result)
                test_code = "@test " * result.orig_expr
            elseif result isa Test.Error
                status = "error"
                message = result.backtrace
                test_code = "@test " * result.orig_expr
            elseif result isa Test.Broken
                status = "fail"
                message = string(result)
                test_code = result.test_type === :skipped ? "@test_skip " : "@test "
                test_code *= string(result.orig_expr)
            elseif result isa Test.AbstractTestSet
                # Descend into nested test sets
                child_has_failed = walk!(tests, name, result)
                continue
            else
                error("Unknown testset.results item: $result")
            end

            any_failed = any_failed || status in ("fail", "error")

            push!(tests, Dict(filter( ((k, v),) -> !isnothing(v), (
                "name" => number_tests ? "$name.$n" : name,
                "status" => status,
                "message" => message,
                "test_code" => test_code,
                "output" => output,
            ))))
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
