struct Attributes
    labels::Vector{String}
    dimensions::Vector{Symbol}
    dimension_size::Vector{Int}
end

function Attributes(labels::Vector{String})
    return Attributes(labels, Symbol[], Int[])
end

function Attributes(quiver::Quiver.Reader)
    labels = copy(quiver.metadata.labels)
    dimensions = copy(quiver.metadata.dimensions)
    dimension_size = copy(quiver.metadata.dimension_size)
    return Attributes(labels, dimensions, dimension_size)
end

function Base.:(==)(a::Attributes, b::Attributes)
    return a.dimensions == b.dimensions && a.dimension_size == b.dimension_size
end

function Base.copy(a::Attributes)
    return Attributes(
        copy(a.labels),
        copy(a.dimensions),
        copy(a.dimension_size),
    )
end