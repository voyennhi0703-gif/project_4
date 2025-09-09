import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:period_tracket/common/colo_extension.dart';

class StartDatePage extends StatefulWidget {
  final Map<String, dynamic> formData;
  final Function(String) onSave;

  const StartDatePage({Key? key, required this.formData, required this.onSave})
    : super(key: key);

  @override
  State<StartDatePage> createState() => _StartDatePageState();
}

class _StartDatePageState extends State<StartDatePage> {
  DateTime selectedDate = DateTime.now();

  // Controllers for scroll wheels
  late FixedExtentScrollController dayController;
  late FixedExtentScrollController monthController;
  late FixedExtentScrollController yearController;

  // Current values
  int selectedDay = DateTime.now().day;
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  // Date ranges
  final int startYear = 2020;
  final int endYear = 2030;

  // Month names in Vietnamese
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

  @override
  void initState() {
    super.initState();

    // Parse existing date if available
    if (widget.formData['startDate'] != null) {
      selectedDate = DateTime.parse(widget.formData['startDate']);
      selectedDay = selectedDate.day;
      selectedMonth = selectedDate.month;
      selectedYear = selectedDate.year;
    }

    // Initialize controllers
    dayController = FixedExtentScrollController(initialItem: selectedDay - 1);
    monthController = FixedExtentScrollController(
      initialItem: selectedMonth - 1,
    );
    yearController = FixedExtentScrollController(
      initialItem: selectedYear - startYear,
    );
  }

  @override
  void dispose() {
    dayController.dispose();
    monthController.dispose();
    yearController.dispose();
    super.dispose();
  }

  // Get number of days in the selected month/year
  int getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  void updateSelectedDate() {
    // Ensure day is valid for the selected month/year
    int maxDays = getDaysInMonth(selectedYear, selectedMonth);
    if (selectedDay > maxDays) {
      selectedDay = maxDays;
      dayController.animateToItem(
        selectedDay - 1,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    }

    selectedDate = DateTime(selectedYear, selectedMonth, selectedDay);
  }

  void handleSave() {
    String formattedDate =
        '${selectedYear.toString().padLeft(4, '0')}-${selectedMonth.toString().padLeft(2, '0')}-${selectedDay.toString().padLeft(2, '0')}';
    widget.onSave(formattedDate);
    Navigator.of(context).pop();
  }

  void handleCancel() {
    Navigator.of(context).pop();
  }

  String _getDayOfWeek(DateTime date) {
    const days = [
      'Chủ Nhật',
      'Thứ Hai',
      'Thứ Ba',
      'Thứ Tư',
      'Thứ Năm',
      'Thứ Sáu',
      'Thứ Bảy',
    ];
    return days[date.weekday % 7];
  }

  Widget buildScrollPicker({
    required String title,
    required int itemCount,
    required FixedExtentScrollController controller,
    required String Function(int) itemBuilder,
    required Function(int) onSelectedItemChanged,
  }) {
    return Expanded(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: TColor.gray,
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: TColor.lightGray,
                borderRadius: BorderRadius.circular(12),
              ),
              child: CupertinoPicker(
                scrollController: controller,
                itemExtent: 50,
                onSelectedItemChanged: onSelectedItemChanged,
                selectionOverlay: Container(
                  decoration: BoxDecoration(
                    // Làm trong suốt hoàn toàn
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    // Chỉ giữ lại border để người dùng vẫn thấy vùng được chọn
                    border: Border.all(
                      color: TColor.primaryColor1.withOpacity(0.6),
                      width: 2,
                    ),
                  ),
                ),
                children: List.generate(
                  itemCount,
                  (index) => Center(
                    child: Text(
                      itemBuilder(index),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: TColor.black,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // iOS-style header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Empty space for balance
                  const SizedBox(width: 60),
                  // Title
                  Text(
                    'Ngày bắt đầu',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  // Add button
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: handleSave,
                    child: Text(
                      'Add',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF007AFF),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Main content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Title
                    Text(
                      'Ngày bắt đầu chu kỳ kinh gần nhất?',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Lướt để chọn ngày bắt đầu kỳ kinh gần nhất của bạn',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 40),

                    // iOS-style wheel date picker
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Month picker
                            Expanded(
                              child: CupertinoPicker(
                                scrollController: monthController,
                                itemExtent: 40,
                                onSelectedItemChanged: (index) {
                                  setState(() {
                                    selectedMonth = index + 1;
                                    updateSelectedDate();
                                  });
                                },
                                selectionOverlay: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF007AFF,
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(
                                        0xFF007AFF,
                                      ).withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                ),
                                children: monthNames
                                    .map(
                                      (month) => Center(
                                        child: Text(
                                          month,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),

                            // Day picker
                            Expanded(
                              child: CupertinoPicker(
                                scrollController: dayController,
                                itemExtent: 40,
                                onSelectedItemChanged: (index) {
                                  setState(() {
                                    selectedDay = index + 1;
                                    updateSelectedDate();
                                  });
                                },
                                selectionOverlay: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF007AFF,
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(
                                        0xFF007AFF,
                                      ).withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                ),
                                children: List.generate(
                                  getDaysInMonth(selectedYear, selectedMonth),
                                  (index) => Center(
                                    child: Text(
                                      (index + 1).toString(),
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Year picker
                            Expanded(
                              child: CupertinoPicker(
                                scrollController: yearController,
                                itemExtent: 40,
                                onSelectedItemChanged: (index) {
                                  setState(() {
                                    selectedYear = startYear + index;
                                    updateSelectedDate();
                                  });
                                },
                                selectionOverlay: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF007AFF,
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(
                                        0xFF007AFF,
                                      ).withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                ),
                                children: List.generate(
                                  endYear - startYear + 1,
                                  (index) => Center(
                                    child: Text(
                                      (startYear + index).toString(),
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Selected date display
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '${monthNames[selectedMonth - 1]}, ${selectedDay} ${selectedYear}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getDayOfWeek(selectedDate),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
