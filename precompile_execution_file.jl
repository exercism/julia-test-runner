# This file is required for PackageCompiler
# See https://julialang.github.io/PackageCompiler.jl/dev/sysimages.html#tracing for more info

using ExercismTestReports

mktempdir(dir -> test_runner("", "test/fixtures/everything_at_once", dir))
