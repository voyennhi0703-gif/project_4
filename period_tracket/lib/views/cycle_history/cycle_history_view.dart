import 'package:flutter/material.dart';
import 'package:period_tracket/views/data/cycle_data.dart';
import 'package:period_tracket/views/data/data_manager.dart';
import 'package:provider/provider.dart';

class CycleHistoryView extends StatefulWidget {
  const CycleHistoryView({super.key});

  @override
  State<CycleHistoryView> createState() => _CycleHistoryViewState();
}

class _CycleHistoryViewState extends State<CycleHistoryView> {
  String _selectedTab = 'Tất cả'; // Tab mặc định khi mở trang

  @override
  Widget build(BuildContext context) {
    return Consumer<DataManager>(
      builder: (context, dataManager, child) {
        // Lấy tất cả chu kỳ và sắp xếp theo ngày giảm dần (mới nhất trước)
        final allCycles = List<CycleData>.from(dataManager.cycleHistory)
          ..sort((a, b) => b.startDate.compareTo(a.startDate));

        // Lấy 3 chu kỳ gần nhất (mới nhất)
        final recent3Cycles = allCycles.take(3).toList();

        // Lấy 6 chu kỳ gần nhất (mới nhất)
        final recent6Cycles = allCycles.take(6).toList();

        // Xác định các tab có sẵn - "Tất cả" luôn có mặt
        List<String> availableTabs = ['Tất cả'];
        if (allCycles.length >= 3) {
          availableTabs.add('3 chu kỳ gần nhất');
        }
        if (allCycles.length >= 6) {
          availableTabs.add('6 chu kỳ gần nhất');
        }

        // Đặt tab mặc định là "Tất cả" khi mở trang lần đầu
        if (!availableTabs.contains(_selectedTab)) {
          _selectedTab = 'Tất cả';
        }

        // Lấy dữ liệu theo tab được chọn
        List<CycleData> displayCycles;
        switch (_selectedTab) {
          case '3 chu kỳ gần nhất':
            displayCycles = recent3Cycles;
            break;
          case '6 chu kỳ gần nhất':
            displayCycles = recent6Cycles;
            break;
          default: // 'Tất cả'
            displayCycles = allCycles;
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Lịch sử chu kỳ',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: false,
          ),
          body: Column(
            children: [
              // Tab navigation
              if (availableTabs.length > 1) ...[
                Container(
                  height: 40,
                  margin: const EdgeInsets.all(16),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: availableTabs.length,
                    itemBuilder: (context, index) {
                      final tab = availableTabs[index];
                      final isSelected = _selectedTab == tab;
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedTab = tab;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isSelected
                                ? Colors.pink.shade300
                                : Colors.white,
                            foregroundColor: isSelected
                                ? Colors.white
                                : Colors.grey.shade600,
                            elevation: isSelected ? 2 : 0,
                            side: isSelected
                                ? null
                                : BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(tab),
                        ),
                      );
                    },
                  ),
                ),
              ],

              // Legend
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildLegendItem(const Color(0xFFFF4081), 'Kỳ kinh'),
                    _buildLegendItem(
                      const Color(0xFF4DD0E1),
                      'Khung thời gian thụ thai',
                    ),
                    _buildLegendItem(
                      const Color.fromARGB(255, 235, 11, 160),
                      'Rụng trứng',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Cycle list
              Expanded(
                child: displayCycles.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Chưa có dữ liệu chu kỳ',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Hãy bắt đầu theo dõi chu kỳ của bạn',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _buildGroupedCycles(displayCycles).length,
                        itemBuilder: (context, index) {
                          final group = _buildGroupedCycles(
                            displayCycles,
                          )[index];
                          return _buildCycleGroup(group);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black87),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _buildGroupedCycles(List<CycleData> cycles) {
    if (cycles.isEmpty) return [];

    // Nhóm theo năm
    Map<int, List<CycleData>> groupedByYear = {};
    for (final cycle in cycles) {
      final year = cycle.startDate.year;
      if (!groupedByYear.containsKey(year)) {
        groupedByYear[year] = [];
      }
      groupedByYear[year]!.add(cycle);
    }

    // Sắp xếp theo năm giảm dần
    final sortedYears = groupedByYear.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    List<Map<String, dynamic>> result = [];
    for (final year in sortedYears) {
      final yearCycles = groupedByYear[year]!;
      // Sắp xếp chu kỳ trong năm theo ngày giảm dần
      yearCycles.sort((a, b) => b.startDate.compareTo(a.startDate));

      result.add({'year': year, 'cycles': yearCycles});
    }

    return result;
  }

  Widget _buildCycleGroup(Map<String, dynamic> group) {
    final year = group['year'] as int;
    final cycles = group['cycles'] as List<CycleData>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Year header
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            year.toString(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),

        // Cycles in this year
        ...cycles.asMap().entries.map((entry) {
          final index = entry.key;
          final cycle = entry.value;
          final isCurrent = index == 0 && year == DateTime.now().year;

          return _buildCycleItem(cycle, isCurrent);
        }),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildCycleItem(CycleData cycle, bool isCurrent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cycle info
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isCurrent
                          ? 'Chu kỳ hiện tại: ${cycle.cycleDays} ngày'
                          : '${cycle.cycleDays} ngày',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isCurrent
                          ? 'Đã bắt đầu ${_formatDate(cycle.startDate)}'
                          : '${_formatDate(cycle.startDate)} – ${_formatDate(cycle.startDate.add(Duration(days: cycle.cycleDays - 1)))}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.black26, size: 20),
            ],
          ),

          const SizedBox(height: 8),

          // Cycle dots
          _buildCycleDots(cycle),

          const SizedBox(height: 12),

          // Divider
          Container(height: 1, color: Colors.grey[200]),
        ],
      ),
    );
  }

  Widget _buildCycleDots(CycleData cycle) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(cycle.cycleDays, (i) {
          final day = i + 1;
          Color color;

          if (day <= cycle.periodDays) {
            color = const Color(0xFFFF4081); // Kỳ kinh - đỏ
          } else if (day == cycle.ovulationDay) {
            color = const Color.fromARGB(
              255,
              232,
              13,
              225,
            ); // Rụng trứng - xanh đậm
          } else if (day >= cycle.fertileStartDay &&
              day <= cycle.fertileEndDay) {
            color = const Color(
              0xFF4DD0E1,
            ); // Khung thời gian thụ thai - xanh nhạt
          } else {
            color = const Color(0xFFE9E9EE); // Ngày bình thường - xám
          }

          return Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(right: 6),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          );
        }),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day} thg ${date.month}';
  }
}
