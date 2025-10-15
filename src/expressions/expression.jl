abstract type AbstractExpression end

Base.promote_rule(::Type{<:AbstractExpression}, ::Type{<:Number}) = AbstractExpression
Base.promote_rule(::Type{<:Number}, ::Type{<:AbstractExpression}) = AbstractExpression

function has_data(e::AbstractExpression)
    if e isa ExpressionNull
        return false
    end
    return has_data(e.attributes)
end

function Base.eachindex(e::AbstractExpression)
    attributes = e.attributes
    dimensions = attributes.dimensions
    dimension_size = attributes.dimension_size

    ranges = [1:size for size in dimension_size]
    reversed_ranges = reverse(ranges)
    iterator = (reverse(p) for p in Iterators.product(reversed_ranges...))

    vector = Vector{NamedTuple}()
    for it in iterator
        kwargs = NamedTuple{Tuple(dimensions)}(it)
        push!(vector, kwargs)
    end
    return vector
end

function save(L::LuaState, e::AbstractExpression, filename::String)
    if !has_data(e)
        println("$filename not saved")
        return nothing
    end

    case = get_case(L, 1)

    a = e.attributes
    println("Saving $filename ($a)")

    writer = Quiver.Writer{Quiver.binary}(
        joinpath(case.path, filename);
        labels = a.labels,
        dimensions = string.(a.dimensions),
        time_dimension = "stage",
        dimension_size = a.dimension_size,
        initial_date = a.initial_date,
        unit = a.unit,
        # frequency = metadata.frequency,
    )

    start!(e)
    for kwargs in eachindex(e)
        result = evaluate(e; kwargs...)
        Quiver.write!(writer, result; kwargs...)
    end
    finish!(e)

    Quiver.close!(writer)

    return nothing
end
@define_lua_function save

abstract type AbstractUnary <: AbstractExpression end

function start!(e::AbstractUnary)
    start!(e.e1)
    return nothing
end

function finish!(e::AbstractUnary)
    finish!(e.e1)
    return nothing
end

abstract type AbstractBinary <: AbstractExpression end

function start!(e::AbstractBinary)
    start!(e.e1)
    start!(e.e2)
    return nothing
end

function finish!(e::AbstractBinary)
    finish!(e.e1)
    finish!(e.e2)
    return nothing
end

abstract type AbstractVariadic <: AbstractExpression end

function start!(e::AbstractVariadic)
    for expression in e.expressions
        start!(expression)
    end
    return nothing
end

function finish!(e::AbstractVariadic)
    for expression in e.expressions
        finish!(expression)
    end
    return nothing
end
