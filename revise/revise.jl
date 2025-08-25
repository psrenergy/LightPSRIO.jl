import Pkg
Pkg.instantiate()

using Revise

Pkg.activate(dirname(@__DIR__))
Pkg.instantiate()

using LightPSRIO
@info("""
This session is using LightPSRIO.jl with Revise.jl.
For more information visit https://timholy.github.io/Revise.jl/stable/.
""")
