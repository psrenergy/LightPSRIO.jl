struct Highcharts <: Patchwork.Plugin
    title::String
    config::Dict{String, Any}

    function Highcharts(title::String, config::Dict{String, Any})
        return new(title, config)
    end
end

function Highcharts(title::String, config::AbstractString)
    return Highcharts(title, JSON.parse(config; allownan = true, dicttype = Dict{String, Any}))
end

function Patchwork.to_html(plugin::Highcharts)
    chart_id = "chart-$(uuid4())"
    # config_json = JSON.json(plugin.config; allownan = true, nan = "null", inf = "null", ninf = "null", pretty = false)
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
    # "https://code.highcharts.com/12.4.0/modules/exporting.js",
    "https://code.highcharts.com/12.4.0/modules/boost.js",
]

init_script(::Type{Highcharts}) = """
    document.querySelectorAll('.highcharts-chart').forEach(container => {
        const config = JSON.parse(container.getAttribute('data-config'));

        config.navigation = { buttonOptions: { align: 'left' } };

        config.exporting = {
            enabled: true,
            buttons: {
                contextButton: {
                    menuItems: [
                        'downloadPNG',
                        {
                            text: 'Show All Series',
                            onclick: function() {
                                this.series.forEach(series => {
                                    if (!series.visible) {
                                        series.setVisible(true, false);
                                    }
                                });
                                this.redraw();
                            }
                        },
                        {
                            text: 'Hide All Series',
                            onclick: function() {
                                this.series.forEach(series => {
                                    if (series.visible) {
                                        series.setVisible(false, false);
                                    }
                                });
                                this.redraw();
                            }
                        }                        
                    ]
                }
            }
        };
        
        Highcharts.chart(container.id, config);
    });
"""

Patchwork.css(::Type{Highcharts}) = ""
