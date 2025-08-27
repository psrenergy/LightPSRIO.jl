abstract type Expression end

Base.promote_rule(::Type{<:Expression}, ::Type{<:Number}) = Expression
Base.promote_rule(::Type{<:Number}, ::Type{<:Expression}) = Expression

function save(e::Expression, filename::String)
    println("Saving expression data to $filename")

    attributes = e.attributes
    labels = attributes.labels
    dimensions = attributes.dimensions
    dimension_size = attributes.dimension_size

    path = raw"C:\Development\PSRIO\LightPSRIO.jl\test"

    writer = Quiver.Writer{Quiver.csv}(
        joinpath(path, filename);
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
    iterators = (reverse(p) for p in Iterators.product(reversed_ranges...))

    start!(e)
    for indices in iterators
        kwargs = NamedTuple{Tuple(dimensions)}(indices)
        result = evaluate(e; kwargs...)
        println("The result for $kwargs is: $result")

        Quiver.write!(writer, result; kwargs...)
    end
    finish!(e)

    Quiver.close!(writer)

    return nothing
end
@define_lua_function save

