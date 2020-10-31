using Test

@testset "first test" begin
    @test 1 == 1
end

@testset "second test" begin
    x = 2
    @test x == 1
end

@testset "third test" begin
    @test 3 == 3
end
