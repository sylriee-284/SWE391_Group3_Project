// Dashboard JavaScript with Chart.js

// Initialize charts when DOM is loaded
document.addEventListener('DOMContentLoaded', function () {
    initializeSalesChart();
    initializeTopProductsChart();
    initializeRefundCancelChart();
});

// Sales Chart - Line/Area Chart
function initializeSalesChart() {
    const ctx = document.getElementById('salesChart');
    if (!ctx) return;

    // Get data from JSP
    const chartData = typeof salesChartData !== 'undefined' ? salesChartData : { dataPoints: [] };

    const labels = chartData.dataPoints.map(point => point.label);
    const revenueData = chartData.dataPoints.map(point => point.revenue);
    const orderCountData = chartData.dataPoints.map(point => point.orderCount);

    new Chart(ctx, {
        type: 'line',
        data: {
            labels: labels,
            datasets: [
                {
                    label: 'Doanh thu (₫)',
                    data: revenueData,
                    borderColor: '#10b981',
                    backgroundColor: 'rgba(16, 185, 129, 0.1)',
                    borderWidth: 3,
                    fill: true,
                    tension: 0.4,
                    yAxisID: 'y'
                },
                {
                    label: 'Số đơn hàng',
                    data: orderCountData,
                    borderColor: '#3b82f6',
                    backgroundColor: 'rgba(59, 130, 246, 0.1)',
                    borderWidth: 2,
                    fill: false,
                    tension: 0.4,
                    yAxisID: 'y1'
                }
            ]
        },
        options: {
            responsive: true,
            maintainAspectRatio: true,
            interaction: {
                mode: 'index',
                intersect: false,
            },
            plugins: {
                legend: {
                    position: 'top',
                    labels: {
                        usePointStyle: true,
                        padding: 20,
                        font: {
                            size: 12,
                            family: "'Segoe UI', Tahoma, Geneva, Verdana, sans-serif"
                        }
                    }
                },
                tooltip: {
                    backgroundColor: 'rgba(0, 0, 0, 0.8)',
                    padding: 12,
                    titleFont: {
                        size: 14,
                        weight: 'bold'
                    },
                    bodyFont: {
                        size: 13
                    },
                    callbacks: {
                        label: function (context) {
                            let label = context.dataset.label || '';
                            if (label) {
                                label += ': ';
                            }
                            if (context.datasetIndex === 0) {
                                // Revenue - format as currency
                                label += new Intl.NumberFormat('vi-VN', {
                                    style: 'currency',
                                    currency: 'VND'
                                }).format(context.parsed.y);
                            } else {
                                // Order count
                                label += context.parsed.y;
                            }
                            return label;
                        }
                    }
                }
            },
            scales: {
                x: {
                    grid: {
                        display: false
                    },
                    ticks: {
                        font: {
                            size: 11
                        }
                    }
                },
                y: {
                    type: 'linear',
                    display: true,
                    position: 'left',
                    grid: {
                        color: 'rgba(0, 0, 0, 0.05)'
                    },
                    ticks: {
                        callback: function (value) {
                            return new Intl.NumberFormat('vi-VN', {
                                notation: 'compact',
                                compactDisplay: 'short'
                            }).format(value) + '₫';
                        },
                        font: {
                            size: 11
                        }
                    }
                },
                y1: {
                    type: 'linear',
                    display: true,
                    position: 'right',
                    grid: {
                        drawOnChartArea: false,
                    },
                    ticks: {
                        font: {
                            size: 11
                        }
                    }
                }
            }
        }
    });
}

// Top Products Chart - Horizontal Bar Chart
function initializeTopProductsChart() {
    const ctx = document.getElementById('topProductsChart');
    if (!ctx) return;

    // Get data from JSP
    const products = typeof topProductsData !== 'undefined' ? topProductsData : [];

    const labels = products.slice(0, 10).map(p =>
        p.productName.length > 30 ? p.productName.substring(0, 30) + '...' : p.productName
    );
    const data = products.slice(0, 10).map(p => p.totalRevenue);

    new Chart(ctx, {
        type: 'bar',
        data: {
            labels: labels,
            datasets: [{
                label: 'Doanh thu (₫)',
                data: data,
                backgroundColor: [
                    'rgba(79, 70, 229, 0.8)',
                    'rgba(16, 185, 129, 0.8)',
                    'rgba(59, 130, 246, 0.8)',
                    'rgba(245, 158, 11, 0.8)',
                    'rgba(239, 68, 68, 0.8)',
                    'rgba(139, 92, 246, 0.8)',
                    'rgba(6, 182, 212, 0.8)',
                    'rgba(236, 72, 153, 0.8)',
                    'rgba(34, 197, 94, 0.8)',
                    'rgba(251, 146, 60, 0.8)'
                ],
                borderWidth: 0,
                borderRadius: 6
            }]
        },
        options: {
            indexAxis: 'y',
            responsive: true,
            maintainAspectRatio: true,
            plugins: {
                legend: {
                    display: false
                },
                tooltip: {
                    backgroundColor: 'rgba(0, 0, 0, 0.8)',
                    padding: 12,
                    callbacks: {
                        label: function (context) {
                            return new Intl.NumberFormat('vi-VN', {
                                style: 'currency',
                                currency: 'VND'
                            }).format(context.parsed.x);
                        }
                    }
                }
            },
            scales: {
                x: {
                    grid: {
                        color: 'rgba(0, 0, 0, 0.05)'
                    },
                    ticks: {
                        callback: function (value) {
                            return new Intl.NumberFormat('vi-VN', {
                                notation: 'compact',
                                compactDisplay: 'short'
                            }).format(value) + '₫';
                        },
                        font: {
                            size: 11
                        }
                    }
                },
                y: {
                    grid: {
                        display: false
                    },
                    ticks: {
                        font: {
                            size: 11
                        }
                    }
                }
            }
        }
    });
}

// Refund/Cancel Trend Chart - Doughnut Chart
function initializeRefundCancelChart() {
    const ctx = document.getElementById('refundCancelChart');
    if (!ctx) return;

    // Get data from JSP (using salesChartData for trends)
    const chartData = typeof salesChartData !== 'undefined' ? salesChartData : { dataPoints: [] };

    const totalRefunds = chartData.dataPoints.reduce((sum, point) => sum + (point.refundCount || 0), 0);
    const totalCancels = chartData.dataPoints.reduce((sum, point) => sum + (point.cancelCount || 0), 0);
    const totalCompleted = chartData.dataPoints.reduce((sum, point) => sum + (point.orderCount || 0), 0) - totalRefunds - totalCancels;

    new Chart(ctx, {
        type: 'doughnut',
        data: {
            labels: ['Hoàn thành', 'Hoàn trả', 'Hủy'],
            datasets: [{
                data: [totalCompleted, totalRefunds, totalCancels],
                backgroundColor: [
                    'rgba(16, 185, 129, 0.8)',
                    'rgba(239, 68, 68, 0.8)',
                    'rgba(245, 158, 11, 0.8)'
                ],
                borderWidth: 2,
                borderColor: '#ffffff',
                hoverOffset: 10
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: true,
            plugins: {
                legend: {
                    position: 'bottom',
                    labels: {
                        usePointStyle: true,
                        padding: 20,
                        font: {
                            size: 12,
                            family: "'Segoe UI', Tahoma, Geneva, Verdana, sans-serif"
                        }
                    }
                },
                tooltip: {
                    backgroundColor: 'rgba(0, 0, 0, 0.8)',
                    padding: 12,
                    callbacks: {
                        label: function (context) {
                            const label = context.label || '';
                            const value = context.parsed;
                            const total = context.dataset.data.reduce((a, b) => a + b, 0);
                            const percentage = ((value / total) * 100).toFixed(1);
                            return `${label}: ${value} đơn (${percentage}%)`;
                        }
                    }
                }
            }
        }
    });
}

// Utility: Format currency
function formatCurrency(value) {
    return new Intl.NumberFormat('vi-VN', {
        style: 'currency',
        currency: 'VND',
        maximumFractionDigits: 0
    }).format(value);
}

// Utility: Format number
function formatNumber(value) {
    return new Intl.NumberFormat('vi-VN').format(value);
}

// Auto-refresh dashboard every 5 minutes
setInterval(function () {
    if (typeof autoRefreshEnabled !== 'undefined' && autoRefreshEnabled) {
        location.reload();
    }
}, 300000); // 5 minutes
