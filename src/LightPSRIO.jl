module LightPSRIO

using Base.Iterators
using EnumX
using LuaNova
using Quiver
using Statistics

const cases = Vector{String}()

include("optional.jl")
include("study.jl")
include("aggregate_functions.jl")

include("collections/collection.jl")
include("collections/collection_generic.jl")

include("attributes.jl")

include("expressions/expression.jl")
include("expressions/expression_aggregate.jl")
include("expressions/expression_data.jl")
include("expressions/expression_data_number.jl")
include("expressions/expression_data_quiver.jl")
include("expressions/expression_unary.jl")
include("expressions/expression_binary.jl")

include("state.jl")

function debug()
    push_case!(raw"C:\Development\PSRIO\LightPSRIO.jl\test")

    state = LightPSRIO.initialize()

    run(
        state,
        """
generic = Generic()
e1 = generic:load("demand1")
e2 = generic:load("demand1")
e = e1 + e2 + 1;
e:save("test1");
e = e1 * 2 + 1;
e:save("test2");

e = e1:aggregate("stage", BY_SUM());
e:save("test3");

-- julia_typeof(a)
""",
    )

    finalize(state)
    return nothing
end

# function debug5()
#     b = ExpressionDataNumber(3.0)
#     e = (5 + b) * b + 2
#     result = evaluate(e)
#     println("The result of $e is: $result")

#     e = @lazy_expression (5 + 3.0) * 3.0 + 2
#     result = evaluate(e)
#     println("The result of $e is: $result")

#     d1 = ExpressionDataQuiver()
#     d2 = ExpressionDataQuiver()

#     e = d1 + d2 + 1

#     for stage in 1:12
#         result = evaluate(e; stage = stage, scenario = 1)
#         println("The result of stage $stage is: $result")
#     end

#     close!(d1)
#     close!(d2)

#     return nothing
# end

end
