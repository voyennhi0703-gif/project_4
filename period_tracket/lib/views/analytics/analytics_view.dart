import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:period_tracket/views/data/data_manager.dart';
import 'package:period_tracket/views/home/home_cycle_history_card.dart';
import 'package:provider/provider.dart';

class AnalyticsView extends StatefulWidget {
  const AnalyticsView({super.key});

  @override
  State<AnalyticsView> createState() => _AnalyticsViewState();
}

class _AnalyticsViewState extends State<AnalyticsView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<DataManager>(
      builder: (context, dataManager, child) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.pink.shade50, Colors.pink.shade100],
              ),
            ),
            child: Column(
              children: [
                // Header với gradient giống trang home
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Colors.pink.shade200, Colors.pink.shade300],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Phân tích',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.pink.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Summary cards
                        Row(
                          children: [
                            Expanded(
                              child: _buildSummaryCard(
                                title: 'Chu kỳ hiện tại',
                                value: '${dataManager.currentCycleDay}',
                                subtitle: 'ngày',
                                color: const Color(0xFFFF4081),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildSummaryCard(
                                title: 'Tổng chu kỳ',
                                value: '${dataManager.cycleHistory.length}',
                                subtitle: 'chu kỳ',
                                color: const Color(0xFF26C6DA),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: _buildSummaryCard(
                                title: 'Độ dài TB',
                                value:
                                    '${_calculateAverageCycleLength(dataManager)}',
                                subtitle: 'ngày',
                                color: _getCycleLengthColor(
                                  _calculateAverageCycleLength(dataManager),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildSummaryCard(
                                title: 'Kỳ kinh TB',
                                value:
                                    '${_calculateAveragePeriodLength(dataManager)}',
                                subtitle: 'ngày',
                                color: _getPeriodLengthColor(
                                  _calculateAveragePeriodLength(dataManager),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Cycle Health Status Card
                        _buildCycleHealthStatusCard(dataManager),

                        const SizedBox(height: 16),

                        const HomeCycleHistoryCard(),

                        const SizedBox(height: 16),
                        // Quick insights
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Thông tin nhanh',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 16),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildInsightRow(
                                      'Giai đoạn hiện tại: ',
                                      dataManager.cyclePhase,
                                    ),
                                    _buildInsightRow(
                                      'Khả năng thụ thai: ',
                                      dataManager.getPregnancyChance(),
                                    ),
                                    _buildInsightRow(
                                      'Ngày rụng trứng tiếp theo: ',
                                      dataManager.ovulationDate != null
                                          ? dataManager.formatDate(
                                              dataManager.ovulationDate,
                                            )
                                          : 'Chưa có dữ liệu',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // iOS-style Cycle Trend Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.2),
                              width: 0.5,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // iOS-style header
                              Row(
                                children: [
                                  const Text(
                                    'Xu hướng chu kỳ',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.info_outline,
                                      size: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // iOS-style description with bold text
                              _buildIOSCycleTrendDescriptionWithBold(
                                dataManager,
                              ),

                              const SizedBox(height: 20),

                              // iOS-style Chart
                              SizedBox(
                                height: 320,
                                child: Stack(
                                  children: [
                                    _buildIOSCycleLineChart(dataManager),

                                    // Hiển thị giá trị trên các điểm dữ liệu
                                  ],
                                ),
                              ),

                              const SizedBox(height: 12),

                              // iOS-style Legend
                              _buildIOSChartLegend(),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Medical advice card
                        _buildMedicalAdviceCard(dataManager),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCycleHealthStatusCard(DataManager dataManager) {
    final avgCycleLength = _calculateAverageCycleLength(dataManager);
    final avgPeriodLength = _calculateAveragePeriodLength(dataManager);

    final cycleStatus = _getCycleHealthStatus(avgCycleLength);
    final periodStatus = _getPeriodHealthStatus(avgPeriodLength);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.health_and_safety,
                color: const Color(0xFFFF4081),
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Tình trạng sức khỏe sinh sản',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Cycle length status
          _buildHealthStatusRow(
            'Độ dài chu kỳ',
            '$avgCycleLength ngày',
            cycleStatus.status,
            cycleStatus.color,
            cycleStatus.icon,
          ),

          const SizedBox(height: 12),

          // Period length status
          _buildHealthStatusRow(
            'Độ dài kỳ kinh',
            '$avgPeriodLength ngày',
            periodStatus.status,
            periodStatus.color,
            periodStatus.icon,
          ),

          const SizedBox(height: 16),

          // Educational info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700], size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Thông tin hữu ích',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[800],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '• Chu kỳ bình thường: 21-35 ngày (theo ACOG)\n'
                  '• Kỳ kinh bình thường: 3-7 ngày\n'
                  '• Độ dài chu kỳ được tính từ ngày đầu kỳ kinh này đến ngày đầu kỳ kinh tiếp theo',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.blue[700],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthStatusRow(
    String label,
    String value,
    String status,
    Color color,
    IconData icon,
  ) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMedicalAdviceCard(DataManager dataManager) {
    final needsMedicalAttention = _shouldSeekMedicalAdvice(dataManager);

    if (!needsMedicalAttention.shouldSeek) {
      return Container();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red[200]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.medical_services, color: Colors.red[700], size: 24),
              const SizedBox(width: 8),
              const Text(
                'Khuyến nghị tham khảo ý kiến bác sĩ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Text(
            'Dựa trên dữ liệu chu kỳ của bạn, có một số dấu hiệu cần lưu ý:',
            style: TextStyle(
              fontSize: 14,
              color: Colors.red[800],
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 8),

          ...needsMedicalAttention.reasons.map(
            (reason) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• ',
                    style: TextStyle(fontSize: 14, color: Colors.red[700]),
                  ),
                  Expanded(
                    child: Text(
                      reason,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.red[700],
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.red[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Lưu ý: Thông tin này chỉ mang tính chất tham khảo. Hãy tham khảo ý kiến bác sĩ chuyên khoa để được tư vấn và điều trị phù hợp.',
              style: TextStyle(
                fontSize: 11,
                color: Colors.red[800],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Health status calculation methods
  HealthStatus _getCycleHealthStatus(int cycleLength) {
    if (cycleLength >= 21 && cycleLength <= 35) {
      return HealthStatus(
        status: 'Bình thường',
        color: Colors.green,
        icon: Icons.check_circle,
      );
    } else if (cycleLength < 21) {
      return HealthStatus(
        status: 'Ngắn',
        color: Colors.orange,
        icon: Icons.warning,
      );
    } else {
      return HealthStatus(status: 'Dài', color: Colors.red, icon: Icons.error);
    }
  }

  HealthStatus _getPeriodHealthStatus(int periodLength) {
    if (periodLength >= 3 && periodLength <= 7) {
      return HealthStatus(
        status: 'Bình thường',
        color: Colors.green,
        icon: Icons.check_circle,
      );
    } else if (periodLength < 3) {
      return HealthStatus(
        status: 'Ngắn',
        color: Colors.orange,
        icon: Icons.warning,
      );
    } else {
      return HealthStatus(status: 'Dài', color: Colors.red, icon: Icons.error);
    }
  }

  Color _getCycleLengthColor(int cycleLength) {
    if (cycleLength >= 21 && cycleLength <= 35) {
      return const Color(0xFF4DD0E1); // Normal - cyan
    } else if (cycleLength < 21) {
      return Colors.orange; // Short
    } else {
      return Colors.red; // Long
    }
  }

  Color _getPeriodLengthColor(int periodLength) {
    if (periodLength >= 3 && periodLength <= 7) {
      return const Color(0xFFFFB74D); // Normal - amber
    } else if (periodLength < 3) {
      return Colors.orange; // Short
    } else {
      return Colors.red; // Long
    }
  }

  MedicalAdvice _shouldSeekMedicalAdvice(DataManager dataManager) {
    List<String> reasons = [];

    if (dataManager.cycleHistory.isEmpty) {
      return MedicalAdvice(shouldSeek: false, reasons: []);
    }

    final avgCycleLength = _calculateAverageCycleLength(dataManager);
    final avgPeriodLength = _calculateAveragePeriodLength(dataManager);

    // Check for consistently abnormal cycle length
    int abnormalCycles = 0;
    for (final cycle in dataManager.cycleHistory) {
      if (!_isCycleLengthNormal(cycle.cycleDays)) {
        abnormalCycles++;
      }
    }

    if (abnormalCycles > dataManager.cycleHistory.length * 0.6) {
      if (avgCycleLength < 21) {
        reasons.add('Chu kỳ thường xuyên ngắn dưới 21 ngày');
      } else if (avgCycleLength > 35) {
        reasons.add('Chu kỳ thường xuyên dài hơn 35 ngày');
      }
    }

    // Check for consistently abnormal period length
    int abnormalPeriods = 0;
    for (final cycle in dataManager.cycleHistory) {
      if (!_isPeriodLengthNormal(cycle.periodDays)) {
        abnormalPeriods++;
      }
    }

    if (abnormalPeriods > dataManager.cycleHistory.length * 0.6) {
      if (avgPeriodLength < 3) {
        reasons.add('Kỳ kinh thường xuyên ngắn dưới 3 ngày');
      } else if (avgPeriodLength > 7) {
        reasons.add('Kỳ kinh thường xuyên dài hơn 7 ngày');
      }
    }

    // Check for high variability
    if (dataManager.cycleHistory.length >= 3) {
      List<int> cycleLengths = dataManager.cycleHistory
          .map((c) => c.cycleDays)
          .toList();
      int maxCycle = cycleLengths.reduce((a, b) => a > b ? a : b);
      int minCycle = cycleLengths.reduce((a, b) => a < b ? a : b);

      if (maxCycle - minCycle > 20) {
        reasons.add('Độ dài chu kỳ thay đổi quá nhiều (chênh lệch > 20 ngày)');
      }
    }

    return MedicalAdvice(shouldSeek: reasons.isNotEmpty, reasons: reasons);
  }

  // THAY THẾ hàm _buildIOSCycleLineChart bằng version này:

  Widget _buildIOSCycleLineChart(DataManager dataManager) {
    final chartData = _getChartData(dataManager);

    if (chartData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.show_chart, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              'Chưa có đủ dữ liệu chu kỳ',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Hãy theo dõi ít nhất 2-3 chu kỳ để xem biểu đồ',
              style: TextStyle(color: Colors.grey[500], fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Tối ưu Y-axis dựa trên dữ liệu
    final yAxisRange = _getOptimizedYAxisRange(chartData);

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) {
            if (yAxisRange.ticks.contains(value)) {
              return FlLine(color: Colors.grey[200]!, strokeWidth: 0.5);
            }
            return FlLine(color: Colors.transparent, strokeWidth: 0);
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60,
              interval: 1,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < chartData.length) {
                  final data = chartData[value.toInt()];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: SizedBox(
                      width: 60,
                      child: Text(
                        '${data.date.day} thg ${data.date.month}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
            axisNameWidget: const Padding(
              padding: EdgeInsets.only(top: 12.0),
              child: Text(
                'Ngày bắt đầu chu kỳ',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: 1,
              getTitlesWidget: (value, meta) {
                if (yAxisRange.ticks.contains(value)) {
                  return Text(
                    '${value.toInt()}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  );
                }
                return const Text('');
              },
            ),
            axisNameWidget: RotatedBox(
              quarterTurns: 2,
              child: Text(
                'Độ dài chu kỳ, ngày',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: chartData.asMap().entries.map((entry) {
              final index = entry.key;
              final data = entry.value;
              return FlSpot(index.toDouble(), data.cycleLength);
            }).toList(),
            isCurved: true,
            curveSmoothness: 0.3,
            color: Colors.grey[400]!,
            barWidth: 2,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                final data = chartData[index];
                return FlDotTextPainter(
                  radius: 5,
                  color: Colors.blue[800]!,
                  strokeWidth: 0,
                  text: '${data.cycleLength.toInt()}',
                  textStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                );
              },
            ),
            belowBarData: BarAreaData(show: false),
          ),
        ],
        minY: yAxisRange.minY,
        maxY: yAxisRange.maxY,
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => Colors.black87,
            tooltipRoundedRadius: 8,
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                final data = chartData[barSpot.spotIndex];
                final cycleLength = data.cycleLength.toInt();

                String status;
                if (_isCycleLengthNormal(cycleLength)) {
                  status = 'Bình thường';
                } else if (cycleLength < 21) {
                  status = 'Ngắn';
                } else {
                  status = 'Dài';
                }

                return LineTooltipItem(
                  '${data.date.day}/${data.date.month}\nChu kỳ: ${cycleLength} ngày\n$status',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              }).toList();
            },
          ),
          handleBuiltInTouches: true,
        ),
        // iOS-style normal range
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: 21,
              color: Colors.grey.withOpacity(0.15),
              strokeWidth: 0,
            ),
            HorizontalLine(
              y: 35,
              color: Colors.grey.withOpacity(0.15),
              strokeWidth: 0,
            ),
          ],
        ),
      ),
    );
  }

  // LOẠI BỎ hoàn toàn các hàm sau:
  // - _buildDataPointLabels()
  // - DataPointLabelPainter class

  Widget _buildIOSChartLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 20,
          height: 1,
          decoration: BoxDecoration(color: Colors.grey.withOpacity(0.15)),
        ),
        const SizedBox(width: 6),
        Text(
          'Trong phạm vi bình thường (21 - 35 ngày)',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  bool _isCycleLengthNormal(int cycleLength) {
    return cycleLength >= 21 && cycleLength <= 35;
  }

  bool _isPeriodLengthNormal(int periodLength) {
    return periodLength >= 3 && periodLength <= 7;
  }

  List<ChartData> _getChartData(DataManager dataManager) {
    final cycles = dataManager.cycleHistory;
    if (cycles.isEmpty) return [];

    // Sắp xếp theo ngày bắt đầu và lấy tối đa 6 chu kỳ gần nhất để giống với hình
    final sortedCycles = List.from(cycles);
    sortedCycles.sort((a, b) => b.startDate.compareTo(a.startDate));
    final recentCycles = sortedCycles.take(6).toList();
    recentCycles.sort((a, b) => a.startDate.compareTo(b.startDate));

    // Tạo dữ liệu biểu đồ
    return recentCycles.asMap().entries.map((entry) {
      final cycle = entry.value;

      return ChartData(
        x: entry.key.toDouble(),
        cycleLength: cycle.cycleDays.toDouble(),
        periodLength: cycle.periodDays.toDouble(),
        date: cycle.startDate,
      );
    }).toList();
  }

  YAxisRange _getOptimizedYAxisRange(List<ChartData> chartData) {
    if (chartData.isEmpty) {
      return YAxisRange(minY: 10, maxY: 70, ticks: [10, 25, 40, 55, 70]);
    }

    // Tìm min và max từ dữ liệu
    final values = chartData.map((data) => data.cycleLength).toList();
    final dataMin = values.reduce((a, b) => a < b ? a : b);
    final dataMax = values.reduce((a, b) => a > b ? a : b);

    // Thêm padding 10% ở trên và dưới
    final padding = (dataMax - dataMin) * 0.1;
    final minY = (dataMin - padding).clamp(5.0, 10.0);
    final maxY = (dataMax + padding).clamp(60.0, 80.0);

    // Tạo 5 mốc tối ưu
    final range = maxY - minY;
    final step = range / 4;

    final ticks = [minY, minY + step, minY + step * 2, minY + step * 3, maxY];

    return YAxisRange(minY: minY, maxY: maxY, ticks: ticks);
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFFFF4081),
            ),
          ),
        ],
      ),
    );
  }

  int _calculateAverageCycleLength(DataManager dataManager) {
    if (dataManager.cycleHistory.isEmpty) return dataManager.cycleDuration;

    int total = dataManager.cycleHistory
        .map((cycle) => cycle.cycleDays)
        .reduce((a, b) => a + b);
    return (total / dataManager.cycleHistory.length).round();
  }

  int _calculateAveragePeriodLength(DataManager dataManager) {
    if (dataManager.cycleHistory.isEmpty) return dataManager.periodDuration;

    int total = dataManager.cycleHistory
        .map((cycle) => cycle.periodDays)
        .reduce((a, b) => a + b);
    return (total / dataManager.cycleHistory.length).round();
  }

  Widget _buildIOSCycleTrendDescriptionWithBold(DataManager dataManager) {
    if (dataManager.cycleHistory.isEmpty) {
      return Text(
        'Chưa có đủ dữ liệu để hiển thị xu hướng chu kỳ.',
        style: TextStyle(fontSize: 15, color: Colors.grey[600], height: 1.4),
      );
    }

    final recentCycles = dataManager.cycleHistory.take(6).toList();
    int shortCycles = 0;
    int longCycles = 0;
    int normalCycles = 0;

    for (final cycle in recentCycles) {
      if (cycle.cycleDays < 21) {
        shortCycles++;
      } else if (cycle.cycleDays > 35) {
        longCycles++;
      } else {
        normalCycles++;
      }
    }

    final totalCycles = recentCycles.length;

    // Tạo mô tả chi tiết như trong hình iOS với bold text
    if (totalCycles == 1) {
      final cycle = recentCycles.first;
      if (cycle.cycleDays < 21) {
        return Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Chu kỳ đầu tiên của bạn là ',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
              TextSpan(
                text: 'ngắn',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[700],
                  height: 1.4,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text:
                    '. Hãy theo dõi thêm vài chu kỳ nữa để có cái nhìn tổng quan về xu hướng chu kỳ của bạn.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
            ],
          ),
        );
      } else if (cycle.cycleDays > 35) {
        return Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Chu kỳ đầu tiên của bạn là ',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
              TextSpan(
                text: 'dài',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[700],
                  height: 1.4,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text:
                    '. Hãy theo dõi thêm vài chu kỳ nữa để có cái nhìn tổng quan về xu hướng chu kỳ của bạn.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
            ],
          ),
        );
      } else {
        return Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Chu kỳ đầu tiên của bạn nằm trong khoảng ',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
              TextSpan(
                text: 'bình thường',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[700],
                  height: 1.4,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text:
                    '. Hãy theo dõi thêm vài chu kỳ nữa để có cái nhìn tổng quan về xu hướng chu kỳ của bạn.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
            ],
          ),
        );
      }
    } else {
      List<TextSpan> textSpans = [];

      // Phần đầu
      textSpans.add(
        TextSpan(
          text: 'Trong $totalCycles chu kỳ hoàn chỉnh gần đây nhất của bạn có ',
          style: TextStyle(fontSize: 15, color: Colors.grey[700], height: 1.4),
        ),
      );

      // Thêm các loại chu kỳ với bold
      List<String> cycleTypes = [];
      if (shortCycles > 0) cycleTypes.add('$shortCycles chu kỳ ngắn');
      if (longCycles > 0) cycleTypes.add('$longCycles chu kỳ dài');
      if (normalCycles > 0) cycleTypes.add('$normalCycles chu kỳ bình thường');

      for (int i = 0; i < cycleTypes.length; i++) {
        final cycleType = cycleTypes[i];
        final parts = cycleType.split(' ');
        final number = parts[0];
        final type = parts[2]; // "ngắn", "dài", hoặc "bình thường"

        textSpans.add(
          TextSpan(
            text: '$number chu kỳ ',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
        );

        textSpans.add(
          TextSpan(
            text: type,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[700],
              height: 1.4,
              fontWeight: FontWeight.bold,
            ),
          ),
        );

        if (i < cycleTypes.length - 1) {
          textSpans.add(
            TextSpan(
              text: ' và ',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          );
        }
      }

      // Phần cuối
      textSpans.add(
        TextSpan(
          text: '. Hãy xem đồ thị bên dưới để biết xu hướng chu kỳ của bạn.',
          style: TextStyle(fontSize: 15, color: Colors.grey[700], height: 1.4),
        ),
      );

      return Text.rich(TextSpan(children: textSpans));
    }
  }
}

// Helper classes
class ChartData {
  final double x;
  final double cycleLength;
  final double periodLength;
  final DateTime date;

  ChartData({
    required this.x,
    required this.cycleLength,
    required this.periodLength,
    required this.date,
  });
}

class YAxisRange {
  final double minY;
  final double maxY;
  final List<double> ticks;

  YAxisRange({required this.minY, required this.maxY, required this.ticks});
}

class HealthStatus {
  final String status;
  final Color color;
  final IconData icon;

  HealthStatus({required this.status, required this.color, required this.icon});
}

class MedicalAdvice {
  final bool shouldSeek;
  final List<String> reasons;

  MedicalAdvice({required this.shouldSeek, required this.reasons});
}

// Custom painter để hiển thị text trên dots
class FlDotTextPainter extends FlDotPainter {
  final double radius;
  final Color color;
  final double strokeWidth;
  final String text;
  final TextStyle textStyle;

  FlDotTextPainter({
    required this.radius,
    required this.color,
    required this.strokeWidth,
    required this.text,
    required this.textStyle,
  });

  @override
  void draw(Canvas canvas, FlSpot spot, Offset offsetInCanvas) {
    // Vẽ dot
    canvas.drawCircle(
      offsetInCanvas,
      radius,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );

    // Vẽ text
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final textOffset = Offset(
      offsetInCanvas.dx - textPainter.width / 2,
      offsetInCanvas.dy - radius - textPainter.height - 4,
    );

    textPainter.paint(canvas, textOffset);
  }

  @override
  Size getSize(FlSpot spot) {
    return Size(radius * 2, radius * 2);
  }

  @override
  Color get mainColor => color;

  @override
  List<Object?> get props => [radius, color, strokeWidth, text, textStyle];

  @override
  FlDotPainter lerp(FlDotPainter? a, FlDotPainter? b, double t) {
    if (a is FlDotTextPainter && b is FlDotTextPainter) {
      return FlDotTextPainter(
        radius: lerpDouble(a.radius, b.radius, t) ?? a.radius,
        color: Color.lerp(a.color, b.color, t) ?? a.color,
        strokeWidth:
            lerpDouble(a.strokeWidth, b.strokeWidth, t) ?? a.strokeWidth,
        text: t < 0.5 ? a.text : b.text,
        textStyle: TextStyle.lerp(a.textStyle, b.textStyle, t) ?? a.textStyle,
      );
    }
    return this;
  }
}
