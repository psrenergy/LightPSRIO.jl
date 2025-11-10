mutable struct Markdown <: AbstractElement
    content::Vector{String}

    function Markdown(content::Vector{String})
        return new(content)
    end
end
function Markdown()
    return Markdown(String[])
end
function Markdown(content::String)
    return Markdown([content])
end
@define_lua_struct Markdown

function add_from_file(L::LuaState, markdown::Markdown, filename::String)
    case = get_case(L, 1)

    path = joinpath(case.path, "$filename.md")
    if !isfile(path)
        error("Markdown file '$filename.md' not found in case path.")
    end

    content = read(path, String)
    add(markdown, content)
    return nothing
end
@define_lua_function add_from_file

function add(markdown::Markdown, content::String)
    push!(markdown.content, content)
    return nothing
end
@define_lua_function add

function create_patchwork(markdown::Markdown)
    return Patchwork.Markdown(join(markdown.content, "\n"))
end
