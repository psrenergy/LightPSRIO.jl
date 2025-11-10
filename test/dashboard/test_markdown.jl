module TestMarkdown

using Dates
using LightPSRIO
using Quiver
using Test

include("../conftest.jl")

@testset "Markdown" begin
    setup_tests(
        create_markdown("markdown1", "# Heading 1\n\nThis is a test of **Markdown** rendering."),
    ) do L
        LightPSRIO.run_script(
            L,
            """
local generic = Generic();
local markdown1 = generic:load_string("markdown1.md");
print(markdown1);

local tab = Tab("Tab 1");

local markdown = Markdown();
markdown:add(markdown1);
tab:push(markdown);

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
