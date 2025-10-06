mutable struct Tab
    label::String
    elements::Vector{<:AbstractElement}

    function Tab(label::String)
        return new(label, AbstractElement[])
    end
end
@define_lua_struct Tab

function push(tab::Tab, element::AbstractElement)
    push!(tab.elements, element)
    return nothing
end
@define_lua_function push

function create_patchwork(tab::Tab)
    return Patchwork.Tab(tab.label, [create_patchwork(element) for element in tab.elements])
end
