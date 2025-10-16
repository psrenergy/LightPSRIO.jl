mutable struct ExpressionProfile <: AbstractUnary
    attributes::Attributes
    e1::AbstractExpression
    profile_type::ProfileType.T
    aggregate_function::AggregateFunction
    
    dimension_symbol::Symbol
    dimension_original_size::Int
end

function ExpressionProfile(e1::AbstractExpression, profile_type::ProfileType.T, aggregate_function::AggregateFunction)
    @if_expression_has_no_data_return_null e1

    attributes = copy(e1.attributes)

    # Use the time dimension from attributes
    dimension_symbol = :stage # attributes.time_dimension

    dimension_index = findfirst(==(dimension_symbol), attributes.dimensions)
    if dimension_index === nothing
        println("Time dimension $(dimension_symbol) not found (dimensions: $(attributes.dimensions))")
        return ExpressionNull()
    end

    dimension_original_size = attributes.dimension_size[dimension_index]

    # Calculate new dimension size based on profile type
    new_size = if profile_type == ProfileType.Day
        7  # Days in a week
    elseif profile_type == ProfileType.Week
        52  # Weeks in a year (approximate)
    elseif profile_type == ProfileType.Month
        12  # Months in a year
    elseif profile_type == ProfileType.Year
        1  # Single average per year
    else
        error("Unknown profile type: $(profile_type)")
    end

    attributes.dimension_size[dimension_index] = new_size

    @debug "PROFILE ($(dimension_symbol)): $(e1.attributes) -> $attributes"

    return ExpressionProfile(
        attributes,
        e1,
        profile_type,
        aggregate_function,
        dimension_symbol,
        dimension_original_size,
    )
end

@define_lua_struct ExpressionProfile

function day_profile(x::AbstractExpression, aggregate_function::AggregateFunction)
    return ExpressionProfile(x, ProfileType.Day, aggregate_function)
end
@define_lua_function day_profile

function week_profile(x::AbstractExpression, aggregate_function::AggregateFunction)
    return ExpressionProfile(x, ProfileType.Week, aggregate_function)
end
@define_lua_function week_profile

function month_profile(x::AbstractExpression, aggregate_function::AggregateFunction)
    return ExpressionProfile(x, ProfileType.Month, aggregate_function)
end
@define_lua_function month_profile

function year_profile(x::AbstractExpression, aggregate_function::AggregateFunction)
    return ExpressionProfile(x, ProfileType.Year, aggregate_function)
end
@define_lua_function year_profile

function evaluate(e::ExpressionProfile; kwargs...)
    if !has_data(e)
        return Float64[]
    end

    attributes = e.attributes
    labels_size = length(attributes.labels)
    dimension_original_size = e.dimension_original_size
    profile_type = e.profile_type
    aggregate_func = e.aggregate_function

    # Determine which period index we're computing for
    period_idx = get(kwargs, e.dimension_symbol, 1)

    # Collect all data points that belong to this period
    data_for_period = Vector{Vector{Float64}}()

    # Iterate through all original time steps
    for i in 1:dimension_original_size
        # Calculate which period this time step belongs to
        current_date = attributes.initial_date + Dates.Day(i - 1)

        belongs_to_period = if profile_type == ProfileType.Day
            dayofweek(current_date) == period_idx
        elseif profile_type == ProfileType.Week
            week(current_date) == period_idx
        elseif profile_type == ProfileType.Month
            month(current_date) == period_idx
        elseif profile_type == ProfileType.Year
            true  # All data belongs to single yearly average
        else
            false
        end

        if belongs_to_period
            modified_kwargs = merge(
                NamedTuple(kwargs),
                NamedTuple{(e.dimension_symbol,)}((i,)),
            )

            current_value = evaluate(e.e1; modified_kwargs...)
            push!(data_for_period, current_value)
        end
    end

    # If no data for this period, return zeros
    if isempty(data_for_period)
        return zeros(labels_size)
    end

    # Apply the aggregation function
    if aggregate_func.type == AggregateType.Sum
        return sum(data_for_period)
    elseif aggregate_func.type == AggregateType.Average
        return mean(data_for_period)
    elseif aggregate_func.type == AggregateType.Min
        return minimum(data_for_period)
    elseif aggregate_func.type == AggregateType.Max
        return maximum(data_for_period)
    elseif aggregate_func.type == AggregateType.Percentile
        return [quantile(vcat(data_for_period...), aggregate_func.parameter)]
    else
        error("Aggregate function $(aggregate_func) not implemented yet.")
    end
end
