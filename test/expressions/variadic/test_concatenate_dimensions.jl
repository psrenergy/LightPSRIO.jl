module TestConcatenateDimensions

using DataFrames
using Dates
using LightPSRIO
using Quiver
using Test

include("../../conftest.jl")

function create_stage_data(filename; n_stages::Integer, start_value::Float64)
    # Create data where values start from start_value
    writer = Quiver.Writer{Quiver.binary}(
        joinpath(get_data_directory(), filename);
        dimensions = ["stage", "scenario", "block"],
        labels = ["agent1", "agent2"],
        time_dimension = "stage",
        dimension_size = [n_stages, 2, 2],
        initial_date = DateTime(2024, 1, 1),
        unit = "MWh",
    )

    for stage in 1:n_stages
        for scenario in 1:2
            for block in 1:2
                # Values based on start_value + stage
                data = Float64[start_value + stage, (start_value + stage) * 2]
                Quiver.write!(writer, data; stage, scenario, block)
            end
        end
    end

    Quiver.close!(writer)

    return nothing
end

@testset "Concatenate Dimensions - Stage" begin
    initialize_tests()

    # Create three separate time series: stages 1-3, 4-6, 7-9
    create_stage_data("stages_1_3"; n_stages = 3, start_value = 0.0)
    create_stage_data("stages_4_6"; n_stages = 3, start_value = 3.0)
    create_stage_data("stages_7_9"; n_stages = 3, start_value = 6.0)

    L = LightPSRIO.initialize([get_data_directory()])

    LightPSRIO.run_script(
        L,
        """
local generic = Generic();
local part1 = generic:load("stages_1_3");
local part2 = generic:load("stages_4_6");
local part3 = generic:load("stages_7_9");

-- Concatenate along stage dimension
local combined = concatenate_dimensions("stage", part1, part2, part3);
combined:save("stages_concatenated");
    """,
    )

    finalize(L)

    # Verify the concatenated result has 9 stages
    open_quiver("stages_concatenated") do q
        @test q.metadata.unit == "MWh"
        @test q.metadata.dimension_size == [9, 2, 2]
        @test q.metadata.labels == ["agent1", "agent2"]

        # Test values from first part (stages 1-3)
        @test Quiver.goto!(q; stage = 1, scenario = 1, block = 1) ≈ [1.0, 2.0]
        @test Quiver.goto!(q; stage = 2, scenario = 1, block = 1) ≈ [2.0, 4.0]
        @test Quiver.goto!(q; stage = 3, scenario = 1, block = 1) ≈ [3.0, 6.0]

        # Test values from second part (stages 4-6)
        @test Quiver.goto!(q; stage = 4, scenario = 1, block = 1) ≈ [4.0, 8.0]
        @test Quiver.goto!(q; stage = 5, scenario = 1, block = 1) ≈ [5.0, 10.0]
        @test Quiver.goto!(q; stage = 6, scenario = 1, block = 1) ≈ [6.0, 12.0]

        # Test values from third part (stages 7-9)
        @test Quiver.goto!(q; stage = 7, scenario = 1, block = 1) ≈ [7.0, 14.0]
        @test Quiver.goto!(q; stage = 8, scenario = 1, block = 1) ≈ [8.0, 16.0]
        @test Quiver.goto!(q; stage = 9, scenario = 1, block = 1) ≈ [9.0, 18.0]

        # Test other scenario and block combinations
        @test Quiver.goto!(q; stage = 5, scenario = 2, block = 2) ≈ [5.0, 10.0]
    end

    delete_files(["stages_1_3", "stages_4_6", "stages_7_9", "stages_concatenated"])

    return nothing
end

@testset "Concatenate Dimensions - Scenario" begin
    initialize_tests()

    L = LightPSRIO.initialize([get_data_directory()])

    LightPSRIO.run_script(
        L,
        """
local generic = Generic();
local input1 = generic:load("input1");
local input2 = generic:load("input2");

-- Both have 2 scenarios, concatenate to get 4 scenarios
local combined = concatenate_dimensions("scenario", input1, input2);
combined:save("scenarios_concatenated");
    """,
    )

    finalize(L)

    open_quiver("scenarios_concatenated") do q
        @test q.metadata.dimension_size == [2, 4, 2]

        # First 2 scenarios from input1 (unit: GWh)
        @test Quiver.goto!(q; stage = 1, scenario = 1, block = 1) ≈ [1.0, 1.0, 1.0, 2.0]
        @test Quiver.goto!(q; stage = 1, scenario = 2, block = 1) ≈ [1.0, 2.0, 1.0, 2.0]

        # Last 2 scenarios from input2 (unit: MWh, but same values)
        @test Quiver.goto!(q; stage = 1, scenario = 3, block = 1) ≈ [1.0, 1.0, 1.0, 2.0]
        @test Quiver.goto!(q; stage = 1, scenario = 4, block = 1) ≈ [1.0, 2.0, 1.0, 2.0]
    end

    delete_files(["scenarios_concatenated"])

    return nothing
end

@testset "Concatenate Dimensions - Block" begin
    initialize_tests()

    L = LightPSRIO.initialize([get_data_directory()])

    LightPSRIO.run_script(
        L,
        """
local generic = Generic();
local input1 = generic:load("input1");

-- Concatenate input1 with itself along block dimension
local combined = concatenate_dimensions("block", input1, input1);
combined:save("blocks_concatenated");
    """,
    )

    finalize(L)

    open_quiver("blocks_concatenated") do q
        @test q.metadata.dimension_size == [2, 2, 4]

        # First 2 blocks from first input1
        @test Quiver.goto!(q; stage = 1, scenario = 1, block = 1) ≈ [1.0, 1.0, 1.0, 2.0]
        @test Quiver.goto!(q; stage = 1, scenario = 1, block = 2) ≈ [1.0, 1.0, 2.0, 2.0]

        # Last 2 blocks from second input1
        @test Quiver.goto!(q; stage = 1, scenario = 1, block = 3) ≈ [1.0, 1.0, 1.0, 2.0]
        @test Quiver.goto!(q; stage = 1, scenario = 1, block = 4) ≈ [1.0, 1.0, 2.0, 2.0]
    end

    delete_files(["blocks_concatenated"])

    return nothing
end

@testset "Concatenate Dimensions - Combined Operations" begin
    initialize_tests()

    create_stage_data("series1"; n_stages = 5, start_value = 0.0)
    create_stage_data("series2"; n_stages = 5, start_value = 10.0)

    L = LightPSRIO.initialize([get_data_directory()])

    LightPSRIO.run_script(
        L,
        """
local generic = Generic();
local s1 = generic:load("series1");
local s2 = generic:load("series2");

-- Concatenate and then aggregate
local combined = concatenate_dimensions("stage", s1, s2);
local avg = combined:aggregate("stage", BY_AVERAGE());
avg:save("concat_then_aggregate");

-- Concatenate profiles
local s1_profile = s1:profile("stage", BY_MONTH(BY_AVERAGE()));
local s2_profile = s2:profile("stage", BY_MONTH(BY_AVERAGE()));
local profiles_concat = concatenate_dimensions("stage", s1_profile, s2_profile);
profiles_concat:save("profiles_concatenated");
    """,
    )

    finalize(L)

    open_quiver("concat_then_aggregate") do q
        @test q.metadata.dimension_size == [1, 2, 2]
        # Average of stages 1-10: (1+2+...+10 + 11+12+...+20) / 2 = (55 + 155) / 2 = 105, but our formula is start+stage
        # So it's (0+1 + 0+2 + ... + 0+5 + 10+1 + 10+2 + ... + 10+5) / 10 = (15 + 65) / 10 = 8.0
        @test Quiver.goto!(q; stage = 1, scenario = 1, block = 1)[1] ≈ 8.0
    end

    open_quiver("profiles_concatenated") do q
        # Each series has 5 stages, profiles to 12 months, concat gives 24 stages
        @test q.metadata.dimension_size == [24, 2, 2]
    end

    delete_files(["series1", "series2", "concat_then_aggregate", "profiles_concatenated"])

    return nothing
end

@testset "Concatenate Dimensions - Error Cases" begin
    initialize_tests()

    L = LightPSRIO.initialize([get_data_directory()])

    # Test concatenating with incompatible units
    LightPSRIO.run_script(
        L,
        """
local generic = Generic();
local input1 = generic:load("input1");  -- GWh
local input2 = generic:load("input2");  -- MWh

-- This should fail because units don't match
local result = concatenate_dimensions("stage", input1, input2);
if result:has_data() then
    result:save("should_not_exist_1");
end
    """,
    )

    # Test concatenating on non-existent dimension
    LightPSRIO.run_script(
        L,
        """
local generic = Generic();
local input1 = generic:load("input1");

-- This should fail because "nonexistent" is not a valid dimension
local result = concatenate_dimensions("nonexistent", input1, input1);
if result:has_data() then
    result:save("should_not_exist_2");
end
    """,
    )

    finalize(L)

    # Verify error cases didn't create output
    @test !isfile(joinpath(get_data_directory(), "should_not_exist_1"))
    @test !isfile(joinpath(get_data_directory(), "should_not_exist_2"))

    return nothing
end

end
