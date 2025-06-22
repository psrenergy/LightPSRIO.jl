module TestAqua

using Aqua
using LazyEvaluation
using Test

@testset "Aqua" begin
    Aqua.test_ambiguities(LazyEvaluation, recursive = false)
    Aqua.test_all(LazyEvaluation, ambiguities = false)
    return nothing
end

end
