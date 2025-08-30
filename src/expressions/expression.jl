abstract type Expression end

Base.promote_rule(::Type{<:Expression}, ::Type{<:Number}) = Expression
Base.promote_rule(::Type{<:Number}, ::Type{<:Expression}) = Expression

function has_data(e::Expression)
    return has_data(e.attributes)
end

function save(L::LuaState, e::Expression, filename::String)
    if !has_data(e)
        println("$filename not saved")
        return nothing
    end

    attributes = e.attributes
    labels = attributes.labels
    dimensions = attributes.dimensions
    dimension_size = attributes.dimension_size

    case = get_case(L, 1)

    println("Saving $filename ($attributes)")

    writer = Quiver.Writer{Quiver.binary}(
        joinpath(case.path, filename);
        labels = labels,
        dimensions = string.(dimensions),
        time_dimension = "stage",
        dimension_size = dimension_size,
        # initial_date = metadata.initial_date,
        # unit = metadata.unit,
        # frequency = metadata.frequency,
    )

    ranges = [1:size for size in dimension_size]
    reversed_ranges = reverse(ranges)
    iterator = (reverse(p) for p in Iterators.product(reversed_ranges...))

    start!(e)
    for indices in iterator
        kwargs = NamedTuple{Tuple(dimensions)}(indices)
        result = evaluate(e; kwargs...)
        Quiver.write!(writer, result; kwargs...)
    end
    finish!(e)

    Quiver.close!(writer)

    return nothing
end
@define_lua_function_with_state save

