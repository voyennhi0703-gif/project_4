import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:period_tracket/views/data/cycle_data.dart';
import 'package:period_tracket/views/data/data_manager.dart';
import 'package:provider/provider.dart';

class AddPreviousCycleView extends StatefulWidget {
  final bool isEditMode;

  const AddPreviousCycleView({super.key, this.isEditMode = false});

  @override
  State<AddPreviousCycleView> createState() => _AddPreviousCycleViewState();
}

class _AddPreviousCycleViewState extends State<AddPreviousCycleView> {
  DateTime _currentMonth = DateTime.now();
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  CycleData? _currentCycle;
  int _periodDays = 5; // Default period length
  List<CycleData> _editableCycles = []; // Danh sách chu kỳ có thể chỉnh sửa
  CycleData? _selectedCycleToEdit; // Chu kỳ đang được chọn để chỉnh sửa

  @override
  void initState() {
    super.initState();
    _loadCurrentCycle();
  }

  void _loadCurrentCycle() {
    final dataManager = context.read<DataManager>();
    if (dataManager.cycleHistory.isNotEmpty) {
      _currentCycle = dataManager.cycleHistory.first;

      // Nếu là chế độ chỉnh sửa, load tất cả các chu kỳ có thể chỉnh sửa
      if (widget.isEditMode) {
        _editableCycles = dataManager.cycleHistory.toList(); // Tất cả chu kỳ
        // Mặc định chọn chu kỳ đầu tiên (chu kỳ hiện tại)
        if (_editableCycles.isNotEmpty) {
          _selectedCycleToEdit = _editableCycles.first;
          _selectedStartDate = _selectedCycleToEdit!.startDate;
          _selectedEndDate = _selectedCycleToEdit!.startDate.add(
            Duration(days: _selectedCycleToEdit!.cycleDays - 1),
          );
          _periodDays = _selectedCycleToEdit!.periodDays;

          // Đặt tháng hiện tại về tháng của chu kỳ đang chỉnh sửa
          _currentMonth = DateTime(
            _selectedCycleToEdit!.startDate.year,
            _selectedCycleToEdit!.startDate.month,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      appBar: AppBar(
        backgroundColor: Colors.pink.shade200,
        elevation: 0,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          widget.isEditMode ? 'Chỉnh sửa chu kỳ' : 'Thêm chu kỳ trước đó',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Header với thông tin tháng
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Colors.pink.shade200, Colors.pink.shade300],
              ),
            ),
            child: Column(
              children: [
                Text(
                  _getMonthYearText(_currentMonth),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.isEditMode
                      ? 'Chỉnh sửa chu kỳ: Tap vào chu kỳ để chọn, sau đó tap vào ngày mới'
                      : 'Chọn ngày bắt đầu và kết thúc kỳ kinh',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                if (widget.isEditMode && _selectedCycleToEdit != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          'Chu kỳ đang chỉnh sửa: ${_selectedCycleToEdit!.cycleDays} ngày (${_formatDate(_selectedCycleToEdit!.startDate)} - ${_formatDate(_selectedCycleToEdit!.startDate.add(Duration(days: _selectedCycleToEdit!.cycleDays - 1)))})',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 8),
                      CupertinoButton(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        onPressed: () {
                          setState(() {
                            _selectedCycleToEdit = null;
                            _selectedStartDate = null;
                            _selectedEndDate = null;
                          });
                        },
                        child: const Text(
                          'Chọn khác',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  widget.isEditMode
                      ? 'Chu kỳ hiện tại: màu xám | Chu kỳ khác: màu sắc khác nhau | Có thể chỉnh sửa thành ngắn hơn hoặc dài hơn'
                      : 'Kỳ kinh hiện tại: màu hồng | Chu kỳ hiện tại: màu xám (không thể chọn)',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          // Navigation buttons
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  onPressed: _previousMonth,
                  child: const Icon(
                    Icons.chevron_left,
                    color: Colors.pink,
                    size: 20,
                  ),
                ),
                CupertinoButton(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  onPressed: _nextMonth,
                  child: const Icon(
                    Icons.chevron_right,
                    color: Colors.pink,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),

          // Calendar hoặc danh sách chu kỳ
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
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
                children: [
                  // Weekday headers
                  _buildWeekdayHeaders(),

                  // Calendar grid
                  Expanded(child: _buildCalendarGrid()),
                ],
              ),
            ),
          ),

          // Period length selector (hiển thị cho cả chế độ thêm và chỉnh sửa)
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(16),
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
                  'Độ dài kỳ kinh',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '$_periodDays ngày',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFF4081),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        CupertinoButton(
                          padding: const EdgeInsets.all(8),
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          onPressed: _periodDays > 1
                              ? _decreasePeriodDays
                              : null,
                          child: const Icon(
                            Icons.remove,
                            color: Colors.grey,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        CupertinoButton(
                          padding: const EdgeInsets.all(8),
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          onPressed: _periodDays < 10
                              ? _increasePeriodDays
                              : null,
                          child: const Icon(
                            Icons.add,
                            color: Colors.grey,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Save button
          Container(
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            width: double.infinity,
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(vertical: 16),
              color: _selectedStartDate != null && _selectedEndDate != null
                  ? (widget.isEditMode
                        ? const Color(0xFF34C759)
                        : const Color(0xFFFF4081))
                  : Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
              onPressed: _selectedStartDate != null && _selectedEndDate != null
                  ? (widget.isEditMode ? _updateCycle : _savePreviousCycle)
                  : null,
              child: Text(
                widget.isEditMode ? 'Cập nhật chu kỳ' : 'Lưu chu kỳ',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeaders() {
    const weekdays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: weekdays.map((day) {
          return Expanded(
            child: Text(
              day,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month,
      1,
    );
    final lastDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month + 1,
      0,
    );
    final firstWeekday = firstDayOfMonth.weekday;
    final daysInMonth = lastDayOfMonth.day;

    // Calculate total cells needed (including empty cells for previous month)
    final totalCells = firstWeekday - 1 + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
      ),
      itemCount: rows * 7,
      itemBuilder: (context, index) {
        final dayIndex = index - (firstWeekday - 1);

        if (dayIndex < 0 || dayIndex >= daysInMonth) {
          return const SizedBox(); // Empty cell
        }

        final day = dayIndex + 1;
        final currentDate = DateTime(
          _currentMonth.year,
          _currentMonth.month,
          day,
        );
        final isSelected = _isDateInSelectedRange(currentDate);
        final isStartDate =
            _selectedStartDate != null &&
            _isSameDay(currentDate, _selectedStartDate!);
        final isEndDate =
            _selectedEndDate != null &&
            _isSameDay(currentDate, _selectedEndDate!);
        final isCurrentCycle = _isDateInCurrentCycle(currentDate);
        final isCurrentPeriod = _isDateInCurrentPeriod(currentDate);
        final isEditingCycle = _isDateInEditingCycle(currentDate);
        final isOtherCycle = _isDateInOtherCycle(currentDate);
        final isAnyCycle = _isDateInAnyCycle(currentDate);
        final cycleForDate = _getCycleForDate(currentDate);

        return GestureDetector(
          onTap: () => _onDateTapped(currentDate, isAnyCycle),
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isCurrentPeriod
                  ? const Color(0xFFFF4081).withOpacity(
                      0.3,
                    ) // Màu hồng cho kỳ kinh hiện tại
                  : isCurrentCycle
                  ? Colors
                        .grey[300] // Màu xám cho phần còn lại của chu kỳ hiện tại
                  : isEditingCycle && widget.isEditMode
                  ? const Color(0xFFFF4081).withOpacity(
                      0.2,
                    ) // Màu hồng nhạt cho chu kỳ đang chỉnh sửa
                  : isOtherCycle
                  ? _getCycleColor(cycleForDate).withOpacity(
                      0.2,
                    ) // Màu sắc khác nhau cho từng chu kỳ
                  : isSelected
                  ? const Color(0xFFFF4081).withOpacity(0.2)
                  : Colors.transparent,
              borderRadius: _getBorderRadius(
                currentDate,
                isCurrentPeriod,
                isCurrentCycle,
                isStartDate,
                isEndDate,
                isEditingCycle,
                isOtherCycle,
              ),
              border: isStartDate || isEndDate
                  ? Border.all(color: const Color(0xFFFF4081), width: 2)
                  : isCurrentPeriod
                  ? Border.all(color: const Color(0xFFFF4081), width: 1)
                  : isCurrentCycle
                  ? Border.all(color: Colors.grey[600]!, width: 1)
                  : isEditingCycle && widget.isEditMode
                  ? Border.all(color: const Color(0xFFFF4081), width: 1)
                  : isOtherCycle
                  ? Border.all(color: _getCycleColor(cycleForDate), width: 1)
                  : null,
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    '$day',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isStartDate || isEndDate
                          ? FontWeight.bold
                          : isCurrentPeriod
                          ? FontWeight.bold
                          : isCurrentCycle
                          ? FontWeight.bold
                          : isEditingCycle && widget.isEditMode
                          ? FontWeight.bold
                          : isOtherCycle
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isStartDate || isEndDate
                          ? const Color(0xFFFF4081)
                          : isCurrentPeriod
                          ? const Color(0xFFFF4081)
                          : isCurrentCycle
                          ? Colors.grey[700]
                          : isEditingCycle && widget.isEditMode
                          ? const Color(0xFFFF4081)
                          : isOtherCycle
                          ? _getCycleColor(cycleForDate)
                          : Colors.black87,
                    ),
                  ),
                ),
                // Thêm icon lock nhỏ cho ngày không thể chọn
                if (isCurrentCycle || isOtherCycle)
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Icon(
                      Icons.lock,
                      size: 8,
                      color: isCurrentCycle
                          ? Colors.grey[600]
                          : _getCycleColor(cycleForDate),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onDateTapped(DateTime date, bool isAnyCycle) {
    if (widget.isEditMode) {
      // Trong chế độ chỉnh sửa
      if (isAnyCycle) {
        // Nếu đã có chu kỳ được chọn để chỉnh sửa, cho phép chọn ngày mới
        if (_selectedCycleToEdit != null) {
          _onDateSelected(date);
        } else {
          // Nếu chưa có chu kỳ nào được chọn, chọn chu kỳ chứa ngày này
          _selectCycleByDate(date);
        }
      } else {
        // Nếu tap vào ngày trống thì chọn ngày để chỉnh sửa chu kỳ đang được chọn
        _onDateSelected(date);
      }
    } else {
      // Trong chế độ thêm chu kỳ, chỉ cho phép chọn ngày trống
      if (!isAnyCycle) {
        _onDateSelected(date);
      }
    }
  }

  void _selectCycleByDate(DateTime date) {
    // Tìm chu kỳ chứa ngày này
    for (final cycle in _editableCycles) {
      final cycleStartDate = cycle.startDate;
      final cycleEndDate = cycleStartDate.add(
        Duration(days: cycle.cycleDays - 1),
      );

      if ((date.isAfter(cycleStartDate) || _isSameDay(date, cycleStartDate)) &&
          (date.isBefore(cycleEndDate) || _isSameDay(date, cycleEndDate))) {
        setState(() {
          _selectedCycleToEdit = cycle;
          _selectedStartDate = cycle.startDate;
          _selectedEndDate = cycle.startDate.add(
            Duration(days: cycle.cycleDays - 1),
          );
          _periodDays = cycle.periodDays;

          // Đặt tháng hiện tại về tháng của chu kỳ đang chỉnh sửa
          _currentMonth = DateTime(cycle.startDate.year, cycle.startDate.month);
        });
        break;
      }
    }
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      if (_selectedStartDate == null) {
        _selectedStartDate = date;
      } else if (_selectedEndDate == null) {
        if (date.isBefore(_selectedStartDate!)) {
          _selectedEndDate = _selectedStartDate;
          _selectedStartDate = date;
        } else {
          _selectedEndDate = date;
        }
      } else {
        _selectedStartDate = date;
        _selectedEndDate = null;
      }
    });
  }

  bool _isDateInSelectedRange(DateTime date) {
    if (_selectedStartDate == null || _selectedEndDate == null) return false;

    return (date.isAfter(_selectedStartDate!) ||
            _isSameDay(date, _selectedStartDate!)) &&
        (date.isBefore(_selectedEndDate!) ||
            _isSameDay(date, _selectedEndDate!));
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  BorderRadius _getBorderRadius(
    DateTime currentDate,
    bool isCurrentPeriod,
    bool isCurrentCycle,
    bool isStartDate,
    bool isEndDate,
    bool isEditingCycle,
    bool isOtherCycle,
  ) {
    // Nếu là ngày được chọn mới (start/end date)
    if (isStartDate || isEndDate) {
      return BorderRadius.circular(20); // Bo tròn hoàn toàn cho ngày được chọn
    }

    // Nếu không có chu kỳ hiện tại
    if (_currentCycle == null) {
      return BorderRadius.circular(8);
    }

    // Kiểm tra vị trí trong chu kỳ
    final isFirstDayOfPeriod =
        isCurrentPeriod && _isFirstDayOfPeriod(currentDate);
    final isLastDayOfPeriod =
        isCurrentPeriod && _isLastDayOfPeriod(currentDate);
    final isFirstDayOfCycle = isCurrentCycle && _isFirstDayOfCycle(currentDate);
    final isLastDayOfCycle = isCurrentCycle && _isLastDayOfCycle(currentDate);

    // Bo tròn cho kỳ kinh (màu hồng)
    if (isCurrentPeriod) {
      if (isFirstDayOfPeriod && isLastDayOfPeriod) {
        // Chỉ có 1 ngày kỳ kinh - bo tròn hoàn toàn
        return BorderRadius.circular(20);
      } else if (isFirstDayOfPeriod) {
        // Ngày đầu kỳ kinh - bo tròn bên trái
        return const BorderRadius.only(
          topLeft: Radius.circular(20),
          bottomLeft: Radius.circular(20),
        );
      } else if (isLastDayOfPeriod) {
        // Ngày cuối kỳ kinh - bo tròn bên phải
        return const BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        );
      } else {
        // Ngày giữa kỳ kinh - bo tròn nhẹ
        return BorderRadius.circular(12);
      }
    }

    // Bo tròn cho phần còn lại của chu kỳ (màu xám)
    if (isCurrentCycle) {
      if (isFirstDayOfCycle && isLastDayOfCycle) {
        // Chỉ có 1 ngày chu kỳ - bo tròn hoàn toàn
        return BorderRadius.circular(20);
      } else if (isFirstDayOfCycle) {
        // Ngày đầu chu kỳ - bo tròn bên trái
        return const BorderRadius.only(
          topLeft: Radius.circular(20),
          bottomLeft: Radius.circular(20),
        );
      } else if (isLastDayOfCycle) {
        // Ngày cuối chu kỳ - bo tròn bên phải
        return const BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        );
      } else {
        // Ngày giữa chu kỳ - bo tròn nhẹ
        return BorderRadius.circular(12);
      }
    }

    // Bo tròn cho chu kỳ đang được chỉnh sửa (màu hồng nhạt)
    if (isEditingCycle && widget.isEditMode) {
      final isFirstDayOfEditingCycle = _isFirstDayOfEditingCycle(currentDate);
      final isLastDayOfEditingCycle = _isLastDayOfEditingCycle(currentDate);

      if (isFirstDayOfEditingCycle && isLastDayOfEditingCycle) {
        // Chỉ có 1 ngày chu kỳ - bo tròn hoàn toàn
        return BorderRadius.circular(20);
      } else if (isFirstDayOfEditingCycle) {
        // Ngày đầu chu kỳ - bo tròn bên trái
        return const BorderRadius.only(
          topLeft: Radius.circular(20),
          bottomLeft: Radius.circular(20),
        );
      } else if (isLastDayOfEditingCycle) {
        // Ngày cuối chu kỳ - bo tròn bên phải
        return const BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        );
      } else {
        // Ngày giữa chu kỳ - bo tròn nhẹ
        return BorderRadius.circular(12);
      }
    }

    // Bo tròn cho chu kỳ khác
    if (isOtherCycle) {
      return BorderRadius.circular(8); // Bo tròn nhẹ cho chu kỳ khác
    }

    // Mặc định cho ngày bình thường
    return BorderRadius.circular(8);
  }

  bool _isDateInCurrentCycle(DateTime date) {
    if (_currentCycle == null) return false;

    final cycleStartDate = _currentCycle!.startDate;
    final cycleEndDate = cycleStartDate.add(
      Duration(days: _currentCycle!.cycleDays - 1),
    );

    return (date.isAfter(cycleStartDate) || _isSameDay(date, cycleStartDate)) &&
        (date.isBefore(cycleEndDate) || _isSameDay(date, cycleEndDate));
  }

  bool _isDateInEditingCycle(DateTime date) {
    if (_selectedCycleToEdit == null) return false;

    final cycleStartDate = _selectedCycleToEdit!.startDate;
    final cycleEndDate = cycleStartDate.add(
      Duration(days: _selectedCycleToEdit!.cycleDays - 1),
    );

    return (date.isAfter(cycleStartDate) || _isSameDay(date, cycleStartDate)) &&
        (date.isBefore(cycleEndDate) || _isSameDay(date, cycleEndDate));
  }

  bool _isDateInOtherCycle(DateTime date) {
    if (_selectedCycleToEdit == null) return false;

    // Kiểm tra xem ngày có nằm trong chu kỳ khác (không phải chu kỳ hiện tại và không phải chu kỳ đang chỉnh sửa)
    for (final cycle in _editableCycles) {
      if (cycle == _selectedCycleToEdit || cycle == _currentCycle) continue;

      final cycleStartDate = cycle.startDate;
      final cycleEndDate = cycleStartDate.add(
        Duration(days: cycle.cycleDays - 1),
      );

      if ((date.isAfter(cycleStartDate) || _isSameDay(date, cycleStartDate)) &&
          (date.isBefore(cycleEndDate) || _isSameDay(date, cycleEndDate))) {
        return true;
      }
    }
    return false;
  }

  bool _isDateInAnyCycle(DateTime date) {
    // Kiểm tra xem ngày có nằm trong bất kỳ chu kỳ nào
    for (final cycle in _editableCycles) {
      final cycleStartDate = cycle.startDate;
      final cycleEndDate = cycleStartDate.add(
        Duration(days: cycle.cycleDays - 1),
      );

      if ((date.isAfter(cycleStartDate) || _isSameDay(date, cycleStartDate)) &&
          (date.isBefore(cycleEndDate) || _isSameDay(date, cycleEndDate))) {
        return true;
      }
    }
    return false;
  }

  CycleData? _getCycleForDate(DateTime date) {
    // Tìm chu kỳ chứa ngày này
    for (final cycle in _editableCycles) {
      final cycleStartDate = cycle.startDate;
      final cycleEndDate = cycleStartDate.add(
        Duration(days: cycle.cycleDays - 1),
      );

      if ((date.isAfter(cycleStartDate) || _isSameDay(date, cycleStartDate)) &&
          (date.isBefore(cycleEndDate) || _isSameDay(date, cycleEndDate))) {
        return cycle;
      }
    }
    return null;
  }

  Color _getCycleColor(CycleData? cycle) {
    if (cycle == null) return Colors.grey;

    // Tạo màu sắc khác nhau cho từng chu kỳ dựa trên vị trí trong danh sách
    final index = _editableCycles.indexOf(cycle);
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
      Colors.brown,
      Colors.cyan,
    ];

    return colors[index % colors.length];
  }

  bool _isDateInCurrentPeriod(DateTime date) {
    if (_currentCycle == null) return false;

    final periodStartDate = _currentCycle!.startDate;
    final periodEndDate = periodStartDate.add(
      Duration(days: _currentCycle!.periodDays - 1),
    );

    return (date.isAfter(periodStartDate) ||
            _isSameDay(date, periodStartDate)) &&
        (date.isBefore(periodEndDate) || _isSameDay(date, periodEndDate));
  }

  bool _isFirstDayOfPeriod(DateTime date) {
    if (_currentCycle == null) return false;
    return _isSameDay(date, _currentCycle!.startDate);
  }

  bool _isLastDayOfPeriod(DateTime date) {
    if (_currentCycle == null) return false;
    final periodEndDate = _currentCycle!.startDate.add(
      Duration(days: _currentCycle!.periodDays - 1),
    );
    return _isSameDay(date, periodEndDate);
  }

  bool _isFirstDayOfCycle(DateTime date) {
    if (_currentCycle == null) return false;
    return _isSameDay(date, _currentCycle!.startDate);
  }

  bool _isLastDayOfCycle(DateTime date) {
    if (_currentCycle == null) return false;
    final cycleEndDate = _currentCycle!.startDate.add(
      Duration(days: _currentCycle!.cycleDays - 1),
    );
    return _isSameDay(date, cycleEndDate);
  }

  bool _isFirstDayOfEditingCycle(DateTime date) {
    if (_selectedCycleToEdit == null) return false;
    return _isSameDay(date, _selectedCycleToEdit!.startDate);
  }

  bool _isLastDayOfEditingCycle(DateTime date) {
    if (_selectedCycleToEdit == null) return false;
    final cycleEndDate = _selectedCycleToEdit!.startDate.add(
      Duration(days: _selectedCycleToEdit!.cycleDays - 1),
    );
    return _isSameDay(date, cycleEndDate);
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  void _increasePeriodDays() {
    setState(() {
      _periodDays++;
    });
  }

  void _decreasePeriodDays() {
    setState(() {
      _periodDays--;
    });
  }

  String _getMonthYearText(DateTime date) {
    const months = [
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
    return '${months[date.month - 1]} ${date.year}';
  }

  String _formatDate(DateTime date) {
    return '${date.day} thg ${date.month}';
  }

  void _updateCycle() {
    if (_selectedCycleToEdit == null ||
        _selectedStartDate == null ||
        _selectedEndDate == null)
      return;

    final dataManager = context.read<DataManager>();
    final cycleDays =
        _selectedEndDate!.difference(_selectedStartDate!).inDays + 1;

    // Create updated cycle data
    final updatedCycle = CycleData(
      startDate: _selectedStartDate!,
      cycleDays: cycleDays,
      periodDays: _periodDays,
    );

    // Update cycle in history
    dataManager.updateCycle(_selectedCycleToEdit!, updatedCycle);

    // Show success message
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Thành công'),
        content: const Text('Đã cập nhật chu kỳ thành công'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close edit cycle page
            },
          ),
        ],
      ),
    );
  }

  void _savePreviousCycle() {
    if (_selectedStartDate == null || _selectedEndDate == null) return;

    final dataManager = context.read<DataManager>();
    final cycleDays =
        _selectedEndDate!.difference(_selectedStartDate!).inDays + 1;

    // Create new cycle data
    final newCycle = CycleData(
      startDate: _selectedStartDate!,
      cycleDays: cycleDays,
      periodDays: _periodDays, // Sử dụng period days được chọn
    );

    // Add to cycle history
    dataManager.addPreviousCycle(newCycle);

    // Show success message
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Thành công'),
        content: const Text('Đã thêm chu kỳ trước đó vào lịch sử'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close add cycle page
            },
          ),
        ],
      ),
    );
  }
}
