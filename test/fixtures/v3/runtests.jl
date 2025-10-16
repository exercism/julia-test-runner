using Test

const EXERCISM_CONCEPT_EXERCISE = true

#Adapted from /verbose_testing/runtests.jl

f(x) = x

@testset verbose = true "tests" begin
    @testset "1. First task name" begin
        @test 1 == 1
        @test 1 == 2
    end

    @testset "2. Second task name" begin
        @test 3 == 4
    end

    @testset "3. Third task name" begin
        @test 5 == 6
    end

    @testset "4. Fourth task name" begin
        @test error("")
        @test true

        @testset "Inner 4" begin
            @test f(5) == 6
        end
    end
end
