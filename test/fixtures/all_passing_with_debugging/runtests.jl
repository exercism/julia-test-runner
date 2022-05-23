using Test

function f1(x)
    @show x # debugging
end

function f2(x)
    println("I'M HERE!")
    x
end

@testset "first test" begin
    @test f1(1) == 1
end

@testset "second test" begin
    @test f2(2) == 2
end
