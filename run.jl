using ExercismTestReports

const SOLUTION_DIR = ARGS[2]
const OUTPUT_DIR = ARGS[3]

@debug "SOLUTION_DIR = " SOLUTION_DIR
@debug "OUTPUT_DIR = " OUTPUT_DIR

let json_str = tojson(runtests(joinpath(SOLUTION_DIR, "runtests.jl"))...)
    # Strip dir inside the test-runner container
    cleaned_json_str = replace(json_str, SOLUTION_DIR => "./")

    # Strip Julia build env directories
    # This may need to be changed if the build environment of Julia changes in future versions
    cleaned_json_str = replace(cleaned_json_str, "/buildworker/worker/package_linux64/build/usr/share" => "[...]")

    write(joinpath(OUTPUT_DIR, "results.json"), cleaned_json_str)
end
