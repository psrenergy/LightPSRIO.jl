mutable struct Dashboard
    tabs::Vector{Tab}

    function Dashboard()
        return new(Tab[])
    end
end
@define_lua_struct Dashboard

function push(dashboard::Dashboard, tab::Tab)
    push!(dashboard.tabs, tab)
    return nothing
end
@define_lua_function push

function save(L::LuaState, dashboard::Dashboard, filename::String)
    case = get_case(L, 1)

    file = open(joinpath(case.path, "$filename.html"), "w")
    
    write(file, """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/vue@3.3.4/dist/vue.global.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js@3.9.1/dist/chart.min.js"></script>
    <style>
        .tab-content {
            padding: 20px;
        }
        .chart-container {
            margin-bottom: 30px;
            padding: 20px;
            border: 1px solid #dee2e6;
            border-radius: 8px;
            background-color: #f8f9fa;
        }
        .chart-wrapper {
            position: relative;
            height: 400px;
            margin-top: 15px;
        }
        .nav-tabs .nav-link {
            color: #495057;
        }
        .nav-tabs .nav-link.active {
            color: #007bff;
            font-weight: bold;
        }
    </style>
</head>
<body>
    <div id="app" class="container-fluid py-4">
        <div class="row">
            <div class="col-12">
                <h1 class="mb-4">Dashboard</h1>
                
                <!-- Tab Navigation -->
                <ul class="nav nav-tabs" id="dashboardTabs" role="tablist">
                    <li class="nav-item" role="presentation" v-for="(tab, index) in tabs" :key="index">
                        <button class="nav-link" 
                                :class="{ active: activeTab === index }"
                                @click="activeTab = index"
                                type="button">
                            {{ tab.label }}
                        </button>
                    </li>
                </ul>
                
                <!-- Tab Content -->
                <div class="tab-content" id="dashboardTabContent">
                    <div v-for="(tab, tabIndex) in tabs" :key="tabIndex" 
                         v-show="activeTab === tabIndex" 
                         class="tab-pane fade" 
                         :class="{ 'show active': activeTab === tabIndex }">
                        
                        <h2 class="mt-3 mb-4">{{ tab.label }}</h2>
                        
                        <!-- Charts Grid -->
                        <div class="row">
                            <div v-for="(chart, chartIndex) in tab.charts" :key="chartIndex" 
                                 class="col-lg-6 col-md-12">
                                <div class="chart-container">
                                    <h4>{{ chart.title }}</h4>
                                    <div class="chart-wrapper">
                                        <canvas :id="'chart-' + tabIndex + '-' + chartIndex"></canvas>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        const { createApp } = Vue;
        
        createApp({
            data() {
                return {
                    activeTab: 0,
                    tabs: """)
    
    write(file, json_encode_dashboard(dashboard))
    
    write(file, """,
                    chartInstances: {}
                }
            },
            mounted() {
                this.\$nextTick(() => {
                    this.initializeCharts();
                });
            },
            watch: {
                activeTab(newTab, oldTab) {
                    this.\$nextTick(() => {
                        this.initializeChartsForTab(newTab);
                    });
                }
            },
            methods: {
                initializeCharts() {
                    this.tabs.forEach((tab, tabIndex) => {
                        if (tabIndex === this.activeTab) {
                            this.initializeChartsForTab(tabIndex);
                        }
                    });
                },
                initializeChartsForTab(tabIndex) {
                    const tab = this.tabs[tabIndex];
                    tab.charts.forEach((chart, chartIndex) => {
                        const chartId = 'chart-' + tabIndex + '-' + chartIndex;
                        const canvas = document.getElementById(chartId);
                        
                        if (canvas && !this.chartInstances[chartId]) {
                            const ctx = canvas.getContext('2d');
                            
                            const chartConfig = {
                                type: chart.chart_type,
                                data: this.prepareChartData(chart),
                                options: {
                                    responsive: true,
                                    maintainAspectRatio: false,
                                    plugins: {
                                        title: {
                                            display: true,
                                            text: chart.title
                                        },
                                        legend: {
                                            display: true,
                                            position: 'top'
                                        }
                                    },
                                    scales: this.getScaleConfig(chart.chart_type)
                                }
                            };
                            
                            this.chartInstances[chartId] = new Chart(ctx, chartConfig);
                        }
                    });
                },
                prepareChartData(chart) {
                    if (!chart.data || chart.data.length === 0) {
                        return {
                            labels: ['No Data'],
                            datasets: [{
                                label: 'No Data',
                                data: [0],
                                backgroundColor: 'rgba(108, 117, 125, 0.2)',
                                borderColor: 'rgba(108, 117, 125, 1)',
                                borderWidth: 1
                            }]
                        };
                    }
                    
                    const colors = [
                        'rgba(54, 162, 235, 0.8)',
                        'rgba(255, 99, 132, 0.8)',
                        'rgba(255, 205, 86, 0.8)',
                        'rgba(75, 192, 192, 0.8)',
                        'rgba(153, 102, 255, 0.8)',
                        'rgba(255, 159, 64, 0.8)'
                    ];
                    
                    const borderColors = [
                        'rgba(54, 162, 235, 1)',
                        'rgba(255, 99, 132, 1)',
                        'rgba(255, 205, 86, 1)',
                        'rgba(75, 192, 192, 1)',
                        'rgba(153, 102, 255, 1)',
                        'rgba(255, 159, 64, 1)'
                    ];
                    
                    if (chart.chart_type === 'pie' || chart.chart_type === 'doughnut') {
                        return {
                            labels: chart.data.map(d => d.label || d.x || 'Series'),
                            datasets: [{
                                data: chart.data.map(d => d.value || d.y || 0),
                                backgroundColor: colors,
                                borderColor: borderColors,
                                borderWidth: 1
                            }]
                        };
                    }
                    
                    const labels = chart.data.map(d => d.label || d.x || '');
                    const datasets = [{
                        label: chart.title,
                        data: chart.data.map(d => d.value || d.y || 0),
                        backgroundColor: colors[0],
                        borderColor: borderColors[0],
                        borderWidth: 2,
                        fill: chart.chart_type === 'line' ? false : true
                    }];
                    
                    return { labels, datasets };
                },
                getScaleConfig(chartType) {
                    if (chartType === 'pie' || chartType === 'doughnut') {
                        return {};
                    }
                    
                    return {
                        y: {
                            beginAtZero: true,
                            grid: {
                                color: 'rgba(0, 0, 0, 0.1)'
                            }
                        },
                        x: {
                            grid: {
                                color: 'rgba(0, 0, 0, 0.1)'
                            }
                        }
                    };
                }
            }
        }).mount('#app');
    </script>
</body>
</html>
""")
    
    close(file)
    return nothing
end

function json_encode_dashboard(dashboard::Dashboard)
    tabs_json = String[]
    
    for tab in dashboard.tabs
        charts_json = String[]
        
        for chart in tab.charts
            data_json = String[]
            for data_point in chart.data
                point_parts = String[]
                for (key, value) in data_point
                    if isa(value, String)
                        push!(point_parts, "\"$(key)\": \"$(escape_json(value))\"")
                    else
                        push!(point_parts, "\"$(key)\": $(value)")
                    end
                end
                push!(data_json, "{" * join(point_parts, ", ") * "}")
            end
            
            chart_json = """{
                "title": "$(escape_json(chart.title))",
                "chart_type": "$(escape_json(chart.chart_type))",
                "data": [$(join(data_json, ", "))]
            }"""
            push!(charts_json, chart_json)
        end
        
        tab_json = """{
            "label": "$(escape_json(tab.label))",
            "charts": [$(join(charts_json, ", "))]
        }"""
        push!(tabs_json, tab_json)
    end
    
    return "[" * join(tabs_json, ", ") * "]"
end

function escape_json(str::String)
    return replace(replace(replace(str, "\\" => "\\\\"), "\"" => "\\\""), "\n" => "\\n")
end
@define_lua_function save