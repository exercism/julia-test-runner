using Test

@testset "first test" begin
    f(x) = @show x
    @test f(1) == 1
end

@testset "second test" begin
    @test 1 == 2
end

@testset "third test" begin
    @test error("")
end
