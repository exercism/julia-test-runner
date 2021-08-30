using ExercismTestReports
using JSON
using Test

# When running tests on this project, the solution_dir path is likely to be
# in our home directory, which Julia prints differently, so we copy all the
# input paths to somewhere else to sort that out (might not work in windows,
# but also who cares?)

const FIXTURES = joinpath(@__DIR__, "fixtures")
const TEMPDIR = mktempdir()
cp(FIXTURES, joinpath(TEMPDIR, "fixtures"))
const TMP_FIXTURES = joinpath(TEMPDIR, "fixtures")

@testset for fixture in readdir(TMP_FIXTURES)
    results = test_runner("", "$TMP_FIXTURES/$fixture/")
    d1 = JSON.parse(results)
    reference = "$FIXTURES/$fixture/results.json"
    if isfile(reference)
        d2 = JSON.parsefile(reference)
        @test d1 == d2
    else
        write(reference, JSON.json(d1, 4))
        @test_skip nothing
    end
end
