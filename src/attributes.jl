mutable struct Attributes
    labels::Vector{String}
    collection::Collection
    dimensions::Vector{Symbol}
    dimension_size::Vector{Int}
end

function Attributes(collection::Collection)
    return Attributes(String[], collection, Symbol[], Int[])
end

function Attributes(labels::Vector{String}, collection::Collection)
    return Attributes(labels, collection, Symbol[], Int[])
end

function Attributes(quiver::Quiver.Reader)
    labels = copy(quiver.metadata.labels)
    collection = Collection()
    dimensions = copy(quiver.metadata.dimensions)
    dimension_size = copy(quiver.metadata.dimension_size)
    return Attributes(labels, collection, dimensions, dimension_size)
end

function Base.:(==)(a::Attributes, b::Attributes)
    return a.dimensions == b.dimensions && a.dimension_size == b.dimension_size
end

function Base.copy(a::Attributes)
    return Attributes(
        copy(a.labels),
        a.collection,
        copy(a.dimensions),
        copy(a.dimension_size),
    )
end

function Base.show(io::IO, attributes::Attributes)
    for (index, dimension) in enumerate(attributes.dimensions)
        print(io, "$dimension: 1:$(attributes.dimension_size[index]), ")
    end
    print(io, "agents: $(length(attributes.labels))")
    # print(io, "stages: 195 [1:195] [week] [40/2011], blocks: none, scenarios: 1, unit: , agents: 1 [study]")
    return nothing
end

function has_data(attributes::Attributes)
    return length(attributes.labels) > 0
end
