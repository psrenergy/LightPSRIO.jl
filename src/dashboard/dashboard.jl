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

    write(
        file,
        """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard</title>
    <script src="https://cdn.tailwindcss.com/3.4.0"></script>
    <script src="https://cdn.jsdelivr.net/npm/vue@3.3.4/dist/vue.global.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js@3.9.1/dist/chart.min.js"></script>
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    colors: {
                        'dashboard-blue': '#3b82f6',
                        'dashboard-gray': '#f8fafc',
                        'chart-border': '#e2e8f0'
                    }
                }
            }
        }
    </script>
</head>
<body class="bg-gray-50 min-h-screen">
    <div id="app" class="container mx-auto px-4 py-8 max-w-7xl">
        <div class="mb-8">
            <h1 class="text-4xl font-bold text-gray-900 mb-2">Dashboard</h1>
            <p class="text-gray-600">Interactive data visualization</p>
        </div>
        
        <!-- Search Bar -->
        <div class="mb-6">
            <div class="relative max-w-md">
                <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                    <svg class="h-5 w-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path>
                    </svg>
                </div>
                <input v-model="searchQuery" 
                       type="text" 
                       class="block w-full pl-10 pr-3 py-2 border border-gray-300 rounded-md leading-5 bg-white placeholder-gray-500 focus:outline-none focus:placeholder-gray-400 focus:ring-1 focus:ring-dashboard-blue focus:border-dashboard-blue text-sm" 
                       placeholder="Search charts...">
                <div v-if="searchQuery" 
                     @click="searchQuery = ''" 
                     class="absolute inset-y-0 right-0 pr-3 flex items-center cursor-pointer">
                    <svg class="h-5 w-5 text-gray-400 hover:text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
                    </svg>
                </div>
            </div>
        </div>

        <!-- Tab Navigation -->
        <div class="mb-6">
            <nav class="flex space-x-1 bg-gray-100 p-1 rounded-lg shadow-sm">
                <button v-for="(tab, index) in tabs" :key="index"
                        @click="activeTab = index"
                        :class="[
                            'px-4 py-2 text-sm font-medium rounded-md transition-all duration-200',
                            activeTab === index 
                                ? 'bg-white text-dashboard-blue shadow-sm ring-1 ring-dashboard-blue/20' 
                                : 'text-gray-600 hover:text-gray-900 hover:bg-gray-200'
                        ]">
                    {{ tab.label }}
                    <span v-if="searchQuery && getFilteredChartsForTab(index).length > 0" 
                          class="ml-2 inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium bg-dashboard-blue text-white">
                        {{ getFilteredChartsForTab(index).length }}
                    </span>
                </button>
            </nav>
        </div>
        
        <!-- Tab Content -->
        <div class="space-y-6">
            <div v-for="(tab, tabIndex) in tabs" :key="tabIndex" 
                 v-show="activeTab === tabIndex"
                 class="animate-fadeIn">
                
                <div class="mb-6">
                    <h2 class="text-2xl font-semibold text-gray-800 mb-2">{{ tab.label }}</h2>
                    <div class="h-0.5 w-20 bg-dashboard-blue rounded"></div>
                </div>
                
                <!-- Charts Grid -->
                <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
                    <div v-for="(chart, chartIndex) in getFilteredChartsForTab(tabIndex)" :key="chartIndex" 
                         class="bg-white rounded-xl shadow-sm border border-gray-200 p-6 hover:shadow-md transition-shadow duration-200">
                        <div class="mb-4">
                            <h3 class="text-lg font-semibold text-gray-800" v-html="highlightSearchTerm(chart.title)"></h3>
                            <div class="text-sm text-gray-500 capitalize">{{ chart.chart_type }} chart</div>
                        </div>
                        <div class="relative h-80">
                            <canvas :id="'chart-' + tabIndex + '-' + chart.originalIndex" 
                                    class="max-w-full max-h-full"></canvas>
                        </div>
                    </div>
                </div>
                
                <!-- No Search Results -->
                <div v-if="searchQuery && getFilteredChartsForTab(tabIndex).length === 0" 
                     class="text-center py-12 bg-white rounded-xl border border-gray-200">
                    <div class="w-16 h-16 mx-auto mb-4 bg-gray-100 rounded-full flex items-center justify-center">
                        <svg class="w-8 h-8 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path>
                        </svg>
                    </div>
                    <h3 class="text-lg font-medium text-gray-900 mb-2">No charts found</h3>
                    <p class="text-gray-500">No charts match your search query "{{ searchQuery }}"</p>
                </div>
                
                <!-- Empty State -->
                <div v-else-if="!searchQuery && tab.charts.length === 0" 
                     class="text-center py-12 bg-white rounded-xl border border-gray-200">
                    <div class="w-16 h-16 mx-auto mb-4 bg-gray-100 rounded-full flex items-center justify-center">
                        <svg class="w-8 h-8 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"></path>
                        </svg>
                    </div>
                    <h3 class="text-lg font-medium text-gray-900 mb-2">No charts available</h3>
                    <p class="text-gray-500">This tab doesn't contain any charts yet.</p>
                </div>
            </div>
        </div>
    </div>

    <style>
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
        }
        
        .animate-fadeIn {
            animation: fadeIn 0.3s ease-out;
        }
        
        /* Custom scrollbar for better aesthetics */
        ::-webkit-scrollbar {
            width: 6px;
        }
        
        ::-webkit-scrollbar-track {
            background: #f1f5f9;
        }
        
        ::-webkit-scrollbar-thumb {
            background: #cbd5e1;
            border-radius: 3px;
        }
        
        ::-webkit-scrollbar-thumb:hover {
            background: #94a3b8;
        }
    </style>

    <script>
        const { createApp } = Vue;
        
        createApp({
            data() {
                return {
                    activeTab: 0,
                    searchQuery: '',
                    tabs: """,
    )

    write(file, json_encode_dashboard(dashboard))

    write(
        file,
        """,
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
                },
                searchQuery() {
                    this.\$nextTick(() => {
                        // Re-initialize charts for the active tab when search changes
                        this.initializeChartsForTab(this.activeTab);
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
                    const filteredCharts = this.getFilteredChartsForTab(tabIndex);
                    filteredCharts.forEach((chart) => {
                        const chartId = 'chart-' + tabIndex + '-' + chart.originalIndex;
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
                                        legend: {
                                            display: true,
                                            position: 'bottom',
                                            labels: {
                                                padding: 20,
                                                font: {
                                                    family: 'system-ui, -apple-system, sans-serif',
                                                    size: 12
                                                },
                                                color: '#6b7280' // gray-500
                                            }
                                        },
                                        tooltip: {
                                            backgroundColor: '#1f2937', // gray-800
                                            titleColor: '#f9fafb',       // gray-50
                                            bodyColor: '#f9fafb',        // gray-50
                                            borderColor: '#374151',      // gray-700
                                            borderWidth: 1,
                                            cornerRadius: 8,
                                            titleFont: {
                                                family: 'system-ui, -apple-system, sans-serif',
                                                size: 13,
                                                weight: 600
                                            },
                                            bodyFont: {
                                                family: 'system-ui, -apple-system, sans-serif',
                                                size: 12
                                            }
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
                        'rgba(59, 130, 246, 0.8)',   // blue-500
                        'rgba(16, 185, 129, 0.8)',   // emerald-500  
                        'rgba(245, 158, 11, 0.8)',   // amber-500
                        'rgba(239, 68, 68, 0.8)',    // red-500
                        'rgba(139, 92, 246, 0.8)',   // violet-500
                        'rgba(236, 72, 153, 0.8)',   // pink-500
                        'rgba(6, 182, 212, 0.8)',    // cyan-500
                        'rgba(34, 197, 94, 0.8)'     // green-500
                    ];
                    
                    const borderColors = [
                        'rgba(59, 130, 246, 1)',     // blue-500
                        'rgba(16, 185, 129, 1)',     // emerald-500
                        'rgba(245, 158, 11, 1)',     // amber-500
                        'rgba(239, 68, 68, 1)',      // red-500
                        'rgba(139, 92, 246, 1)',     // violet-500
                        'rgba(236, 72, 153, 1)',     // pink-500
                        'rgba(6, 182, 212, 1)',      // cyan-500
                        'rgba(34, 197, 94, 1)'       // green-500
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
                                color: '#f1f5f9', // gray-100
                                borderColor: '#e2e8f0' // gray-200
                            },
                            ticks: {
                                color: '#6b7280', // gray-500
                                font: {
                                    family: 'system-ui, -apple-system, sans-serif',
                                    size: 11
                                }
                            }
                        },
                        x: {
                            grid: {
                                color: '#f1f5f9', // gray-100
                                borderColor: '#e2e8f0' // gray-200
                            },
                            ticks: {
                                color: '#6b7280', // gray-500
                                font: {
                                    family: 'system-ui, -apple-system, sans-serif',
                                    size: 11
                                }
                            }
                        }
                    };
                },
                getFilteredChartsForTab(tabIndex) {
                    if (!this.searchQuery) {
                        return this.tabs[tabIndex].charts.map((chart, index) => ({
                            ...chart,
                            originalIndex: index
                        }));
                    }
                    
                    const query = this.searchQuery.toLowerCase();
                    return this.tabs[tabIndex].charts
                        .map((chart, index) => ({ ...chart, originalIndex: index }))
                        .filter(chart => 
                            chart.title.toLowerCase().includes(query) ||
                            chart.chart_type.toLowerCase().includes(query)
                        );
                },
                highlightSearchTerm(text) {
                    if (!this.searchQuery) return text;
                    
                    const regex = new RegExp('(' + this.searchQuery + ')', 'gi');
                    return text.replace(regex, '<span class="bg-yellow-200 text-yellow-800 px-1 rounded">\$1</span>');
                }
            }
        }).mount('#app');
    </script>
</body>
</html>
""",
    )

    close(file)
    return nothing
end
@define_lua_function save

function json_encode_dashboard(dashboard::Dashboard)
    tabs_json = String[]

    for tab in dashboard.tabs
        tab_json = json_encode_dashboard(tab)
        push!(tabs_json, tab_json)
    end

    return "[" * join(tabs_json, ", ") * "]"
end

