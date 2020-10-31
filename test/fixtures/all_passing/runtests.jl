using Test

@testset "first test" begin
    x = 1
    @test x == 1
end

@testset "second test" begin
    @test 2 == 2
end

@testset "third test" begin
    @test 3 == 3
end
