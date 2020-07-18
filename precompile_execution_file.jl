# This file is required for PackageCompiler
# See https://julialang.github.io/PackageCompiler.jl/dev/sysimages/#tracing-1 for more info

using ExercismTestReports

let json_str = tojson(runtests(joinpath("test", "fixtures", "everything_at_once", "runtests.jl"))...)
    cleaned_json_str = replace(json_str, joinpath("test", "fixtures", "everything_at_once") => "./")
    write(joinpath(mktempdir(), "results.json"), cleaned_json_str)
end
