struct Attributes
    labels::Vector{String}
    collection::Collection
    dimensions::Vector{Symbol}
    dimension_size::Vector{Int}
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