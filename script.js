let data = [];
let charts = {};
let activeFilters = {};

// Miglioramenti nell'animazione di caricamento
function showLoading() {
    const loading = document.getElementById('loading');
    loading.style.display = 'block';
    document.getElementById('data-table').style.display = 'none';
}

function hideLoading() {
    const loading = document.getElementById('loading');
    loading.style.opacity = '0';
    setTimeout(() => {
        loading.style.display = 'none';
        document.getElementById('data-table').style.display = 'table';
        document.getElementById('data-table').style.opacity = '0';
        setTimeout(() => {
            document.getElementById('data-table').style.opacity = '1';
        }, 50);
    }, 300);
}

// Aggiornamento della funzione loadData per includere l'inizializzazione dei filtri
async function loadData() {
    showLoading();
    try {
        const response = await fetch('Programma_Televisivo_con_Stagioni_clean.json');
        data = await response.json();
        populateSeasonSelect();
        populateFilterOptions();
        displayData();
        hideLoading();
    } catch (error) {
        console.error('Errore nel caricamento del file JSON:', error);
        document.getElementById('loading').textContent = 'Errore nel caricamento dei dati.';
    }
}

// Popolamento del select delle stagioni
function populateSeasonSelect() {
    const seasonSelect = document.getElementById('season-select');
    const seasons = [...new Set(data.map(item => item.Stagione))].sort((a, b) => a - b);
    seasons.forEach(season => {
        const option = document.createElement('option');
        option.value = season;
        option.textContent = `Stagione ${season}`;
        seasonSelect.appendChild(option);
    });
}

// Popolamento delle opzioni dei filtri
function populateFilterOptions() {
    const years = [...new Set(data.map(item => item.Anno))].sort();
    const locations = [...new Set(data.map(item => item.Location))].sort();
    const categories = [...new Set(data.map(item => item['Categoria speciale']))].filter(cat => cat).sort();

    populateSelect('filter-anno', years);
    populateSelect('filter-location', locations);
    populateSelect('filter-categoria', categories);
}

function populateSelect(elementId, options) {
    const select = document.getElementById(elementId);
    select.innerHTML = '<option value="">Tutti</option>';
    options.forEach(option => {
        const optElement = document.createElement('option');
        optElement.value = option;
        optElement.textContent = option;
        select.appendChild(optElement);
    });
}

// Funzione di filtro avanzato
function applyAdvancedFilters(item) {
    const filters = {
        anno: document.getElementById('filter-anno').value,
        location: document.getElementById('filter-location').value,
        categoria: document.getElementById('filter-categoria').value,
        vincitore: document.getElementById('filter-vincitore').value.toLowerCase(),
        titolare: document.getElementById('filter-titolare').value.toLowerCase(),
        dateStart: document.getElementById('filter-date-start').value,
        dateEnd: document.getElementById('filter-date-end').value
    };

    // Salva i filtri attivi
    activeFilters = { ...filters };

    // Verifica ogni filtro
    if (filters.anno && item.Anno !== filters.anno) return false;
    if (filters.location && item.Location !== filters.location) return false;
    if (filters.categoria && item['Categoria speciale'] !== filters.categoria) return false;
    if (filters.vincitore && !item.Vincitore.toLowerCase().includes(filters.vincitore)) return false;
    if (filters.titolare && !item.Titolare.toLowerCase().includes(filters.titolare)) return false;

    // Gestione del range di date
    if (filters.dateStart || filters.dateEnd) {
        const itemDate = parseItalianDate(item['Prima visione']);
        if (!itemDate) return false;
        if (filters.dateStart && itemDate < new Date(filters.dateStart)) return false;
        if (filters.dateEnd && itemDate > new Date(filters.dateEnd)) return false;
    }

    return true;
}

function parseItalianDate(dateStr) {
    if (!dateStr) return null;
    
    const months = {
        'gen': '01', 'feb': '02', 'mar': '03', 'apr': '04',
        'mag': '05', 'giu': '06', 'lug': '07', 'ago': '08',
        'set': '09', 'ott': '10', 'nov': '11', 'dic': '12'
    };

    // Rimuovi "º" e gestisci i formati delle date
    dateStr = dateStr.replace('º', '');
    
    if (dateStr.includes('-')) {
        const parts = dateStr.split('-');
        if (parts.length === 3) {
            return new Date(`20${parts[2]}-${months[parts[1]] || parts[1]}-${parts[0]}`);
        }
    }
    
    return new Date(dateStr);
}

// Visualizzazione dei dati nella tabella
function displayData() {
    const tableBody = document.querySelector('#data-table tbody');
    const searchInput = document.getElementById('search-input').value.toLowerCase();
    const seasonSelect = document.getElementById('season-select').value;
    
    const filteredData = data.filter(item => {
        const matchesSeason = seasonSelect === 'all' || item.Stagione === seasonSelect;
        const matchesSearch = Object.values(item).some(value => 
            value.toString().toLowerCase().includes(searchInput)
        );
        return matchesSearch && matchesSeason && applyAdvancedFilters(item);
    });

    tableBody.innerHTML = filteredData
        .map(item => `
            <tr>
                <td>${item.Anno}</td>
                <td>${item.Stagione}</td>
                <td>${item.Puntata}</td>
                <td>${item.Location}</td>
                <td>${item.Tema}</td>
                <td>${item['Prima visione']}</td>
                <td>${item['Categoria speciale']}</td>
                <td>${item.Concorrenti}</td>
                <td>${item.Vincitore}</td>
                <td>${item.Titolare}</td>
            </tr>
        `).join('');

    // Aggiorna il contatore dei risultati
    const resultCount = document.createElement('div');
    resultCount.className = 'mt-3 text-muted';
    resultCount.textContent = `${filteredData.length} risultati trovati`;
    const existingCount = document.querySelector('.mt-3.text-muted');
    if (existingCount) {
        existingCount.remove();
    }
    tableBody.parentElement.after(resultCount);
}

// Gestione del grafico
function initCharts() {
    const chartContainers = [
        'locations-chart',
        'locations-evolution-chart',
        'top-locations-chart'
    ];

    chartContainers.forEach(containerId => {
        if (document.getElementById(containerId)) {
            charts[containerId] = echarts.init(document.getElementById(containerId));
        }
    });

    updateCharts();
    enableAutoResize();
}

function updateCharts() {
    updateLocationsDistribution();
    updateLocationsEvolutionChart();
    updateTopLocationsChart();
}

function updateLocationsDistribution() {
    if (!charts['locations-chart']) return;

    const locationCounts = {};
    data.forEach(item => {
        locationCounts[item.Location] = (locationCounts[item.Location] || 0) + 1;
    });

    const option = {
        title: {
            text: 'Distribuzione per Location',
            left: 'center',
            textStyle: {
                fontSize: 16,
                fontFamily: 'Inter'
            }
        },
        tooltip: {
            trigger: 'item',
            formatter: '{b}: {c} episodi ({d}%)'
        },
        series: [{
            type: 'pie',
            radius: ['40%', '70%'],
            center: ['50%', '55%'],
            avoidLabelOverlap: true,
            itemStyle: {
                borderRadius: 8,
                borderWidth: 2
            },
            label: {
                show: true,
                formatter: '{b}: {c}'
            },
            emphasis: {
                label: {
                    show: true,
                    fontSize: 14,
                    fontWeight: 'bold'
                }
            },
            data: Object.entries(locationCounts).map(([name, value]) => ({
                name,
                value
            })).sort((a, b) => b.value - a.value)
        }]
    };

    charts['locations-chart'].setOption(option);
}

function updateCategoriesChart() {
    if (!charts['categories-chart']) return;

    // Raggruppa categorie simili
    const categoryGroups = {
        'Ristoranti Etnici': ['etnico', 'etnici', 'fusion', 'internazionale'],
        'Ristoranti di Mare': ['pesce', 'mare', 'pescatori'],
        'Ristoranti Tradizionali': ['tradizionale', 'tipico', 'cucina locale'],
        'Ristoranti Moderni': ['gourmet', 'moderna', 'contemporanea'],
        'Street Food': ['street food', 'street', 'cibo da strada']
    };

    const categoriesData = data.reduce((acc, item) => {
        if (item.Categoria_speciale && item.Categoria_speciale.trim()) {
            const categoria = item.Categoria_speciale.trim().toLowerCase();
            let gruppo = 'Altro';
            
            // Trova il gruppo appropriato
            for (const [key, keywords] of Object.entries(categoryGroups)) {
                if (keywords.some(keyword => categoria.includes(keyword))) {
                    gruppo = key;
                    break;
                }
            }
            
            if (!acc[gruppo]) {
                acc[gruppo] = {
                    count: 0,
                    locations: new Set(),
                    seasons: new Set(),
                    details: new Set()
                };
            }
            acc[gruppo].count++;
            acc[gruppo].locations.add(item.Location);
            acc[gruppo].seasons.add(item.Stagione);
            acc[gruppo].details.add(item.Categoria_speciale.trim());
        }
        return acc;
    }, {});

    const sortedCategories = Object.entries(categoriesData)
        .map(([name, stats]) => ({
            name,
            count: stats.count,
            locations: stats.locations.size,
            seasons: stats.seasons.size,
            details: Array.from(stats.details)
        }))
        .sort((a, b) => b.count - a.count);

    const option = {
        title: {
            text: 'Analisi Categorie Speciali per Gruppi',
            subtext: 'Raggruppamento per tipologia di ristorazione',
            left: 'center',
            textStyle: {
                fontSize: 18,
                fontFamily: 'Inter'
            },
            subtextStyle: {
                fontSize: 12
            }
        },
        tooltip: {
            trigger: 'item',
            formatter: function(params) {
                const cat = sortedCategories.find(c => c.name === params.name);
                return `<strong>${cat.name}</strong><br/>
                        Episodi: ${cat.count}<br/>
                        Location: ${cat.locations}<br/>
                        Stagioni: ${cat.seasons}<br/>
                        <br/>Include:<br/>
                        ${cat.details.join('<br/>')}`;
            }
        },
        series: [
            {
                type: 'pie',
                radius: ['40%', '70%'],
                center: ['50%', '50%'],
                avoidLabelOverlap: true,
                itemStyle: {
                    borderRadius: 8,
                    borderColor: '#fff',
                    borderWidth: 2
                },
                label: {
                    show: true,
                    formatter: '{b}\n{c} ep.',
                    position: 'outside',
                    alignTo: 'none',
                    bleedMargin: 5
                },
                emphasis: {
                    label: {
                        show: true,
                        fontSize: 16,
                        fontWeight: 'bold'
                    }
                },
                data: sortedCategories.map(c => ({
                    name: c.name,
                    value: c.count
                }))
            }
        ]
    };

    charts['categories-chart'].setOption(option);
}

function updateTimelineChart() {
    if (!charts['timeline-chart']) return;

    // Organizziamo i dati per stagione e mese
    const timeData = data.reduce((acc, item) => {
        if (!item.Prima_visione) return acc;
        
        const date = new Date(item.Prima_visione);
        const year = date.getFullYear();
        const month = date.getMonth();
        const season = item.Stagione;
        
        const key = `${year}-${month}`;
        if (!acc[key]) {
            acc[key] = {
                date: date,
                count: 0,
                seasons: new Set(),
                episodes: []
            };
        }
        
        acc[key].count++;
        acc[key].seasons.add(season);
        acc[key].episodes.push({
            stagione: season,
            location: item.Location,
            categoria: item.Categoria_speciale
        });
        
        return acc;
    }, {});

    const series = [];
    const years = [...new Set(Object.values(timeData).map(d => d.date.getFullYear()))].sort();
    
    // Creiamo una serie per ogni anno
    years.forEach((year, index) => {
        const yearData = Object.values(timeData)
            .filter(d => d.date.getFullYear() === year)
            .map(d => [
                d.date,
                d.count,
                d.episodes.map(e => 
                    `${e.location}${e.categoria ? ` (${e.categoria})` : ''}`
                ).join('\n')
            ]);

        series.push({
            name: `${year}`,
            type: 'line',
            smooth: true,
            symbol: 'circle',
            symbolSize: 12,
            lineStyle: {
                width: 3
            },
            data: yearData
        });
    });

    const option = {
        title: {
            text: 'Distribuzione Temporale delle Puntate',
            subtext: 'Analisi mensile per anno',
            left: 'center',
            textStyle: {
                fontSize: 18,
                fontFamily: 'Inter'
            }
        },
        tooltip: {
            trigger: 'item',
            formatter: function(params) {
                const date = new Date(params.value[0]);
                return `<strong>${date.toLocaleDateString('it-IT', {
                    year: 'numeric',
                    month: 'long'
                })}</strong><br/>
                Puntate: ${params.value[1]}<br/>
                <br/>Location:<br/>
                ${params.value[2].split('\n').join('<br/>')}`;
            }
        },
        legend: {
            data: years,
            top: 30
        },
        grid: {
            left: '3%',
            right: '4%',
            bottom: '3%',
            containLabel: true
        },
        xAxis: {
            type: 'time',
            axisLabel: {
                formatter: function(value) {
                    return new Date(value).toLocaleDateString('it-IT', {
                        month: 'short'
                    });
                }
            }
        },
        yAxis: {
            type: 'value',
            name: 'Numero di Puntate',
            minInterval: 1
        },
        series: series
    };

    charts['timeline-chart'].setOption(option);
}

function updateTopLocationsChart() {
    if (!charts['top-locations-chart']) return;

    const locationStats = {};
    data.forEach(item => {
        if (!locationStats[item.Location]) {
            locationStats[item.Location] = {
                episodes: 0,
                winners: new Set()
            };
        }
        locationStats[item.Location].episodes++;
        if (item.Vincitore) {
            locationStats[item.Location].winners.add(item.Vincitore);
        }
    });

    const topLocations = Object.entries(locationStats)
        .map(([location, stats]) => ({
            location,
            episodes: stats.episodes,
            winners: stats.winners.size
        }))
        .sort((a, b) => b.episodes - a.episodes)
        .slice(0, 10);

    const option = {
        title: {
            text: 'Top 10 Location',
            left: 'center',
            textStyle: {
                fontSize: 16,
                fontFamily: 'Inter'
            }
        },
        tooltip: {
            trigger: 'axis',
            axisPointer: {
                type: 'shadow'
            }
        },
        legend: {
            data: ['Episodi', 'Vincitori Unici'],
            top: 30
        },
        xAxis: {
            type: 'value'
        },
        yAxis: {
            type: 'category',
            data: topLocations.map(item => item.location),
            axisLabel: {
                interval: 0
            }
        },
        series: [
            {
                name: 'Episodi',
                type: 'bar',
                data: topLocations.map(item => item.episodes)
            },
            {
                name: 'Vincitori Unici',
                type: 'bar',
                data: topLocations.map(item => item.winners)
            }
        ]
    };

    charts['top-locations-chart'].setOption(option);
}

function updateLocationsEvolutionChart() {
    if (!charts['locations-evolution-chart']) return;

    // Raggruppa le location per anno
    const locationsByYear = data.reduce((acc, item) => {
        const year = parseInt(item.Anno);
        if (!acc[year]) acc[year] = new Set();
        acc[year].add(item.Location);
        return acc;
    }, {});

    const years = Object.keys(locationsByYear).sort();
    const locationCounts = years.map(year => locationsByYear[year].size);

    const option = {
        title: {
            text: 'Evoluzione delle Location negli Anni',
            subtext: 'Numero di location diverse visitate per anno',
            left: 'center',
            textStyle: {
                fontSize: 16,
                fontFamily: 'Inter'
            }
        },
        tooltip: {
            trigger: 'axis',
            formatter: '{b}: {c} location'
        },
        xAxis: {
            type: 'category',
            data: years,
            name: 'Anno'
        },
        yAxis: {
            type: 'value',
            name: 'Numero di Location',
            minInterval: 1
        },
        series: [{
            data: locationCounts,
            type: 'line',
            smooth: true,
            lineStyle: {
                width: 3
            },
            symbolSize: 8,
            itemStyle: {
                color: '#91cc75'
            },
            areaStyle: {
                color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [{
                    offset: 0,
                    color: 'rgba(145, 204, 117, 0.3)'
                }, {
                    offset: 1,
                    color: 'rgba(145, 204, 117, 0.1)'
                }])
            }
        }]
    };

    charts['locations-evolution-chart'].setOption(option);
}

function enableAutoResize() {
    window.addEventListener('resize', () => {
        Object.values(charts).forEach(chart => chart && chart.resize());
    });
}

// Event Listeners
document.addEventListener('DOMContentLoaded', () => {
    loadData();
    
    // Listener per il form di ricerca avanzata
    document.getElementById('applyFilters').addEventListener('click', () => {
        displayData();
        bootstrap.Modal.getInstance(document.getElementById('searchModal')).hide();
    });

    // Reset filtri
    document.getElementById('resetFilters').addEventListener('click', () => {
        document.getElementById('advancedSearchForm').reset();
        activeFilters = {};
        displayData();
    });

    // Ricerca in tempo reale
    document.getElementById('search-input').addEventListener('input', () => {
        displayData();
    });

    document.getElementById('season-select').addEventListener('change', () => {
        displayData();
    });

    // Listener per i campi del form avanzato
    document.querySelectorAll('#advancedSearchForm select, #advancedSearchForm input').forEach(element => {
        element.addEventListener('change', () => {
            displayData();
        });
    });

    document.querySelector('a[data-bs-toggle="tab"][href="#chart-tab"]')
        .addEventListener('shown.bs.tab', () => {
            if (!charts['locations-chart']) {
                initCharts();
            } else {
                Object.values(charts).forEach(chart => chart && chart.resize());
            }
        });
});