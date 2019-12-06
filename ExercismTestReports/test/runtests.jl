using ExercismTestReports
using FileIO
using ReferenceTests
using Test

# The custom ReferenceTest handler doesn't work on Windows due to the regex used for detection directories
Sys.iswindows() && error("Windows is not supported. Please use WSL or Docker to run the test suite")

"""
Replace everything in `s` that looks like a directory with `{{DIR}}/`.

**Example**
```jldoctest
julia> s = "Test Failed at /home/user/foo/julia-test-runner/ExercismTestReports/test/references/single-failing-testset/runtests.jl:4";

julia> replace_paths(s)
"Test Failed at {{DIR}}/runtests.jl:4"
```
"""
replace_paths(s) = replace(s, r"(?>\/[a-zA-Z\-0-9\_\.]+)+\/" => "{{DIR}}/")

# Overwrite the called ReferenceTests.test_reference method with one that replaces directories
# This is super hacky but it's unlikely this package will be used in any context that isn't an Exercism test-runner, so it shouldn't cause any issues
# A better way would be defining a new FileIO format, FileIO loaders/savers for it and then creating a new handler that dispatches on the new format
function ReferenceTests.test_reference(file::FileIO.File{FileIO.format"TXT"}, actual; render = ReferenceTests.Diff())
    # Open file and replace dirs
    orig = read(file.filename, String)

    open(file, "w") do f
        write(f, replace_paths(orig))
    end
    
    ReferenceTests._test_reference(render, file, replace_paths(string(actual)))
end

for (root, dirs, files) in walkdir("references")
    # If we're not in a directory that contains tests, skip it
    # This should allow us to arbitrarily nest test directories
    "runtests.jl" in files || continue

    @info "Testing $root"
    @test_reference joinpath(root, "results.json") generate_json_report(joinpath(root, "runtests.jl"))
end
