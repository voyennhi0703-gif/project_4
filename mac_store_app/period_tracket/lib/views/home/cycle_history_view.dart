import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:period_tracket/views/data/cycle_data.dart';
import 'package:period_tracket/views/data/data_manager.dart';
import 'package:period_tracket/views/home/old_cycle_add_view.dart';
import 'package:provider/provider.dart';

class CycleHistoryView extends StatefulWidget {
  const CycleHistoryView({super.key});
  @override
  State<CycleHistoryView> createState() => _CycleHistoryPageState();
}

class _CycleHistoryPageState extends State<CycleHistoryView> {
  int _seg = 0; // 0: all, 1: 3, 2: 6

  @override
  Widget build(BuildContext context) {
    final dm = context.watch<DataManager>();
    final cycles = [...dm.cycleHistory];
    final shown = _seg == 0 ? cycles : cycles.take(_seg == 1 ? 3 : 6).toList();

    // group by year
    final Map<int, List<CycleData>> byYear = {};
    for (final c in shown) {
      byYear.putIfAbsent(c.startDate.year, () => []).add(c);
    }
    final years = byYear.keys.toList()..sort((a, b) => b.compareTo(a));

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Lịch sử chu kỳ'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            Navigator.of(
              context,
            ).push(CupertinoPageRoute(builder: (_) => const OldCycleAddPage()));
          },
          child: const Text('Thêm'),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),

            // 🔥 Thay thế segmented control bằng scrollable pill buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildPillButton("Tất cả", 0, minWidth: 100),
                    const SizedBox(width: 8),
                    _buildPillButton("3 tháng gần nhất", 1, minWidth: 150),
                    const SizedBox(width: 8),
                    _buildPillButton("6 tháng gần nhất", 2, minWidth: 150),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),
            const _LegendRow(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                itemCount: years.length,
                itemBuilder: (_, i) {
                  final y = years[i];
                  final list = byYear[y]!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                        child: Text(
                          '$y',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                      ...list.asMap().entries.map((e) {
                        final c = e.value;
                        final isCurrent =
                            dm.cycleHistory.isNotEmpty &&
                            identical(c, dm.cycleHistory.first);
                        return _HistoryListTile(
                          title: isCurrent
                              ? 'Chu kỳ hiện tại: ${c.cycleDays} ngày'
                              : '${c.cycleDays} ngày',
                          sub: isCurrent
                              ? 'Đã bắt đầu ${_d(c.startDate)}'
                              : '${_d(c.startDate)} – ${_d(c.startDate.add(Duration(days: c.cycleDays - 1)))}',
                          cycle: c,
                        );
                      }),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Hàm dựng pill button
  Widget _buildPillButton(String text, int value, {double minWidth = 100}) {
    final bool selected = _seg == value;
    return GestureDetector(
      onTap: () {
        setState(() => _seg = value);
      },
      child: Container(
        constraints: BoxConstraints(minWidth: minWidth),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFE91E63)
              : Colors.white, // nền hồng đậm khi chọn
          borderRadius: BorderRadius.circular(30), // bo tròn nhiều
          border: Border.all(
            color: selected ? const Color(0xFFE91E63) : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : Colors.grey[700],
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ),
    );
  }

  String _d(DateTime d) => '${d.day} thg ${d.month}';
}

class _LegendRow extends StatelessWidget {
  const _LegendRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _LegendItem(color: Color(0xFFFF4081), text: 'Kỳ kinh'),
          _LegendItem(
            color: Color(0xFF4DD0E1),
            text: 'Khung thời gian thụ thai',
          ),
          _LegendItem(color: Color(0xFF26C6DA), text: 'Rụng trứng'),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String text;
  const _LegendItem({required this.color, required this.text});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }
}

class _HistoryListTile extends StatelessWidget {
  const _HistoryListTile({
    required this.title,
    required this.sub,
    required this.cycle,
  });
  final String title;
  final String sub;
  final CycleData cycle;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(4, 6, 4, 6),
      padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sub,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.black26),
            ],
          ),
          const SizedBox(height: 8),
          _CycleDotsRow(cycle: cycle),
        ],
      ),
    );
  }
}

class _CycleDotsRow extends StatelessWidget {
  const _CycleDotsRow({required this.cycle});
  final CycleData cycle;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(cycle.cycleDays, (i) {
          final day = i + 1;
          Color color;
          if (day <= cycle.periodDays) {
            color = const Color(0xFFFF4081);
          } else if (day == cycle.ovulationDay) {
            color = const Color(0xFF26C6DA);
          } else if (day >= cycle.fertileStartDay &&
              day <= cycle.fertileEndDay) {
            color = const Color(0xFF4DD0E1);
          } else {
            color = const Color(0xFFE9E9EE);
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
}
