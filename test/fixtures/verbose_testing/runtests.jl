using Test

#Adapted from /nested/runtests.jl

f(x) = x

@testset verbose = true "tests" begin
    @testset "inner 1" begin
        @test 1 == 1
        @test 1 == 2
    end

    @testset "inner 2" begin
        @test 3 == 4
    end

    @testset "inner 3" begin
        @test 5 == 6
    end

    @test 1 == 1

    @testset "outer 3" begin
        @test error("")
        @test true

        @testset "inner 4" begin
            @test f(5) == 6
        end
    end
end
