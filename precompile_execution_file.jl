# This file is required for PackageCompiler
# See https://julialang.github.io/PackageCompiler.jl/dev/sysimages.html#tracing for more info
#
# PackageCompiler runs this file with --trace-compile and replays the recorded
# precompile statements while it builds the sysimage. Only calls made through
# dynamic dispatch are recorded. A call made inside a closure (such as the body
# of `mktempdir() do dir ... end`) is compiled together with that closure, and
# the closure itself cannot be replayed, so its code never reaches the sysimage.
# We call test_runner through invokelatest so each call is recorded as
# test_runner(::String, ::String, ::String), the same entry point used by run.jl.
#
# We run every fixture because the report code is specialised on the shape of
# each run (with or without printed output, failures, errors, skipped tests,
# syntax errors). Without this, every run would compile that code again (about
# 0.6 s on a t3.medium).

using ExercismTestReports

const OUTPUT_DIR = mktempdir()

for fixture in readdir("test/fixtures"; join=true)
    Base.invokelatest(test_runner, "", fixture * "/", OUTPUT_DIR)
end
