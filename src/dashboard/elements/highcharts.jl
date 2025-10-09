struct Highcharts <: Patchwork.Plugin
    title::String
    config::JSON.Object

    function Highcharts(title::String, config::JSON.Object)
        return new(title, config)
    end
end

function Highcharts(title::String, config::AbstractString)
    return Highcharts(title, JSON.parse(config))
end

function Patchwork.to_html(plugin::Highcharts)
    chart_id = "chart-$(uuid4())"
    config_json = JSON.json(plugin.config)

    return """
    <div>
        <h3 class="text-lg font-semibold mb-4">$(plugin.title)</h3>
        <div id="$chart_id" class="highcharts-chart" data-config='$config_json' style="height: 400px;"></div>
    </div>
    """
end

Patchwork.css_deps(::Type{Highcharts}) = String[]

Patchwork.js_deps(::Type{Highcharts}) = [
    "https://code.highcharts.com/12.4.0/highcharts.js",
    "https://code.highcharts.com/12.4.0/highcharts-more.js",
    "https://code.highcharts.com/12.4.0/modules/exporting.js",
]

Patchwork.init_script(::Type{Highcharts}) = """
    document.querySelectorAll('.highcharts-chart').forEach(container => {
        const config = JSON.parse(container.getAttribute('data-config'));
        Highcharts.chart(container.id, config);
    });
"""

Patchwork.css(::Type{Highcharts}) = ""
