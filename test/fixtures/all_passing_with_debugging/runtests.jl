using Test

@testset "first test" begin
    x = 1
    @show x # Debugging
    @test x == 1
end

@testset "second test" begin
    println("I'M HERE!")
    @test 2 == 2
end
