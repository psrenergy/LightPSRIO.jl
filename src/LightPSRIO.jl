module LightPSRIO

using Base.Iterators
using EnumX
using LuaNova
using Quiver
using Statistics

include("optional.jl")
include("aggregate_functions.jl")
include("case.jl")

include("collections/collection.jl")
include("collections/collection_generic.jl")
include("collections/collection_study.jl")

include("attributes.jl")

include("expressions/expression.jl")
include("expressions/expression_aggregate_agents.jl")
include("expressions/expression_aggregate_dimensions.jl")
include("expressions/expression_binary.jl")
include("expressions/expression_concatenate_agents.jl")
include("expressions/expression_data_number.jl")
include("expressions/expression_data_quiver.jl")
include("expressions/expression_unary.jl")

include("state.jl")

end
