import Pkg
Pkg.instantiate()

case = ARGS[1]
script = ARGS[2]

using LightPSRIO
L = LightPSRIO.initialize([case])
LightPSRIO.run_file(L, script)
finalize(L)
