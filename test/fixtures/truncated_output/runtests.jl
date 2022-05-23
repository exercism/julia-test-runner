using Test

@testset "first test" begin
    f(x) = (println("x"^5000); x)
    @test f(1) == 1
end
