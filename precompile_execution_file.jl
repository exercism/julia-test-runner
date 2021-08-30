# This file is required for PackageCompiler
# See https://julialang.github.io/PackageCompiler.jl/dev/sysimages/#tracing-1 for more info

using ExercismTestReports: test_runner

mktempdir(dir -> test_runner("", "test/fixtures/everything_at_once", dir))
