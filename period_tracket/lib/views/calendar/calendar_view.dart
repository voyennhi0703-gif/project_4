import 'package:flutter/material.dart';
import 'package:period_tracket/views/data/data_manager.dart';
import 'package:provider/provider.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  DateTime currentDate = DateTime.now();
  DateTime? selectedDate;
  bool showSetup = false;

  // User profile for setup
  Map<String, dynamic> userProfile = {
    'lastPeriodStart': '',
    'cycleLength': 28,
    'periodLength': 5,
    'name': '',
  };

  final List<String> monthNames = [
    'Tháng 1',
    'Tháng 2',
    'Tháng 3',
    'Tháng 4',
    'Tháng 5',
    'Tháng 6',
    'Tháng 7',
    'Tháng 8',
    'Tháng 9',
    'Tháng 10',
    'Tháng 11',
    'Tháng 12',
  ];

  final List<String> dayNames = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];

  // Calculate cycle predictions based on user profile
  Map<String, Map<String, dynamic>> calculateCyclePredictions(
    DataManager dataManager,
  ) {
    if (dataManager.startDate == null) return {};

    DateTime startDate = dataManager.startDate!;
    Map<String, Map<String, dynamic>> predictions = {};

    // Generate predictions for next 12 months
    for (int cycleNum = 0; cycleNum < 12; cycleNum++) {
      DateTime cycleStartDate = startDate.add(
        Duration(days: cycleNum * dataManager.cycleDuration),
      );

      // Period days
      for (int day = 0; day < dataManager.periodDuration; day++) {
        DateTime periodDate = cycleStartDate.add(Duration(days: day));
        String dateKey = formatDateKey(periodDate);

        String flow = day < 2
            ? 'heavy'
            : day < 4
            ? 'medium'
            : 'light';
        String confidence = cycleNum == 0 ? 'confirmed' : 'predicted';

        predictions[dateKey] = {
          'type': cycleNum == 0 ? 'period' : 'predicted-period',
          'flow': flow,
          'confidence': confidence,
        };
      }

      // Ovulation (typically 14 days before next period)
      DateTime ovulationDate = cycleStartDate.add(
        Duration(days: dataManager.cycleDuration - 14),
      );
      String ovulationKey = formatDateKey(ovulationDate);
      predictions[ovulationKey] = {
        'type': cycleNum == 0 ? 'ovulation' : 'predicted-ovulation',
        'confidence': cycleNum == 0 ? 'likely' : 'predicted',
      };

      // Fertile window (5 days before ovulation + ovulation day + 1 day after)
      for (int fertileDay = -5; fertileDay <= 1; fertileDay++) {
        if (fertileDay == 0) continue; // Skip ovulation day itself
        DateTime fertileDate = ovulationDate.add(Duration(days: fertileDay));
        String fertileKey = formatDateKey(fertileDate);
        predictions[fertileKey] = {
          'type': cycleNum == 0 ? 'fertile' : 'predicted-fertile',
          'confidence': cycleNum == 0 ? 'likely' : 'predicted',
        };
      }
    }

    return predictions;
  }

  String formatDateKey(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  // Calculate current cycle statistics
  Map<String, int> getCurrentCycleStats(DataManager dataManager) {
    if (dataManager.startDate == null) {
      return {'currentDay': 0, 'daysToNext': 0, 'daysToOvulation': 0};
    }

    DateTime lastStart = dataManager.startDate!;
    DateTime today = DateTime.now();
    int diffDays = today.difference(lastStart).inDays;
    int currentDay = (diffDays % dataManager.cycleDuration) + 1;

    int daysToNext =
        dataManager.cycleDuration - (diffDays % dataManager.cycleDuration);
    int ovulationDay = dataManager.cycleDuration - 14;
    int daysToOvulation = ovulationDay - (diffDays % dataManager.cycleDuration);

    if (daysToOvulation <= 0) {
      daysToOvulation += dataManager.cycleDuration;
    }

    return {
      'currentDay': currentDay,
      'daysToNext': daysToNext == dataManager.cycleDuration ? 0 : daysToNext,
      'daysToOvulation': daysToOvulation,
    };
  }

  List<DateTime?> getDaysInMonth(DateTime date) {
    int year = date.year;
    int month = date.month;
    DateTime firstDay = DateTime(year, month, 1);
    DateTime lastDay = DateTime(year, month + 1, 0);
    int daysInMonth = lastDay.day;
    int startingDayOfWeek = firstDay.weekday % 7; // Convert to 0=Sunday

    List<DateTime?> days = [];

    for (int i = 0; i < startingDayOfWeek; i++) {
      days.add(null);
    }

    for (int day = 1; day <= daysInMonth; day++) {
      days.add(DateTime(year, month, day));
    }

    return days;
  }

  Color getDayColor(DateTime? date, DataManager dataManager) {
    if (date == null) return Colors.transparent;

    String dateKey = formatDateKey(date);
    Map<String, Map<String, dynamic>> predictions = calculateCyclePredictions(
      dataManager,
    );
    Map<String, dynamic>? data = predictions[dateKey];

    DateTime today = DateTime.now();
    bool isToday =
        date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;

    if (isToday && data == null) {
      return Colors.blue.shade500;
    }

    if (data == null) return Colors.transparent;

    switch (data['type']) {
      case 'period':
        if (data['flow'] == 'heavy') return Colors.red.shade500;
        if (data['flow'] == 'medium') return Colors.red.shade400;
        return Colors.red.shade300;
      case 'predicted-period':
        return Colors.red.shade100;
      case 'ovulation':
        return Colors.purple.shade500;
      case 'predicted-ovulation':
        return Colors.purple.shade100;
      case 'fertile':
        return Colors.green.shade400;
      case 'predicted-fertile':
        return Colors.green.shade100;
      default:
        return Colors.transparent;
    }
  }

  Border? getDayBorder(DateTime? date, DataManager dataManager) {
    if (date == null) return null;

    String dateKey = formatDateKey(date);
    Map<String, Map<String, dynamic>> predictions = calculateCyclePredictions(
      dataManager,
    );
    Map<String, dynamic>? data = predictions[dateKey];

    if (data == null) return null;

    switch (data['type']) {
      case 'predicted-period':
        return Border.all(
          color: Colors.red.shade400,
          width: 2,
          style: BorderStyle.solid,
        );
      case 'predicted-ovulation':
        return Border.all(
          color: Colors.purple.shade400,
          width: 2,
          style: BorderStyle.solid,
        );
      case 'predicted-fertile':
        return Border.all(
          color: Colors.green.shade400,
          width: 2,
          style: BorderStyle.solid,
        );
      default:
        return null;
    }
  }

  Widget? getDayIcon(DateTime? date, DataManager dataManager) {
    if (date == null) return null;

    String dateKey = formatDateKey(date);
    Map<String, Map<String, dynamic>> predictions = calculateCyclePredictions(
      dataManager,
    );
    Map<String, dynamic>? data = predictions[dateKey];

    if (data == null) return null;

    double iconSize = 8;

    switch (data['type']) {
      case 'period':
      case 'predicted-period':
        return Positioned(
          top: 1,
          right: 1,
          child: Icon(
            Icons.water_drop,
            size: iconSize,
            color: Colors.white.withOpacity(0.8),
          ),
        );
      case 'ovulation':
      case 'predicted-ovulation':
        return Positioned(
          top: 1,
          right: 1,
          child: Icon(
            Icons.wb_sunny,
            size: iconSize,
            color: Colors.white.withOpacity(0.8),
          ),
        );
      case 'fertile':
      case 'predicted-fertile':
        return Positioned(
          top: 1,
          right: 1,
          child: Icon(
            Icons.local_florist,
            size: iconSize,
            color: Colors.white.withOpacity(0.8),
          ),
        );
      default:
        return null;
    }
  }

  void navigateMonth(int direction) {
    setState(() {
      currentDate = DateTime(
        currentDate.year,
        currentDate.month + direction,
        1,
      );
    });
  }

  bool isToday(DateTime? day) {
    if (day == null) return false;
    DateTime today = DateTime.now();
    return day.year == today.year &&
        day.month == today.month &&
        day.day == today.day;
  }

  // Setup form validation
  bool isSetupValid() {
    return userProfile['lastPeriodStart'].toString().isNotEmpty &&
        userProfile['cycleLength'] != null &&
        userProfile['periodLength'] != null;
  }

  void handleSetupSubmit(DataManager dataManager) {
    if (isSetupValid()) {
      DateTime startDate = DateTime.parse(userProfile['lastPeriodStart']);
      dataManager.updateStartDate(startDate);
      dataManager.updateCycleDuration(userProfile['cycleLength']);
      dataManager.updatePeriodDuration(userProfile['periodLength']);

      setState(() {
        showSetup = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã cập nhật thông tin chu kỳ!')),
      );
    }
  }

  Widget buildSetupForm(DataManager dataManager) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF0F5), Color(0xFFF8E8FF)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFEC4899), Color(0xFFBE185D)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Chào mừng đến Period',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Để bắt đầu, hãy nhập thông tin chu kỳ của bạn',
                      style: TextStyle(color: Colors.grey.shade600),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Name field
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Tên của bạn',
                        prefixIcon: const Icon(Icons.person),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          userProfile['name'] = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Last period start date
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Ngày bắt đầu kỳ kinh gần nhất',
                        prefixIcon: const Icon(Icons.calendar_today),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      readOnly: true,
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now().subtract(
                            const Duration(days: 365),
                          ),
                          lastDate: DateTime.now(),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            userProfile['lastPeriodStart'] = formatDateKey(
                              pickedDate,
                            );
                          });
                        }
                      },
                      controller: TextEditingController(
                        text:
                            userProfile['lastPeriodStart'].toString().isNotEmpty
                            ? userProfile['lastPeriodStart']
                            : '',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Cycle length
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Độ dài chu kỳ (ngày)',
                        helperText: 'Thông thường từ 21-35 ngày',
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      initialValue: userProfile['cycleLength'].toString(),
                      onChanged: (value) {
                        setState(() {
                          userProfile['cycleLength'] =
                              int.tryParse(value) ?? 28;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Period length
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Số ngày kinh nguyệt (ngày)',
                        helperText: 'Thông thường từ 3-7 ngày',
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      initialValue: userProfile['periodLength'].toString(),
                      onChanged: (value) {
                        setState(() {
                          userProfile['periodLength'] =
                              int.tryParse(value) ?? 5;
                        });
                      },
                    ),
                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isSetupValid()
                            ? () => handleSetupSubmit(dataManager)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink.shade500,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.save),
                            SizedBox(width: 8),
                            Text(
                              'Bắt đầu theo dõi',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildMainCalendar(DataManager dataManager) {
    Map<String, int> stats = getCurrentCycleStats(dataManager);
    List<DateTime?> days = getDaysInMonth(currentDate);

    return Column(
      children: [
        // Header
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Colors.pink.shade200, Colors.pink.shade300],
            ),
            border: Border(bottom: BorderSide(color: Colors.pink.shade300)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFEC4899), Color(0xFFBE185D)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Chào ${userProfile['name'].toString().isNotEmpty ? userProfile['name'] : 'bạn'}!',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.pink.shade700,
                          ),
                        ),
                        Text(
                          'Period Tracker',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.pink.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        showSetup = true;
                      });
                    },
                    icon: Icon(Icons.edit, color: Colors.pink.shade700),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
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
              children: [
                // Calendar Card
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      // Calendar Header
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () => navigateMonth(-1),
                              icon: const Icon(Icons.chevron_left),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.grey.shade100,
                              ),
                            ),
                            Text(
                              '${monthNames[currentDate.month - 1]} ${currentDate.year}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            IconButton(
                              onPressed: () => navigateMonth(1),
                              icon: const Icon(Icons.chevron_right),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.grey.shade100,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Days of Week
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: dayNames
                              .map(
                                (day) => Expanded(
                                  child: Center(
                                    child: Text(
                                      day,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Calendar Grid
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 7,
                                childAspectRatio: 1,
                                crossAxisSpacing: 4,
                                mainAxisSpacing: 4,
                              ),
                          itemCount: days.length,
                          itemBuilder: (context, index) {
                            DateTime? day = days[index];
                            if (day == null) return const SizedBox();

                            Color dayColor = getDayColor(day, dataManager);
                            Border? dayBorder = getDayBorder(day, dataManager);
                            Widget? dayIcon = getDayIcon(day, dataManager);
                            bool isTodayDay = isToday(day);

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedDate = day;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: dayColor,
                                  borderRadius: BorderRadius.circular(20),
                                  border: dayBorder,
                                  boxShadow: dayColor != Colors.transparent
                                      ? [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.1,
                                            ),
                                            blurRadius: 2,
                                            offset: const Offset(0, 1),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Stack(
                                  children: [
                                    Center(
                                      child: Text(
                                        '${day.day}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: dayColor == Colors.transparent
                                              ? Colors.grey.shade800
                                              : Colors.white,
                                        ),
                                      ),
                                    ),
                                    if (isTodayDay &&
                                        dayColor == Colors.transparent)
                                      Positioned(
                                        top: 2,
                                        right: 2,
                                        child: Container(
                                          width: 6,
                                          height: 6,
                                          decoration: const BoxDecoration(
                                            color: Colors.blue,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                    if (dayIcon != null) dayIcon,
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Legend
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Chú thích',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Column(
                        children: [
                          _buildLegendItem(
                            Colors.red.shade500,
                            'Ngày kinh nguyệt',
                            'Đã xác nhận',
                          ),
                          _buildLegendItem(
                            Colors.red.shade100,
                            'Dự đoán kinh nguyệt',
                            'Dự đoán',
                            dashed: true,
                          ),
                          _buildLegendItem(
                            Colors.purple.shade500,
                            'Ngày rụng trứng',
                            'Có khả năng',
                          ),
                          _buildLegendItem(
                            Colors.green.shade400,
                            'Ngày thụ thai cao',
                            'Cửa sổ thụ thai',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Quick Actions
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(
    Color color,
    String label,
    String description, {
    bool dashed = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: dashed ? Colors.transparent : color,
              borderRadius: BorderRadius.circular(12),
              border: dashed
                  ? Border.all(color: color, width: 2, style: BorderStyle.solid)
                  : null,
            ),
            child: dashed
                ? Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataManager>(
      builder: (context, dataManager, child) {
        // Show setup if no start date is set or showSetup is true
        bool isSetupComplete = dataManager.startDate != null;

        if (!isSetupComplete || showSetup) {
          return Scaffold(body: buildSetupForm(dataManager));
        }

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.pink.shade50, Colors.pink.shade100],
              ),
            ),
            child: buildMainCalendar(dataManager),
          ),
        );
      },
    );
  }
}
