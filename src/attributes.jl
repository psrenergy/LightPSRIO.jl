@kwdef mutable struct Attributes
    collection::Collection
    dimension_size::Vector{Int}
    dimensions::Vector{Symbol}
    frequency::String
    initial_date::DateTime
    labels::Vector{String}
    time_dimension::Symbol
    unit::String
end

function Attributes(quiver::Quiver.Reader)
    return Attributes(
        collection = Collection(),
        dimension_size = copy(quiver.metadata.dimension_size),
        dimensions = copy(quiver.metadata.dimensions),
        frequency = quiver.metadata.frequency,
        initial_date = quiver.metadata.initial_date,
        labels = copy(quiver.metadata.labels),
        time_dimension = quiver.metadata.time_dimension,
        unit = quiver.metadata.unit,
    )
end

function Base.:(==)(a::Attributes, b::Attributes)
    return a.dimensions == b.dimensions &&
           a.dimension_size == b.dimension_size &&
           a.unit == b.unit
end

function Base.copy(a::Attributes)
    return Attributes(
        collection = a.collection,
        dimension_size = copy(a.dimension_size),
        dimensions = copy(a.dimensions),
        frequency = a.frequency,
        initial_date = a.initial_date,
        labels = copy(a.labels),
        time_dimension = a.time_dimension,
        unit = a.unit,
    )
end

function Base.show(io::IO, attributes::Attributes)
    for (index, dimension) in enumerate(attributes.dimensions)
        print(io, "$dimension: 1:$(attributes.dimension_size[index]), ")
    end
    print(io, "unit: $(attributes.unit), agents: $(length(attributes.labels))")
    # print(io, "stages: 195 [1:195] [week] [40/2011], blocks: none, scenarios: 1, unit: , agents: 1 [study]")
    return nothing
end

function has_data(attributes::Attributes)
    return length(attributes.labels) > 0
end

function set_initial_year!(attributes::Attributes, year::Integer)
    dt = attributes.initial_date
    attributes.initial_date = DateTime(year, month(dt), day(dt), hour(dt), minute(dt), second(dt))
    return nothing
end

function get_filtered_dimensions_label(attributes::Attributes, kwargs)
    dimensions = Symbol[]
    for (index, dimension) in enumerate(attributes.dimensions)
        if attributes.dimension_size[index] > 1 && dimension != attributes.time_dimension
            push!(dimensions, dimension)
        end
    end
    return join(["$dimension=$(kwargs[dimension])" for dimension in dimensions], ", ")
end

function get_years(attributes::Attributes)
    if attributes.time_dimension in attributes.dimensions
        index = findfirst(==(attributes.time_dimension), attributes.dimensions)
        n_stages = attributes.dimension_size[index]
        if attributes.frequency == "month"
            return Int(ceil(n_stages / 12))
        else
            error("Unsupported frequency: $(attributes.frequency)")
        end
    end
    return 0
end

function get_date_reference(attributes::Attributes)
    month = Dates.month(attributes.initial_date)
    year = Dates.year(attributes.initial_date)

    if attributes.frequency == "month"
        return DateReference(StageType.MONTH, month, year)
    else
        error("Unsupported frequency: $(attributes.frequency)")
    end
end
