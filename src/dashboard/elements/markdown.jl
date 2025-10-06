mutable struct Markdown <: AbstractElement
    content::Vector{String}

    function Markdown()
        return new(String[])
    end
end
@define_lua_struct Markdown

function add(markdown::Markdown, content::String)
    push!(markdown.content, content)
    return nothing
end
@define_lua_function add

function create_patchwork(markdown::Markdown)
    return Patchwork.Markdown(join(markdown.content, "\n\n"))
end
