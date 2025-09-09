import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:period_tracket/common/colo_extension.dart';
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
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: const Text(
              'Phân tích',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          ),
          body: SingleChildScrollView(
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
                        value: '${_calculateAverageCycleLength(dataManager)}',
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
                        value: '${_calculateAveragePeriodLength(dataManager)}',
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
                  padding: const EdgeInsets.all(24),
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
                      const SizedBox(height: 20),
                      _buildInsightRow(
                        'Giai đoạn hiện tại',
                        dataManager.cyclePhase,
                      ),
                      const SizedBox(height: 4),
                      _buildInsightRow(
                        'Khả năng thụ thai',
                        dataManager.getPregnancyChance(),
                      ),
                      const SizedBox(height: 4),
                      _buildInsightRow(
                        'Ngày rụng trứng tiếp theo',
                        dataManager.ovulationDate != null
                            ? dataManager.formatDate(dataManager.ovulationDate)
                            : 'Chưa có dữ liệu',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Bar Chart with data type selection
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
                        'Xu hướng chu kỳ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Chart
                      SizedBox(
                        height: 300,
                        child: _buildCycleLineChart(dataManager),
                      ),

                      const SizedBox(height: 16),

                      // Legend and explanation
                      _buildChartLegend(),

                      const SizedBox(height: 16),

                      // Cycle status indicator
                      _buildCycleStatusIndicator(dataManager),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Medical advice card
                _buildMedicalAdviceCard(dataManager),
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
      return TColor.rosePink; // Normal - rose pink
    } else if (cycleLength < 21) {
      return TColor.coral; // Short - coral
    } else {
      return TColor.blushPink; // Long - blush pink
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

  Widget _buildCycleLineChart(DataManager dataManager) {
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
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Hãy theo dõi ít nhất 2-3 chu kỳ để xem biểu đồ',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 5,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: Colors.grey[300]!, strokeWidth: 0.5);
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 5,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < chartData.length) {
                  final data = chartData[value.toInt()];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      '${data.date.day} th ${data.date.month}',
                      style: const TextStyle(fontSize: 9, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return const Text('');
              },
            ),
            axisNameWidget: const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(
                'Ngày bắt đầu chu kỳ',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          rightTitles: AxisTitles(
            sideTitles: const SideTitles(showTitles: false),
            axisNameWidget: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: RotatedBox(
                quarterTurns: 1,
                child: Text(
                  'Độ dài chu kỳ (ngày)',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
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
            color: Colors.grey[600]!,
            barWidth: 2,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                final data = chartData[index];
                final cycleLength = data.cycleLength.toInt();

                Color dotColor;
                if (_isCycleLengthNormal(cycleLength)) {
                  dotColor = Colors.green;
                } else if (cycleLength < 21) {
                  dotColor = Colors.orange;
                } else {
                  dotColor = Colors.red;
                }

                return FlDotCirclePainter(
                  radius: 6,
                  color: dotColor,
                  strokeWidth: 0,
                );
              },
            ),
            belowBarData: BarAreaData(show: false),
          ),
        ],
        minY: 15,
        maxY: 45,
        lineTouchData: LineTouchData(
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
          touchCallback:
              (FlTouchEvent event, LineTouchResponse? touchResponse) {},
          handleBuiltInTouches: true,
        ),
        // Thêm các đường kẻ ngang để hiển thị vùng bình thường
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            // Vùng chu kỳ bình thường 21-35 ngày
            HorizontalLine(
              y: 21,
              color: Colors.green.withOpacity(0.3),
              strokeWidth: 1,
              dashArray: [5, 5],
            ),
            HorizontalLine(
              y: 35,
              color: Colors.green.withOpacity(0.3),
              strokeWidth: 1,
              dashArray: [5, 5],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartLegend() {
    return Column(
      children: [
        // Chú thích cho các điểm dữ liệu
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildLegendItem('Bình thường (21-35)', Colors.green),
            _buildLegendItem('Ngắn (<21)', Colors.orange),
            _buildLegendItem('Dài (>35)', Colors.red),
          ],
        ),
        const SizedBox(height: 8),
        // Chú thích cho vùng bình thường
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 20,
              height: 1,
              decoration: BoxDecoration(color: Colors.green.withOpacity(0.5)),
            ),
            const SizedBox(width: 6),
            Text(
              'Phạm vi bình thường theo ACOG (21 - 35 ngày)',
              style: TextStyle(
                fontSize: 11,
                color: Colors.green[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildCycleStatusIndicator(DataManager dataManager) {
    if (dataManager.cycleHistory.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue[200]!, width: 1),
        ),
        child: Row(
          children: [
            Icon(Icons.info, color: Colors.blue, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Chưa có đủ dữ liệu để đánh giá chu kỳ. Hãy theo dõi thêm vài chu kỳ nữa.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue[800],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Phân tích chi tiết các chu kỳ
    int normalCycles = 0;
    int shortCycles = 0;
    int longCycles = 0;
    int normalPeriods = 0;
    int shortPeriods = 0;
    int longPeriods = 0;

    for (final cycle in dataManager.cycleHistory) {
      // Phân loại chu kỳ
      if (_isCycleLengthNormal(cycle.cycleDays)) {
        normalCycles++;
      } else if (cycle.cycleDays < 21) {
        shortCycles++;
      } else {
        longCycles++;
      }

      // Phân loại kỳ kinh
      if (_isPeriodLengthNormal(cycle.periodDays)) {
        normalPeriods++;
      } else if (cycle.periodDays < 3) {
        shortPeriods++;
      } else {
        longPeriods++;
      }
    }

    final totalCycles = dataManager.cycleHistory.length;
    final normalCyclePercentage = (normalCycles / totalCycles * 100).round();
    final normalPeriodPercentage = (normalPeriods / totalCycles * 100).round();

    // Xác định trạng thái tổng thể
    String overallStatus;
    Color overallColor;
    IconData overallIcon;
    String detailText;

    if (normalCyclePercentage >= 80 && normalPeriodPercentage >= 80) {
      overallStatus = 'Rất ổn định';
      overallColor = Colors.green;
      overallIcon = Icons.check_circle;
      detailText =
          'Chu kỳ và kỳ kinh của bạn đều trong phạm vi bình thường. Tiếp tục duy trì lối sống lành mạnh.';
    } else if (normalCyclePercentage >= 60 && normalPeriodPercentage >= 60) {
      overallStatus = 'Tương đối ổn định';
      overallColor = Colors.amber;
      overallIcon = Icons.timeline;
      detailText =
          'Có một số biến động nhẹ trong chu kỳ. Hãy theo dõi thêm và chú ý đến các yếu tố ảnh hưởng như căng thẳng, dinh dưỡng.';
    } else {
      overallStatus = 'Cần theo dõi';
      overallColor = Colors.orange;
      overallIcon = Icons.warning;
      detailText =
          'Chu kỳ có nhiều biến động. Nên tham khảo ý kiến bác sĩ chuyên khoa để được tư vấn.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: overallColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: overallColor.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(overallIcon, color: overallColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Tình trạng: $overallStatus',
                style: TextStyle(
                  fontSize: 14,
                  color: overallColor.withOpacity(0.9),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Text(
            detailText,
            style: TextStyle(
              fontSize: 12,
              color: overallColor.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 12),

          // Thống kê chi tiết
          _buildStatRow(
            'Chu kỳ bình thường:',
            '$normalCycles/$totalCycles ($normalCyclePercentage%)',
            overallColor,
          ),
          _buildStatRow(
            'Kỳ kinh bình thường:',
            '$normalPeriods/$totalCycles ($normalPeriodPercentage%)',
            overallColor,
          ),

          if (shortCycles > 0)
            _buildStatRow(
              'Chu kỳ ngắn (<21 ngày):',
              '$shortCycles/$totalCycles',
              Colors.orange,
            ),

          if (longCycles > 0)
            _buildStatRow(
              'Chu kỳ dài (>35 ngày):',
              '$longCycles/$totalCycles',
              Colors.red,
            ),

          if (shortPeriods > 0)
            _buildStatRow(
              'Kỳ kinh ngắn (<3 ngày):',
              '$shortPeriods/$totalCycles',
              Colors.orange,
            ),

          if (longPeriods > 0)
            _buildStatRow(
              'Kỳ kinh dài (>7 ngày):',
              '$longPeriods/$totalCycles',
              Colors.red,
            ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 11, color: color.withOpacity(0.8)),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              color: color.withOpacity(0.9),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
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
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFFFF4081),
              ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
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
