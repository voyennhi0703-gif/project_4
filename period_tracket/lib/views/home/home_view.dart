import 'package:flutter/material.dart';
import 'package:period_tracket/views/calendar/calendar_view.dart';
import 'package:period_tracket/views/care/health_care_view.dart';
import 'package:period_tracket/views/data/data_manager.dart';
import 'package:period_tracket/views/home/settings_view.dart';
import 'package:period_tracket/views/mood/daily_mood_tracker.dart';
import 'package:period_tracket/views/mood/mood_stats_view.dart';
import 'package:provider/provider.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => HomeViewState();
}

class HomeViewState extends State<HomeView>
    with SingleTickerProviderStateMixin {
  // State để lưu trữ mood data
  Map<String, dynamic>? savedMoodData;

  // State để theo dõi ngày được chọn
  DateTime? selectedDate;

  late AnimationController _circleController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _circleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 1.06,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.06,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_circleController);

    // Run continuously
    _circleController.repeat();
  }

  @override
  void dispose() {
    _circleController.dispose();
    super.dispose();
  }

  void _openMoodTracker(BuildContext context, int currentCycleDay) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => DailyMoodTracker(
          currentCycleDay: currentCycleDay,
          onMoodSaved: (moodData) {
            setState(() {
              savedMoodData = moodData;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Tâm trạng đã được lưu")),
            );
          },
        ),
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

  void _showTodayDetails(DataManager dataManager) {
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

  Widget _buildDateItem(
    String date,
    bool isToday,
    bool isPredicted,
    DateTime day,
    DataManager dataManager,
  ) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDate = day;
        });
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isToday ? Colors.pink.shade400 : Colors.transparent,
          shape: BoxShape.circle,
          border: isPredicted
              ? Border.all(
                  color: Colors.pink.shade400,
                  width: 2,
                  style: BorderStyle.solid,
                )
              : null,
        ),
        child: Center(
          child: Text(
            date,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isToday ? Colors.white : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildWeekDayLabels() {
    DateTime today = DateTime.now();
    List<Widget> labels = [];

    // Thứ tự cố định từ Chủ nhật đến Thứ 7: S, M, T, W, T, F, S
    List<String> weekDays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    for (int i = 0; i < 7; i++) {
      // weekday: 1=Monday, 2=Tuesday, ..., 7=Sunday
      // Nhưng array của chúng ta: 0=Sunday, 1=Monday, ..., 6=Saturday
      // Vậy cần chuyển đổi: Sunday=0, Monday=1, Tuesday=2, Wednesday=3, Thursday=4, Friday=5, Saturday=6
      int todayWeekdayIndex = today.weekday == 7
          ? 0
          : today.weekday; // Chuyển Sunday từ 7 thành 0

      // Kiểm tra xem vị trí này có phải là thứ của hôm nay không
      bool isToday = i == todayWeekdayIndex;

      // Hiển thị cố định theo thứ tự từ Chủ nhật đến Thứ 7
      String dayName = weekDays[i];

      labels.add(
        Container(
          width: isToday ? 50 : 40,
          child: Text(
            isToday ? 'TODAY' : dayName,
            style: TextStyle(
              fontSize: isToday ? 10 : 12,
              color: Colors.grey[600],
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.visible,
          ),
        ),
      );
    }

    return labels;
  }

  List<Widget> _buildDynamicDates(DataManager dataManager) {
    DateTime today = DateTime.now();
    List<Widget> dates = [];

    // Tính toán ngày bắt đầu của tuần (Chủ nhật)
    // weekday: 1=Monday, 2=Tuesday, ..., 7=Sunday
    // Chúng ta muốn bắt đầu từ Chủ nhật (Sunday = 7)
    int daysFromSunday = today.weekday == 7 ? 0 : today.weekday;
    DateTime weekStart = today.subtract(Duration(days: daysFromSunday));

    for (int i = 0; i < 7; i++) {
      DateTime day = weekStart.add(Duration(days: i));

      // Kiểm tra xem ngày này có phải là hôm nay không
      bool isToday =
          day.day == today.day &&
          day.month == today.month &&
          day.year == today.year;

      bool isPeriodDay = dataManager.isPeriodDay(day);
      bool isPredicted = !isToday && isPeriodDay;

      dates.add(
        _buildDateItem('${day.day}', isToday, isPredicted, day, dataManager),
      );
    }

    return dates;
  }

  Widget _buildConnectionLine(int selectedIndex) {
    if (selectedDate == null) return const SizedBox.shrink();

    return Positioned(
      top: 80, // Vị trí từ trên xuống
      left: 20 + (selectedIndex * 50) + 20, // Tính toán vị trí ngang
      child: Container(
        width: 2,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }

  int _getSelectedDateIndex() {
    if (selectedDate == null) return 0;

    DateTime today = DateTime.now();
    int daysFromSunday = today.weekday == 7 ? 0 : today.weekday;
    DateTime weekStart = today.subtract(Duration(days: daysFromSunday));

    return selectedDate!.difference(weekStart).inDays;
  }

  Map<String, String> _getPredictionInfo(
    DateTime date,
    DataManager dataManager,
  ) {
    if (dataManager.startDate == null) {
      return {
        'phase': 'Period:',
        'day': 'Day 1',
        'info': 'Set up your cycle to get predictions',
      };
    }

    // Tính ngày trong chu kỳ
    int daysSinceStart = date.difference(dataManager.startDate!).inDays;
    int cycleDay = (daysSinceStart % dataManager.cycleDuration) + 1;

    // Xác định giai đoạn
    String phase;
    String info;

    if (cycleDay <= dataManager.periodDuration) {
      phase = 'Period:';
      info = 'Menstrual phase';
    } else if (cycleDay <= dataManager.periodDuration + 5) {
      phase = 'Follicular:';
      info = 'Preparing for ovulation';
    } else if (cycleDay <= dataManager.periodDuration + 10) {
      phase = 'Ovulation:';
      info = 'High chance of getting pregnant';
    } else {
      phase = 'Luteal:';
      info = 'Post-ovulation phase';
    }

    return {'phase': phase, 'day': 'Day $cycleDay', 'info': info};
  }

  List<Widget> _buildWeekDays(DataManager dataManager) {
    List<Widget> days = [];
    DateTime today = DateTime.now();

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

  // Method để tạo mood chips với icon
  List<Widget> _buildMoodChips(List<dynamic> items, String category) {
    List<Widget> chips = [];

    // Thêm category label
    chips.add(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: _getCategoryColor(category).withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _getCategoryColor(category)),
        ),
        child: Text(
          category,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: _getCategoryColor(category),
          ),
        ),
      ),
    );

    // Thêm các items với icon
    for (String item in items) {
      chips.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: _getCategoryColor(category).withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _getCategoryColor(category).withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_getItemIcon(item), style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text(
                item,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _getCategoryColor(category),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return chips;
  }

  // Method để lấy icon cho từng item
  String _getItemIcon(String item) {
    Map<String, String> iconMap = {
      // Tâm trạng
      'Bình tĩnh': '😊',
      'Vui vẻ': '😄',
      'Mạnh mẽ': '⚡',
      'Phấn chấn': '😁',
      'Thất thường': '😔',
      'Bực bội': '😠',
      'Buồn': '😞',
      'Lo lắng': '😟',
      'Trầm cảm': '😩',
      'Cảm thấy có lỗi': '😥',
      'Suy nghĩ ám ảnh': '☁️',
      'Thiếu năng lượng': '😴',
      'Lãnh đạm': '😐',
      'Bối rối': '😕',
      'Rất hay tự trách mình': '😡',

      // Triệu chứng
      'Mọi thứ đều ổn': '👍',
      'Chuột rút': '🤰',
      'Sưng đau ngực': '👙',
      'Đau đầu': '🤕',
      'Mụn': '😷',
      'Đau lưng': '🦴',
      'Mệt mỏi': '🔋',
      'Thèm ăn': '🍔',
      'Mất ngủ': '🌙',
      'Đau bụng': '🤰',
      'Ngứa âm đạo': '🌸',
      'Khô âm đạo': '💧',

      // Tiết dịch
      'Không có dịch': '❌',
      'Trắng đục': '💧',
      'Ẩm ướt': '💧',
      'Dạng dính': '💧',
      'Như lòng trắng trứng': '🥚',
      'Dạng đốm': '🩸',
      'Bất thường': '⚠️',
      'Trắng, vón cục': '🔘',
      'Xám': '🔘',

      // Hoạt động thể chất
      'Không tập': '❌',
      'Yoga': '🧘',
      'Gym': '🏋️',
      'Aerobic & nhảy múa': '💃',
      'Bơi lội': '🏊',
      'Thể thao đồng đội': '🏀',
      'Chạy': '🏃',
      'Đạp xe đạp': '🚴',
      'Đi bộ': '🚶',

      // Hoạt động tình dục
      'Không quan hệ tình dục': '❤️',
      'Quan hệ tình dục có bảo vệ': '🔒',
      'Quan hệ tình dục không bảo vệ': '🔓',

      // Thử rụng trứng
      'Đã không thử': '↔️',
      'Kết quả: có thai': '↔️',
      'Kết quả: không có thai': '↔️',
      'Rụng trứng: tự tính toán': '↔️',

      // Tiêu hóa
      'Buồn nôn': '🤢',
      'Đầy hơi': '🎈',
      'Táo bón': '🔒',
      'Tiêu chảy': '🧻',

      // Thử thai
      'Có thai': '↔️',
      'Không có thai': '↔️',
      'Không chắc': '❓',

      // Khác
      'Đi lại': '📍',
      'Căng thẳng': '⚡',
      'Thiền': '🪷',
      'Viết nhật ký': '📖',
      'Bài tập Kegel': '🦴',
      'Bài tập thở': '🫁',
      'Bị bệnh hay bị thương': '🩹',
      'Rượu': '🍷',
    };

    return iconMap[item] ?? '📝';
  }

  // Method để lấy màu cho từng category
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Tâm trạng':
        return Colors.orange;
      case 'Triệu chứng':
        return Colors.pink;
      case 'Tiết dịch':
        return Colors.purple;
      case 'Hoạt động':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

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
                // Header với các nút tương tác
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () => _showSettingsDialog(),
                            icon: Icon(
                              Icons.settings,
                              color: Colors.pink.shade600,
                              size: 28,
                            ),
                          ),
                          Text(
                            'Period Tracker',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.pink.shade700,
                            ),
                          ),
                          IconButton(
                            onPressed: () => _openCalendar(),
                            icon: Icon(
                              Icons.calendar_today,
                              color: Colors.pink.shade600,
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Main content với khả năng cuộn
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),

                        // NEW CYCLE PREDICTION SECTION
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.pink.shade50,
                                Colors.pink.shade100,
                              ],
                            ),
                          ),
                          child: Column(
                            children: [
                              // Calendar section với padding
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  20,
                                  20,
                                  20,
                                  0,
                                ),
                                child: Stack(
                                  children: [
                                    Column(
                                      children: [
                                        // Days of week row
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: _buildWeekDayLabels(),
                                        ),
                                        const SizedBox(height: 8),
                                        // Dates row
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: _buildDynamicDates(
                                            dataManager,
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Đường nối màu trắng
                                    if (selectedDate != null)
                                      _buildConnectionLine(
                                        _getSelectedDateIndex(),
                                      ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 40),

                              // Large circle section with animation
                              ScaleTransition(
                                scale: _scaleAnim,
                                child: Container(
                                  width: 320,
                                  height: 320,
                                  decoration: BoxDecoration(
                                    color: Colors.pink.shade200,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.pink.withOpacity(0.3),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        selectedDate != null
                                            ? _getPredictionInfo(
                                                selectedDate!,
                                                dataManager,
                                              )['phase']!
                                            : (dataManager.cyclePhase.isNotEmpty
                                                  ? dataManager.cyclePhase
                                                  : 'Period:'),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        selectedDate != null
                                            ? _getPredictionInfo(
                                                selectedDate!,
                                                dataManager,
                                              )['day']!
                                            : (dataManager.startDate != null
                                                  ? 'Day ${dataManager.currentCycleDay}'
                                                  : 'Day 1'),
                                        style: const TextStyle(
                                          fontSize: 48,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        selectedDate != null
                                            ? _getPredictionInfo(
                                                selectedDate!,
                                                dataManager,
                                              )['info']!
                                            : dataManager.getPregnancyChance(),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.grey[600],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 30),
                                      GestureDetector(
                                        onTap: () {
                                          if (dataManager.startDate == null) {
                                            _showOnboardingRedirect();
                                          } else if (dataManager
                                                  .currentCycleDay <=
                                              dataManager.periodDuration) {
                                            _showEndCycleDialog(dataManager);
                                          } else {
                                            _showStartCycleDialog(dataManager);
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.pink.shade100,
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Text(
                                            "Edit period dates",
                                            style: TextStyle(
                                              color: Colors.pink.shade700,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 40),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),
                        // Health Care Section
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: const HealthCareView(),
                        ),
                        const SizedBox(height: 24),
                        // Mood Tracker Section
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                                          color: Colors.blue[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // Mood preview section
                                if (savedMoodData != null) ...[
                                  // Saved mood display
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey[200]!,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.check_circle,
                                              color: Colors.green[600],
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            const Text(
                                              "Tâm trạng đã ghi hôm nay",
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.green,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),

                                        // Horizontal scrollable mood items
                                        SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Row(
                                            children: [
                                              if (savedMoodData!['moods'] !=
                                                      null &&
                                                  (savedMoodData!['moods']
                                                          as List)
                                                      .isNotEmpty)
                                                ..._buildMoodChips(
                                                  savedMoodData!['moods'],
                                                  'Tâm trạng',
                                                ),
                                              if (savedMoodData!['symptoms'] !=
                                                      null &&
                                                  (savedMoodData!['symptoms']
                                                          as List)
                                                      .isNotEmpty)
                                                ..._buildMoodChips(
                                                  savedMoodData!['symptoms'],
                                                  'Triệu chứng',
                                                ),
                                              if (savedMoodData!['discharge'] !=
                                                      null &&
                                                  (savedMoodData!['discharge']
                                                          as List)
                                                      .isNotEmpty)
                                                ..._buildMoodChips(
                                                  savedMoodData!['discharge'],
                                                  'Tiết dịch',
                                                ),
                                              if (savedMoodData!['physicalActivity'] !=
                                                      null &&
                                                  (savedMoodData!['physicalActivity']
                                                          as List)
                                                      .isNotEmpty)
                                                ..._buildMoodChips(
                                                  savedMoodData!['physicalActivity'],
                                                  'Hoạt động',
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ] else ...[
                                  // Empty state
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey[200]!,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.mood,
                                          color: Colors.grey[600],
                                          size: 24,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                "Ghi lại tâm trạng và triệu chứng",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                "Nhấn để mở chi tiết",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          color: Colors.grey[400],
                                          size: 16,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],

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
                                      vertical: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          const Color(0xFF26C6DA),
                                          const Color(
                                            0xFF26C6DA,
                                          ).withOpacity(0.8),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(25),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(
                                            0xFF26C6DA,
                                          ).withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          "Ghi lại chi tiết",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
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
}
