using Test

@testset "first test" begin
    println("x"^5000)
    @test 1 == 1
end
