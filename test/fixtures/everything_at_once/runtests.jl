using Test

# Include stdlibs in sysimage
using Dates
using Random
using Unicode
using Printf

@testset "first test" begin
    x = 1
    @show x # Debugging
    @test x == 1
end

@testset "second test" begin
    @test 1 == 2
end

@testset "third test" begin
    @test error("")
end
