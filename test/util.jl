function create_quiver(filename; n_stages::Integer, n_blocks::Integer, n_scenarios::Integer, constant::Float64)
    writer = Quiver.Writer{Quiver.binary}(
        joinpath(@__DIR__, "data", filename);
        dimensions = ["stage", "scenario", "block"],
        labels = ["data_stage", "data_scenario", "data_block", "data_constant"],
        time_dimension = "stage",
        dimension_size = [n_stages, n_scenarios, n_blocks],
        initial_date = DateTime(2024, 1, 1),
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

function load_quiver(filename::String)
    return Quiver.Reader{Quiver.binary}(joinpath(@__DIR__, "data", filename))
end

function load_quiver_as_df(filename::String)
    return Quiver.file_to_df(joinpath(@__DIR__, "data", filename), Quiver.binary)
end

function create_tests(filename::String)
    quiver = load_quiver(filename)
    n_stages = quiver.metadata.dimension_size[1]
    n_scenarios = quiver.metadata.dimension_size[2]
    n_blocks = quiver.metadata.dimension_size[3]

    println("$filename = load_quiver(\"$filename\")")

    for stage in 1:n_stages
        for scenario in 1:n_scenarios
            for block in 1:n_blocks
                data = Quiver.goto!(quiver; stage = stage, scenario = scenario, block = block)
                println("Quiver.goto!($filename; stage = $stage, scenario = $scenario, block = $block) ≈ [$(join(data, ", "))]")
            end
        end
    end

    println("Quiver.close!($filename)")

    return nothing
end