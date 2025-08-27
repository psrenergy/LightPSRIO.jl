function create_quiver(filename, data)
    n_agents, n_blocks, n_scenarios, n_stages = size(data)

    return Quiver.array_to_file(
        filename,
        data,
        Quiver.csv;
        dimensions = ["stage", "scenario", "block"],
        labels = ["agent $i" for i in 1:n_agents],
        time_dimension = "stage",
        dimension_size = [n_stages, n_scenarios, n_blocks],
        initial_date = DateTime(2024, 1, 1),
    )

    return nothing
end

# function create_quiver(; n_stages::Integer, n_scenarios::Integer, n_blocks::Integer)
#     filename = "t$(n_stages)_s$(n_scenarios)_b$(n_blocks)"

#     writer = Quiver.Writer{Quiver.csv}(
#         filename;
#         dimensions = ["stage", "scenario", "block"],
#         labels = ["agent 1", "agent 2", "agent 3"],
#         time_dimension = "stage",
#         dimension_size = [n_stages, n_scenarios, n_blocks],
#         initial_date = DateTime(2024, 1, 1),
#     )

#     for stage in 1:n_stages
#         for scenario in 1:n_scenarios
#             for block in 1:n_blocks
#                 Quiver.write!(writer, [stage, scenario, block]; stage = stage, scenario = scenario, block = block)
#             end
#         end
#     end

#     Quiver.close!(writer)

#     return filename
# end

# function verify_quiver(filename::String; n_stages::Integer, n_scenarios::Integer, n_blocks::Integer, n_agents::Integer)
#     @show reader = Quiver.Reader{Quiver.csv}(filename)
#     @show reader.metadata.dimensions

#     # @assert reader.metadata.dimensions == ["stage", "scenario", "block"]

#     Quiver.close!(reader)

#     return nothing
# end

# function create_df(filename; n_stages::Integer, n_scenarios::Integer, n_blocks::Integer)
#     stages = Int[]
#     scenarios = Int[]
#     blocks = Int[]
#     data = [Int[] for _ in 1:3]

#     for stage in 1:n_stages
#         for scenario in 1:n_scenarios
#             for block in 1:n_blocks
#                 push!(stages, stage)
#                 push!(scenarios, scenario)
#                 push!(blocks, block)
#                 push!(data[1], stage)
#                 push!(data[2], scenario)
#                 push!(data[3], block)
#             end
#         end
#     end

#     df = DataFrame(
#         stage = stages,
#         scenario = scenarios,
#         block = blocks,
#         agent_1 = data[1],
#         agent_2 = data[2],
#         agent_3 = data[3],
#     )

#     Quiver.df_to_file(
#         joinpath(@__DIR__, filename),
#         df,
#         Quiver.csv;
#         dimensions = ["stage", "scenario", "block"],
#         labels = ["agent_1", "agent_2", "agent_3"],
#         time_dimension = "stage",
#         dimension_size = [n_stages, n_scenarios, n_blocks],
#         initial_date = DateTime(2024, 1, 1),
#         unit = "",
#     )

#     return df
# end
