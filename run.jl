using ExercismTestReports

const SOLUTION_DIR = ARGS[2]
const OUTPUT_DIR = ARGS[3]

@debug "SOLUTION_DIR = " SOLUTION_DIR
@debug "OUTPUT_DIR = " OUTPUT_DIR

let json_str = tojson(runtests(joinpath(SOLUTION_DIR, "runtests.jl"))...)
    cleaned_json_str = replace(json_str, SOLUTION_DIR => "./")
    write(joinpath(OUTPUT_DIR, "results.json"), cleaned_json_str)
end
