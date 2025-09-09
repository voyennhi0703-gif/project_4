import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:period_tracket/views/data/cycle_data.dart';
import 'package:provider/provider.dart';

import '../data/data_manager.dart';

class OldCycleAddPage extends StatefulWidget {
  const OldCycleAddPage({super.key});

  @override
  State<OldCycleAddPage> createState() => _OldCycleAddPageState();
}

class _OldCycleAddPageState extends State<OldCycleAddPage> {
  late DateTime _yearAnchor;
  final Set<DateTime> _selectedDays = {}; // tick của user
  final List<Set<DateTime>> _savedCycles = []; // nhiều chu kỳ trong 1 phiên

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _yearAnchor = DateTime(now.year, 1, 1);
    _preselectCurrentPeriod();
  }

  void _preselectCurrentPeriod() {
    final dm = context.read<DataManager>();
    if (dm.cycleHistory.isEmpty) return;
    final current = dm.cycleHistory.first;
    for (int i = 0; i < current.periodDays; i++) {
      final d = DateTime(
        current.startDate.year,
        current.startDate.month,
        current.startDate.day,
      ).add(Duration(days: i));
      _selectedDays.add(d);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final dm = context.watch<DataManager>();

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Thêm chu kỳ cũ'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _selectedDays.isNotEmpty ? _saveOneCycle : null,
          child: const Text('Lưu chu kỳ'),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _YearSwitcher(
              year: _yearAnchor.year,
              onPrev: () => setState(() {
                _yearAnchor = DateTime(_yearAnchor.year - 1, 1, 1);
              }),
              onNext: () => setState(() {
                _yearAnchor = DateTime(_yearAnchor.year + 1, 1, 1);
              }),
            ),

            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: 12,
                itemBuilder: (_, i) {
                  final month = DateTime(_yearAnchor.year, i + 1, 1);
                  return _MonthBlock(
                    month: month,
                    selectedDays: _selectedDays,
                    highlightPredicate: (d) =>
                        dm.isPeriodDay(d), // viền hồng cho chu kỳ hiện tại
                    onToggle: (d) {
                      setState(() {
                        final key = DateTime(d.year, d.month, d.day);
                        if (_selectedDays.contains(key)) {
                          _selectedDays.remove(key);
                        } else {
                          _selectedDays.add(key);
                        }
                      });
                    },
                  );
                },
              ),
            ),

            // footer
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: CupertinoButton.filled(
                      onPressed: _selectedDays.isNotEmpty
                          ? _saveOneCycle
                          : null,
                      child: const Text('Lưu chu kỳ đang chọn'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  CupertinoButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      if (_savedCycles.isNotEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Đã thêm ${_savedCycles.length} chu kỳ',
                            ),
                          ),
                        );
                      }
                    },
                    child: const Text('Đóng'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveOneCycle() {
    final dm = context.read<DataManager>();
    final list = _selectedDays.toList()..sort();
    if (list.isEmpty) return;

    final start = list.first;
    final periodDays = list.length;

    // ước lượng cycleDays từ lịch sử (giống logic bạn viết)
    final cycleDays = _estimateCycleLength(start, dm).clamp(21, 40);
    dm.addCycleHistory(
      CycleData(startDate: start, periodDays: periodDays, cycleDays: cycleDays),
    );

    _savedCycles.add({..._selectedDays});
    _selectedDays.clear();
    setState(() {});
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Đã lưu chu kỳ $cycleDays ngày')));
  }

  int _estimateCycleLength(DateTime currentStart, DataManager dm) {
    final starts = <DateTime>[
      ...dm.cycleHistory.map((e) => e.startDate),
      ..._savedCycles.map((s) => (s.toList()..sort()).first),
    ]..sort();
    // tìm ngày bắt đầu kế tiếp
    for (final s in starts) {
      if (s.isAfter(currentStart)) {
        final d = s.difference(currentStart).inDays;
        if (d >= 20 && d <= 45) return d;
      }
    }
    // trung bình
    if (starts.length >= 2) {
      final lens = <int>[];
      for (int i = 0; i < starts.length - 1; i++) {
        final d = starts[i + 1].difference(starts[i]).inDays;
        if (d >= 20 && d <= 45) lens.add(d);
      }
      if (lens.isNotEmpty) {
        return (lens.reduce((a, b) => a + b) / lens.length).round();
      }
    }
    // fallback
    return dm.cycleHistory.isNotEmpty ? dm.cycleHistory.first.cycleDays : 28;
  }
}

class _YearSwitcher extends StatelessWidget {
  final int year;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  const _YearSwitcher({
    required this.year,
    required this.onPrev,
    required this.onNext,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.black)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CupertinoButton(
            onPressed: onPrev,
            padding: EdgeInsets.zero,
            child: const Icon(CupertinoIcons.chevron_left),
          ),
          Text(
            '$year',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.none,
            ),
          ),
          CupertinoButton(
            onPressed: onNext,
            padding: EdgeInsets.zero,
            child: const Icon(CupertinoIcons.chevron_right),
          ),
        ],
      ),
    );
  }
}

class _MonthBlock extends StatelessWidget {
  final DateTime month;
  final Set<DateTime> selectedDays;
  final bool Function(DateTime)
  highlightPredicate; // ngày thuộc kỳ kinh hiện tại?
  final void Function(DateTime) onToggle;
  const _MonthBlock({
    required this.month,
    required this.selectedDays,
    required this.highlightPredicate,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final first = DateTime(month.year, month.month, 1);
    final last = DateTime(month.year, month.month + 1, 0);
    final days = last.day;
    final startWeekday = first.weekday % 7; // CN=0

    List<Widget> cells = [];

    // header “Tháng x”
    cells.add(
      Padding(
        padding: const EdgeInsets.only(top: 14, bottom: 8),
        child: Center(
          child: Text(
            'Tháng ${month.month}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ),
    );

    // tên thứ
    const wds = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
    cells.add(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: wds
              .map(
                (e) => Text(
                  e,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                    decoration: TextDecoration.none,
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
    cells.add(const SizedBox(height: 6));

    // lưới
    final gridChildren = <Widget>[];
    for (int i = 0; i < startWeekday; i++) {
      gridChildren.add(const SizedBox());
    }
    for (int d = 1; d <= days; d++) {
      final date = DateTime(month.year, month.month, d);
      final key = DateTime(date.year, date.month, date.day);
      final isSel = selectedDays.contains(key);
      final isCurrentPeriod = highlightPredicate(date);

      gridChildren.add(
        GestureDetector(
          onTap: () => onToggle(date),
          child: Container(
            margin: const EdgeInsets.all(4),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSel ? const Color(0xFFFF4081) : Colors.transparent,
              border: isSel
                  ? null
                  : isCurrentPeriod
                  ? Border.all(color: const Color(0xFFFF4081), width: 2)
                  : Border.all(color: Colors.black),
            ),
            child: Center(
              child: Text(
                '$d',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  decoration: TextDecoration.none,
                  color: isSel
                      ? Colors.white
                      : isCurrentPeriod
                      ? const Color(0xFFFF4081)
                      : Colors.black,
                ),
              ),
            ),
          ),
        ),
      );
    }

    cells.add(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: GridView.count(
          crossAxisCount: 7,
          childAspectRatio: 1,
          mainAxisSpacing: 2,
          crossAxisSpacing: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: gridChildren,
        ),
      ),
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: cells),
    );
  }
}
