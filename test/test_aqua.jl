module TestAqua

using Aqua
using LightPSRIO
using Test

@testset "Aqua" begin
    Aqua.test_ambiguities(LightPSRIO, recursive = false)
    Aqua.test_all(LightPSRIO, ambiguities = false)
    return nothing
end

end
