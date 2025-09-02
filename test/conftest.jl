function create_quiver(filename; n_stages::Integer, n_blocks::Integer, n_scenarios::Integer, constant::Float64, unit::String)
    writer = Quiver.Writer{Quiver.binary}(
        joinpath(@__DIR__, "data", filename);
        dimensions = ["stage", "scenario", "block"],
        labels = ["data_stage", "data_scenario", "data_block", "data_constant"],
        time_dimension = "stage",
        dimension_size = [n_stages, n_scenarios, n_blocks],
        initial_date = DateTime(2024, 1, 1),
        unit = unit,
    )

    for stage in 1:n_stages
        for scenario in 1:n_scenarios
            for block in 1:n_blocks
                data = Float64[stage, scenario, block, constant]
                Quiver.write!(writer, data; stage, scenario, block)
            end
        end
    end

    Quiver.close!(writer)

    return nothing
end

function delete_quiver(filename::String)
    rm(joinpath(@__DIR__, "data", "$filename.toml"))
    rm(joinpath(@__DIR__, "data", "$filename.quiv"))
    return nothing
end

function open_quiver(filename::String)
    return Quiver.Reader{Quiver.binary}(joinpath(@__DIR__, "data", filename))
end

function close_quiver(reader::Quiver.Reader)
    Quiver.close!(reader)
    return nothing
end

function load_quiver_as_df(filename::String)
    return Quiver.file_to_df(joinpath(@__DIR__, "data", filename), Quiver.binary)
end

function create_quiver_tests(filename::String)
    println("$filename = open_quiver(\"$filename\")")

    quiver = open_quiver(filename)
    n_stages = quiver.metadata.dimension_size[1]
    n_scenarios = quiver.metadata.dimension_size[2]
    n_blocks = quiver.metadata.dimension_size[3]

    for stage in 1:n_stages
        for scenario in 1:n_scenarios
            for block in 1:n_blocks
                data = Quiver.goto!(quiver; stage = stage, scenario = scenario, block = block)
                println("@test Quiver.goto!($filename; stage = $stage, scenario = $scenario, block = $block) ≈ [$(join(data, ", "))]")
            end
        end
    end
    close_quiver(quiver)

    println("close_quiver($filename)\n")

    return nothing
end

function get_data_directory()
    return joinpath(@__DIR__, "data")
end

function initialize_tests()
    create_quiver("input1"; n_stages = 2, n_scenarios = 2, n_blocks = 2, constant = 2.0, unit = "GWh")
    create_quiver("input2"; n_stages = 2, n_scenarios = 2, n_blocks = 2, constant = 2.0, unit = "MWh")
    return nothing
end

function finalize_tests()
    path = get_data_directory()
    for file in readdir(path)
        if endswith(file, ".toml") || endswith(file, ".quiv")
            rm(joinpath(path, file))
        end
    end
    return nothing
end
