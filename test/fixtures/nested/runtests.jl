using Test

f(x) = x

@testset "outer" begin
    @testset "inner 1" begin
        @test 1 == 1
        @test 1 == 2
    end

    @testset "inner 2" begin
        @test 3 == 4
    end
end

# Not sure if a testset like this with multiple levels should be permitted or not.
# For now, we assume that it is.
@testset "outer 2" begin
    @testset "inner 3" begin
        @test 5 == 6
    end

    @test 1 == 1
end


@testset "outer 3" begin
    @test error("")
    @test true

    @testset "inner 4" begin
        @test f(5) == 6
    end
end
