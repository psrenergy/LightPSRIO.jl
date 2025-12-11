import Pkg
Pkg.instantiate()

using JuliaFormatter

if format(dirname(@__DIR__), verbose = true)
    @info "All files are properly formatted."
    exit(0)
else
    @error "Some files have not been formatted!"
    exit(1)
end
