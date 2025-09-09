import 'package:flutter/material.dart';
import 'package:period_tracket/common/colo_extension.dart';
import 'package:period_tracket/views/calendar/calendar_view.dart';
import 'package:period_tracket/views/data/data_manager.dart';
import 'package:period_tracket/views/home/cycle_history_view.dart';
import 'package:period_tracket/views/home/settings_view.dart';
import 'package:period_tracket/views/mood/mood_stats_view.dart';
import 'package:period_tracket/views/mood/mood_tracker_view.dart';
import 'package:provider/provider.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => HomeViewState();
}

class HomeViewState extends State<HomeView> {
  // State cho daily mood tracker
  List<String> selectedMoods = [];
  List<String> selectedSymptoms = [];

  // Method để hiển thị daily mood tracker
  void _showDailyMoodTracker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                    const Text(
                      'Hôm nay',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 48), // Placeholder for symmetry
                  ],
                ),
              ),

              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    const Text(
                      'Ngày chu kỳ 15',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 24),

                    // Search bar
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.search, color: Colors.grey),
                          SizedBox(width: 8),
                          Text(
                            'Tìm kiếm',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSymptomChip({
    required String icon,
    required String label,
    required Color color,
  }) {
    bool isSelected = selectedSymptoms.contains(label);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            selectedSymptoms.remove(label);
          } else {
            selectedSymptoms.add(label);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.8) : color.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? Border.all(color: color, width: 2) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: Colors.black87,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openMoodTracker(BuildContext context, int currentCycleDay) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MoodTrackerView(
        currentCycleDay: currentCycleDay,
        onMoodSaved: (moodData) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Tâm trạng đã được lưu")),
          );
        },
      ),
    );
  }

  void _showSettingsDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsView()),
    );
  }

  void _openCalendar() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CalendarView()),
    );
  }

  void _showCycleDetails(DataManager dataManager) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CycleHistoryView()),
    );
  }

  void _showTodayDetails(DataManager dataManager) {
    // Implementation for showing today's details
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chi tiết hôm nay'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ngày chu kỳ: ${dataManager.currentCycleDay}'),
            Text('Giai đoạn: ${dataManager.cyclePhase}'),
            Text('Khả năng thụ thai: ${dataManager.getPregnancyChance()}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showOnboardingRedirect() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chưa có dữ liệu chu kỳ'),
        content: const Text(
          'Vui lòng thiết lập thông tin chu kỳ để sử dụng tính năng này.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showStartCycleDialog(DataManager dataManager) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bắt đầu chu kỳ mới'),
        content: const Text(
          'Bạn có muốn bắt đầu chu kỳ kinh nguyệt mới không?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              dataManager.updateStartDate(DateTime.now());
              Navigator.pop(context);
            },
            child: const Text('Bắt đầu'),
          ),
        ],
      ),
    );
  }

  void _showEndCycleDialog(DataManager dataManager) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kết thúc chu kỳ'),
        content: const Text(
          'Bạn có muốn kết thúc chu kỳ kinh nguyệt hiện tại không?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              // Logic to end cycle
              Navigator.pop(context);
            },
            child: const Text('Kết thúc'),
          ),
        ],
      ),
    );
  }

  void _showCycleStats(DataManager dataManager) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thống kê chu kỳ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Chu kỳ trung bình: ${dataManager.cycleDuration} ngày'),
            Text('Kỳ kinh trung bình: ${dataManager.periodDuration} ngày'),
            Text('Số chu kỳ đã ghi: ${dataManager.cycleHistory.length}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _editPeriodDuration(DataManager dataManager) {
    showDialog(
      context: context,
      builder: (context) {
        int newDuration = dataManager.periodDuration;
        return AlertDialog(
          title: const Text('Chỉnh sửa thời gian kỳ kinh'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Thời gian kỳ kinh: $newDuration ngày'),
                  Slider(
                    value: newDuration.toDouble(),
                    min: 3,
                    max: 7,
                    divisions: 4,
                    onChanged: (value) {
                      setState(() {
                        newDuration = value.round();
                      });
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                dataManager.updatePeriodDuration(newDuration);
                Navigator.pop(context);
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  void _editCycleDuration(DataManager dataManager) {
    showDialog(
      context: context,
      builder: (context) {
        int newDuration = dataManager.cycleDuration;
        return AlertDialog(
          title: const Text('Chỉnh sửa thời gian chu kỳ'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Thời gian chu kỳ: $newDuration ngày'),
                  Slider(
                    value: newDuration.toDouble(),
                    min: 21,
                    max: 35,
                    divisions: 14,
                    onChanged: (value) {
                      setState(() {
                        newDuration = value.round();
                      });
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                dataManager.updateCycleDuration(newDuration);
                Navigator.pop(context);
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildWeekDays(DataManager dataManager) {
    List<Widget> days = [];
    DateTime today = DateTime.now();

    // Build 7 days starting from today
    for (int i = 0; i < 7; i++) {
      DateTime day = today.add(Duration(days: i));
      bool isToday = i == 0;
      bool isPeriodDay = dataManager.isPeriodDay(day);

      days.add(
        Container(
          width: 40,
          height: 60,
          decoration: BoxDecoration(
            color: isToday ? Colors.white.withOpacity(0.3) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: isPeriodDay
                ? Border.all(color: Colors.white, width: 2)
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'][day.weekday - 1],
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${day.day}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (isPeriodDay)
                Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return days;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataManager>(
      builder: (context, dataManager, child) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  TColor.lightGray,
                  TColor.softPink.withOpacity(0.3),
                  TColor.blushPink.withOpacity(0.2),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Header với các nút tương tác
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => _showSettingsDialog(),
                          icon: Icon(
                            Icons.settings,
                            color: TColor.gray,
                            size: 28,
                          ),
                        ),
                        Text(
                          'Period Tracker',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: TColor.black,
                          ),
                        ),
                        IconButton(
                          onPressed: () => _openCalendar(),
                          icon: Icon(
                            Icons.calendar_today,
                            color: TColor.gray,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Main content với khả năng cuộn
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Column(
                          children: [
                            const SizedBox(height: 10),

                            // NEW CYCLE PREDICTION SECTION
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    TColor.softPink,
                                    TColor.blushPink,
                                    TColor.rosePink,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  children: [
                                    // Header với ngày tháng
                                    Text(
                                      dataManager
                                          .formatFullDate(DateTime.now())
                                          .split('/')
                                          .reversed
                                          .join(' tháng '),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 8),

                                    // Calendar row với 7 ngày
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: _buildWeekDays(dataManager),
                                    ),

                                    const SizedBox(height: 32),

                                    // Main prediction content
                                    Column(
                                      children: [
                                        Text(
                                          'Dự đoán: Ngày',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.white.withOpacity(
                                              0.9,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          dataManager.cyclePhase.isNotEmpty
                                              ? dataManager.cyclePhase
                                              : 'rụng trứng',
                                          style: const TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(
                                              0.2,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Text(
                                            dataManager.getPregnancyChance(),
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 24),

                                        // Action button
                                        GestureDetector(
                                          onTap: () {
                                            if (dataManager.startDate == null) {
                                              _showOnboardingRedirect();
                                            } else if (dataManager
                                                    .currentCycleDay <=
                                                dataManager.periodDuration) {
                                              _showEndCycleDialog(dataManager);
                                            } else {
                                              _showStartCycleDialog(
                                                dataManager,
                                              );
                                            }
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 32,
                                              vertical: 12,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                            ),
                                            child: Text(
                                              dataManager.startDate == null
                                                  ? "Nhập kỳ kinh"
                                                  : dataManager
                                                            .currentCycleDay <=
                                                        dataManager
                                                            .periodDuration
                                                  ? "Kết thúc chu kỳ"
                                                  : "Nhập kỳ kinh",
                                              style: TextStyle(
                                                color: TColor.rosePink,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Today section
                            GestureDetector(
                              onTap: () => _showTodayDetails(dataManager),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      dataManager.startDate != null
                                          ? "Hôm nay - Ngày chu kỳ ${dataManager.currentCycleDay}"
                                          : "Hôm nay - Chưa có dữ liệu chu kỳ",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      dataManager.startDate != null
                                          ? dataManager.getPregnancyChance()
                                          : "Vui lòng thiết lập chu kỳ để xem thông tin",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    const SizedBox(height: 16),

                                    // Progress bar
                                    Container(
                                      width: double.infinity,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: TColor.lightGray,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: dataManager.startDate != null
                                                ? (MediaQuery.of(
                                                            context,
                                                          ).size.width -
                                                          80) *
                                                      dataManager
                                                          .getCycleProgress()
                                                : 0,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: TColor.rosePink,
                                              borderRadius:
                                                  const BorderRadius.only(
                                                    topLeft: Radius.circular(4),
                                                    bottomLeft: Radius.circular(
                                                      4,
                                                    ),
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      dataManager.startDate != null
                                          ? dataManager.formatDate(
                                              dataManager.startDate,
                                            )
                                          : "Chưa thiết lập",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Cycle Timeline
                            GestureDetector(
                              onTap: () => _showCycleDetails(dataManager),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          "Giai đoạn chu kỳ",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          size: 16,
                                          color: Colors.grey[600],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),

                                    Row(
                                      children: [
                                        // Current phase
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: TColor.softPink
                                                  .withOpacity(0.3),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  dataManager.formatDate(
                                                    DateTime.now(),
                                                  ),
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  dataManager.cyclePhase.isEmpty
                                                      ? "Chưa có dữ liệu"
                                                      : dataManager.cyclePhase,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  dataManager.getPhaseIcon(),
                                                  style: const TextStyle(
                                                    fontSize: 20,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),

                                        // Ovulation
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: TColor.blushPink
                                                  .withOpacity(0.3),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  dataManager.ovulationDate !=
                                                          null
                                                      ? dataManager.formatDate(
                                                          dataManager
                                                              .ovulationDate,
                                                        )
                                                      : "N/A",
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                const Text(
                                                  "Rụng trứng",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                const Text(
                                                  "🥚",
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),

                                        // Next period
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: TColor.rosePink
                                                  .withOpacity(0.3),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  dataManager
                                                      .getDaysUntilNextPeriod()
                                                      .toString(),
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                const Text(
                                                  "ngày nữa",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Mood Tracker Section
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        "Tâm trạng hôm nay",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const MoodStatsView(),
                                          ),
                                        ),
                                        child: Text(
                                          "Xem thống kê",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: TColor.rosePink,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  // Mood selection row
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _buildMoodOption(
                                        "😊",
                                        "Vui vẻ",
                                        TColor.softPink,
                                      ),
                                      _buildMoodOption(
                                        "😢",
                                        "Buồn",
                                        TColor.blushPink,
                                      ),
                                      _buildMoodOption(
                                        "😴",
                                        "Mệt mỏi",
                                        TColor.gray,
                                      ),
                                      _buildMoodOption(
                                        "😰",
                                        "Lo lắng",
                                        TColor.coral,
                                      ),
                                      _buildMoodOption(
                                        "😡",
                                        "Tức giận",
                                        TColor.rosePink,
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 16),

                                  // Quick track button
                                  GestureDetector(
                                    onTap: () => _openMoodTracker(
                                      context,
                                      dataManager.currentCycleDay,
                                    ),
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: TColor.rosePink.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(25),
                                        border: Border.all(
                                          color: TColor.rosePink,
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        "Ghi lại chi tiết",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: TColor.rosePink,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Quick Actions Section
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Thao tác nhanh",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  Row(
                                    children: [
                                      // Cycle Stats
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () =>
                                              _showCycleStats(dataManager),
                                          child: Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: TColor.softPink
                                                  .withOpacity(0.3),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Column(
                                              children: [
                                                Icon(
                                                  Icons.analytics,
                                                  size: 24,
                                                  color: TColor.rosePink,
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  "Thống kê",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                    color: TColor.rosePink,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),

                                      // Edit Period Duration
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () =>
                                              _editPeriodDuration(dataManager),
                                          child: Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: TColor.blushPink
                                                  .withOpacity(0.3),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Column(
                                              children: [
                                                Icon(
                                                  Icons.edit,
                                                  size: 24,
                                                  color: TColor.rosePink,
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  "Kỳ kinh",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                    color: TColor.rosePink,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),

                                      // Edit Cycle Duration
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () =>
                                              _editCycleDuration(dataManager),
                                          child: Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: TColor.coral.withOpacity(
                                                0.3,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Column(
                                              children: [
                                                Icon(
                                                  Icons.schedule,
                                                  size: 24,
                                                  color: TColor.rosePink,
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  "Chu kỳ",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                    color: TColor.rosePink,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMoodOption(String emoji, String label, Color color) {
    bool isSelected = selectedMoods.contains(label);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            selectedMoods.remove(label);
          } else {
            selectedMoods.clear(); // Only allow one mood selection
            selectedMoods.add(label);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? Border.all(color: color, width: 2) : null,
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
