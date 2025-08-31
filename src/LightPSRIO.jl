module LightPSRIO

using Base.Iterators
using EnumX
using LuaNova
using Quiver
using Statistics

include("util.jl")
include("aggregate_functions.jl")
include("case.jl")

include("collections/collection.jl")
include("collections/collection_generic.jl")
include("collections/collection_study.jl")

include("attributes.jl")

include("expressions/expression.jl")

# data expressions
include("expressions/data/number.jl")
include("expressions/data/quiver.jl")

# unary expressions
include("expressions/unary/convert.jl")
include("expressions/unary/aggregate_agents.jl")
include("expressions/unary/aggregate_dimensions.jl")

# binary expressions
include("expressions/binary/binary.jl")

# variadic
include("expressions/variadic/concatenate_agents.jl")

include("dashboard/chart.jl")
include("dashboard/tab.jl")
include("dashboard/dashboard.jl")

include("state.jl")

end
