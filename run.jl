using ExercismTestReports

const SOLUTION_DIR = ARGS[2]
const OUTPUT_DIR = ARGS[3]

@debug "SOLUTION_DIR = " SOLUTION_DIR
@debug "OUTPUT_DIR = " OUTPUT_DIR

write(joinpath(OUTPUT_DIR, "results.json"), tojson(runtests(joinpath(SOLUTION_DIR, "runtests.jl"))...))
