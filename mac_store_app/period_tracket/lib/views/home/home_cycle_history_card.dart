import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:period_tracket/views/data/cycle_data.dart';
import 'package:period_tracket/views/data/data_manager.dart';
import 'package:period_tracket/views/home/cycle_history_view.dart';
import 'package:provider/provider.dart';

class HomeCycleHistoryCard extends StatelessWidget {
  const HomeCycleHistoryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final dm = context.watch<DataManager>();
    final items = dm.cycleHistory.take(3).toList();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Lịch sử chu kỳ',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                CupertinoButton(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CycleHistoryView(),
                      ),
                    );
                  },
                  child: const Text('Xem tất cả >'),
                ),
              ],
            ),
            ...items.asMap().entries.map((e) {
              final idx = e.key;
              final c = e.value;
              final isCurrent = idx == 0;
              return _HistoryListTile(
                title: isCurrent
                    ? 'Chu kỳ hiện tại: ${c.cycleDays} ngày'
                    : '${c.cycleDays} ngày',
                sub: isCurrent
                    ? 'Đã bắt đầu ${_fmt(c.startDate)}'
                    : '${_fmt(c.startDate)} – ${_fmt(c.startDate.add(Duration(days: c.cycleDays - 1)))}',
                cycle: c,
              );
            }),
          ],
        ),
      ),
    );
  }

  static String _fmt(DateTime d) => '${d.day} thg ${d.month}';
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
    return Padding(
      padding: const EdgeInsets.only(right: 8, top: 6, bottom: 6),
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
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sub,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.black26),
            ],
          ),
          const SizedBox(height: 6),
          _CycleDotsRow(cycle: cycle),
          const SizedBox(height: 10),
          const Divider(height: 1),
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
