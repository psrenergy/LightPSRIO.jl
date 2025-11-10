module TestDashboard

using Dates
using LightPSRIO
using Quiver
using Test

include("../conftest.jl")

@testset "Dashboard" begin
    setup_tests(
        create_markdown("markdown1", "# Heading 1\n\nThis is a test of **Markdown** rendering."),
    ) do L
        LightPSRIO.run_script(
            L,
            """
local generic = Generic();
local input1 = generic:load("input_year");

local tab = Tab("Tab 1");

local markdown = Markdown();
tab:add_from_file(markdown, "markdown1");

local dashboard = Dashboard("PSR");
dashboard:push(tab);
dashboard:save("test_markdown");
""",
        )

        return nothing
    end

    return nothing
end

end
