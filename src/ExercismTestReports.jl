module ExercismTestReports

include("testset.jl")
include("runner.jl")
include("tojson.jl")

export ReportingTestSet
export test_runner

"""
    test_runner(exercise_slug, solution_dir)

Like the three-argument version but returns a String encoding the contents of results.json instead of writing it to a file.

This version is used in the tests for the test_runner itself.
"""
function test_runner(exercise_slug, solution_dir)
    captured_stdout, testsets, concept = runtests(joinpath(solution_dir, "runtests.jl"))
    json_str = tojson(captured_stdout, testsets, concept)

    # Strip dir inside the test-runner container
    cleaned_json_str = replace(json_str, solution_dir => "./")

    # Strip Julia build env directories
    # This may need to be changed if the build environment of Julia changes in future versions
    cleaned_json_str = replace(cleaned_json_str, "/buildworker/worker/package_linux64/build/usr/share" => "[...]")

    return cleaned_json_str
end

"""
    test_runner(exercise_slug, solution_dir, output_dir)

Implements the interface described below.

https://github.com/exercism/docs/blob/main/building/tooling/test-runners/interface.md
"""
function test_runner(exercise_slug, solution_dir, output_dir)
    write(joinpath(output_dir, "results.json"), test_runner(exercise_slug, solution_dir))
end

end
