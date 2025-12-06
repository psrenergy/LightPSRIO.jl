module LightPSRIO

using ArgParse
using Base.Iterators
using Dates
using EnumX
using JSON
using Logging
using LuaNova
using Printf
using PSRDates
using Quiver
using Statistics
using UnitConverter
using UUIDs
using Unitful: @unit, Quantity, NoDims, @u_str, uconvert, ustrip

import Patchwork

@unit GWh "GWh" GigawattHour 1u"GW" * 1u"hr" false

const FAVORITE_UNITS = Set([
    "MWh",
    "GWh",
])

include("optional.jl")
include("util.jl")
include("units.jl")
include("aggregate_functions.jl")
include("profile_type.jl")
include("case.jl")

include("collections/collection.jl")
include("collections/collection_generic.jl")
include("collections/collection_study.jl")

include("attributes.jl")

include("expressions/expression.jl")
include("expressions/expression_null.jl")
include("expressions/get_attribute.jl")

# data expressions
include("expressions/data/number.jl")
include("expressions/data/quiver.jl")

# unary expressions
include("expressions/unary/aggregate_agents.jl")
include("expressions/unary/aggregate_dimensions.jl")
include("expressions/unary/convert.jl")
include("expressions/unary/profile.jl")
include("expressions/unary/rename_agents.jl")
include("expressions/unary/select_agents.jl")
include("expressions/unary/set_attribute.jl")
include("expressions/unary/replicate.jl")

# binary expressions
include("expressions/binary/binary.jl")

# variadic expressions
include("expressions/variadic/concatenate_agents.jl")
include("expressions/variadic/concatenate.jl")

# dashboard elements
include("dashboard/elements/highcharts.jl")
include("dashboard/elements/domain_type.jl")
include("dashboard/elements/series_type.jl")
include("dashboard/elements/element.jl")
include("dashboard/elements/layer.jl")
include("dashboard/elements/chart.jl")
include("dashboard/elements/markdown.jl")

# dashboard essentials
include("dashboard/tab.jl")
include("dashboard/dashboard.jl")

# lua state
include("state.jl")

function __init__()
    Unitful.register(LightPSRIO)
end

end
