@kwdef mutable struct Attributes
    initial_date::DateTime
    labels::Vector{String}
    collection::Collection
    dimensions::Vector{Symbol}
    dimension_size::Vector{Int}
    unit::String
end

function Attributes(quiver::Quiver.Reader)
    return Attributes(
        initial_date = quiver.metadata.initial_date,
        labels = copy(quiver.metadata.labels),
        collection = Collection(),
        dimensions = copy(quiver.metadata.dimensions),
        dimension_size = copy(quiver.metadata.dimension_size),
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
        initial_date = a.initial_date,
        labels = copy(a.labels),
        collection = a.collection,
        dimensions = copy(a.dimensions),
        dimension_size = copy(a.dimension_size),
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

function get_filtered_dimensions_label(attributes::Attributes, kwargs)
    dimensions = Symbol[]
    for (index, dimension) in enumerate(attributes.dimensions)
        if attributes.dimension_size[index] > 1 && dimension != :stage
            push!(dimensions, dimension)
        end
    end
    return join(["$dimension=$(kwargs[dimension])" for dimension in dimensions], ", ")
end
