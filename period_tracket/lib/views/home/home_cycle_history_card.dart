// lib/views/home/home_cycle_history_card.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:period_tracket/views/cycle_history/add_previous_cycle_view.dart';
import 'package:period_tracket/views/cycle_history/cycle_history_view.dart';
import 'package:period_tracket/views/data/cycle_data.dart';
import 'package:period_tracket/views/data/data_manager.dart';
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CycleHistoryView(),
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
            // Hiển thị nút Add chỉ khi có đúng 1 chu kỳ (chỉ chu kỳ hiện tại)
            // Hiển thị nút Edit khi có >= 2 chu kỳ
            if (dm.cycleHistory.length == 1) ...[
              const SizedBox(height: 8),
              _AddCycleButton(),
            ] else if (dm.cycleHistory.length >= 2) ...[
              const SizedBox(height: 8),
              _EditCycleButton(),
            ],
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

class _EditCycleButton extends StatelessWidget {
  const _EditCycleButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 4),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          _showEditCycleDialog(context);
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE5E5EA), // iOS system gray 5
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 1,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFF34C759), // iOS system green
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.edit, size: 14, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const Text(
                'Chỉnh sửa chu kỳ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF34C759), // iOS system green
                  letterSpacing: -0.24, // iOS letter spacing
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditCycleDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text(
          'Chỉnh sửa chu kỳ',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        content: const Text(
          'Bạn có thể chỉnh sửa thông tin chu kỳ đã thêm. Chọn chu kỳ bạn muốn chỉnh sửa từ danh sách bên dưới.',
          style: TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text(
              'Hủy',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w400),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text(
              'Xem danh sách',
              style: TextStyle(
                color: Color(0xFF007AFF),
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: () {
              Navigator.pop(context); // Đóng dialog
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const AddPreviousCycleView(isEditMode: true),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AddCycleButton extends StatelessWidget {
  const _AddCycleButton();

  void _showAddCycleWarningDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text(
          'Thêm chu kỳ trước đó',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        content: const Text(
          'Bạn chỉ có thể thêm các chu kỳ trước đó một lần duy nhất. Hãy chọn chính xác ngày bắt đầu và kết thúc chu kỳ, cũng như độ dài kỳ kinh để đảm bảo dữ liệu chính xác.',
          style: TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text(
              'Hủy',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w400),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text(
              'Tiếp tục',
              style: TextStyle(
                color: Color(0xFF007AFF),
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: () {
              Navigator.pop(context); // Đóng dialog
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddPreviousCycleView(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 4),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          _showAddCycleWarningDialog(context);
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE5E5EA), // iOS system gray 5
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 1,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFF007AFF), // iOS system blue
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, size: 14, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const Text(
                'Thêm chu kỳ trước đó',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF007AFF), // iOS system blue
                  letterSpacing: -0.24, // iOS letter spacing
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
