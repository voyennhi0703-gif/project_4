import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:period_tracket/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:period_tracket/views/data/cycle_data.dart';

enum ReminderType { smart, period, ovulation, pill }

class ReminderSettings {
  bool smartEnabled;
  TimeOfDay smartTime;
  bool periodEnabled;
  TimeOfDay periodTime;
  bool ovulationEnabled;
  TimeOfDay ovulationTime;
  bool pillEnabled;
  TimeOfDay pillTime;

  ReminderSettings({
    this.smartEnabled = false,
    this.smartTime = const TimeOfDay(hour: 9, minute: 0),
    this.periodEnabled = false,
    this.periodTime = const TimeOfDay(hour: 9, minute: 0),
    this.ovulationEnabled = false,
    this.ovulationTime = const TimeOfDay(hour: 9, minute: 0),
    this.pillEnabled = false,
    this.pillTime = const TimeOfDay(hour: 21, minute: 0),
  });

  Map<String, dynamic> toJson() {
    return {
      'smartEnabled': smartEnabled,
      'smartTime': '${smartTime.hour}:${smartTime.minute}',
      'periodEnabled': periodEnabled,
      'periodTime': '${periodTime.hour}:${periodTime.minute}',
      'ovulationEnabled': ovulationEnabled,
      'ovulationTime': '${ovulationTime.hour}:${ovulationTime.minute}',
      'pillEnabled': pillEnabled,
      'pillTime': '${pillTime.hour}:${pillTime.minute}',
    };
  }

  factory ReminderSettings.fromJson(Map<String, dynamic> json) {
    TimeOfDay parseTime(String timeStr) {
      final parts = timeStr.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }

    return ReminderSettings(
      smartEnabled: json['smartEnabled'] ?? false,
      smartTime: json['smartTime'] != null
          ? parseTime(json['smartTime'])
          : const TimeOfDay(hour: 9, minute: 0),
      periodEnabled: json['periodEnabled'] ?? false,
      periodTime: json['periodTime'] != null
          ? parseTime(json['periodTime'])
          : const TimeOfDay(hour: 9, minute: 0),
      ovulationEnabled: json['ovulationEnabled'] ?? false,
      ovulationTime: json['ovulationTime'] != null
          ? parseTime(json['ovulationTime'])
          : const TimeOfDay(hour: 9, minute: 0),
      pillEnabled: json['pillEnabled'] ?? false,
      pillTime: json['pillTime'] != null
          ? parseTime(json['pillTime'])
          : const TimeOfDay(hour: 21, minute: 0),
    );
  }
}

class DataManager extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  // Core
  DateTime? _startDate;
  int _cycleDuration = 28;
  int _periodDuration = 5;

  // Computed
  DateTime? _nextPeriodDate;
  DateTime? _ovulationDate;
  List<DateTime> _fertileWindow = [];
  int _currentCycleDay = 1;
  String _cyclePhase = '';

  // History
  final List<CycleData> _cycleHistory = [];
  List<CycleData> get cycleHistory => _cycleHistory;

  ReminderSettings _reminders = ReminderSettings();
  ReminderSettings get reminders => _reminders;

  // Getters
  DateTime? get startDate => _startDate;
  int get cycleDuration => _cycleDuration;
  int get periodDuration => _periodDuration;
  DateTime? get nextPeriodDate => _nextPeriodDate;
  DateTime? get ovulationDate => _ovulationDate;
  List<DateTime> get fertileWindow => _fertileWindow;
  int get currentCycleDay => _currentCycleDay;
  String get cyclePhase => _cyclePhase;

  // Constructor: load persisted data
  DataManager() {
    _loadData();
  }

  // ----- Public API used by UI -----

  void initializeFromOnboarding(Map<String, dynamic> userData) {
    if (userData['startDate'] != null) {
      _startDate = DateTime.parse(userData['startDate']);
    }
    _cycleDuration = userData['cycleDuration'] ?? 28;
    _periodDuration = userData['periodDuration'] ?? 5;
    _recompute();

    if (_startDate != null) {
      // đảm bảo có item hiện tại ở đầu danh sách
      if (_cycleHistory.isEmpty ||
          !_isSameDay(_cycleHistory.first.startDate, _startDate!)) {
        _cycleHistory.insert(
          0,
          CycleData(
            startDate: _startDate!,
            periodDays: _periodDuration,
            cycleDays: _cycleDuration,
          ),
        );
      }
    }
    _saveData();
    notifyListeners();
  }

  void updateStartDate(DateTime newStartDate) {
    // Nếu có start cũ và newStartDate nằm sau → coi như đóng chu kỳ cũ, thêm vào history (đã có)
    if (_startDate != null && newStartDate.isAfter(_startDate!)) {
      _addCycleToHistory(_startDate!, _periodDuration, _cycleDuration);
    }
    _startDate = newStartDate;
    _recompute();
    _saveData();
    notifyListeners();
  }

  void updateCycleDuration(int newDuration) {
    _cycleDuration = newDuration;
    _recompute();
    _saveData();
    notifyListeners();
  }

  void updatePeriodDuration(int newDuration) {
    _periodDuration = newDuration;
    _recompute();
    _saveData();
    notifyListeners();
  }

  void addOldCycle(DateTime startDate, int periodDays, int cycleDays) {
    final c = CycleData(
      startDate: startDate,
      periodDays: periodDays,
      cycleDays: cycleDays,
    );
    _cycleHistory.add(c);
    _cycleHistory.sort((a, b) => b.startDate.compareTo(a.startDate));
    _saveData();
    notifyListeners();
  }

  void addCycleHistory(CycleData c) {
    _cycleHistory.add(c);
    _cycleHistory.sort((a, b) => b.startDate.compareTo(a.startDate));
    _saveData();
    notifyListeners();
  }

  void removeCycleFromHistory(CycleData c) {
    _cycleHistory.remove(c);
    _saveData();
    notifyListeners();
  }

  void _saveReminderSettings() {
    // TODO: Implement SharedPreferences để lưu cài đặt
    // Ví dụ:
    // final prefs = await SharedPreferences.getInstance();
    // prefs.setBool('smart_enabled', _reminders.smartEnabled);
    // prefs.setInt('smart_hour', _reminders.smartTime?.hour ?? 0);
    // ...
  }

  // Tải cài đặt
  void _loadReminderSettings() {
    // TODO: Load từ SharedPreferences
    // Ví dụ:
    // final prefs = await SharedPreferences.getInstance();
    // _reminders.smartEnabled = prefs.getBool('smart_enabled') ?? false;
    // final smartHour = prefs.getInt('smart_hour') ?? 9;
    // ...
  }

  // Helpers used by multiple screens
  String getPhaseIcon() {
    switch (_cyclePhase) {
      case 'Kinh nguyệt':
        return '💧';
      case 'Rụng trứng':
        return '🥚';
      case 'Dễ thụ thai':
        return '🌱';
      default:
        return '🌙';
    }
  }

  String getPregnancyChance() {
    if (_currentCycleDay <= _periodDuration) {
      return 'Thấp - Khả năng thụ thai';
    } else if (_cyclePhase == 'Dễ thụ thai' || _cyclePhase == 'Rụng trứng') {
      return 'Cao - Khả năng thụ thai';
    } else {
      return 'Trung bình - Khả năng thụ thai';
    }
  }

  int getDaysUntilNextPeriod() {
    if (_nextPeriodDate == null) return 0;
    final days = _nextPeriodDate!.difference(DateTime.now()).inDays;
    return days < 0 ? 0 : days;
  }

  double getCycleProgress() => _currentCycleDay / _cycleDuration;

  bool isPeriodDay(DateTime date) {
    if (_startDate == null) return false;
    final daysSinceStart = date.difference(_startDate!).inDays;
    if (daysSinceStart < 0) return false;
    final cycleDay = (daysSinceStart % _cycleDuration) + 1;
    return cycleDay <= _periodDuration;
  }

  String formatDate(DateTime? date) =>
      date == null ? 'N/A' : '${date.day} thg ${date.month}';

  String formatFullDate(DateTime? date) =>
      date == null ? 'N/A' : '${date.day}/${date.month}/${date.year}';

  String getVietnameseMonth(int month) {
    const names = [
      '',
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
    return (month >= 1 && month <= 12) ? names[month] : '';
  }

  // ----- Internal -----

  void _recompute() {
    if (_startDate == null) return;

    final now = DateTime.now();
    final diff = now.difference(_startDate!).inDays;

    // currentCycleDay
    if (diff < 0) {
      _currentCycleDay = 1;
    } else {
      _currentCycleDay = (diff % _cycleDuration) + 1;
    }

    // nextPeriodDate
    if (diff < 0) {
      _nextPeriodDate = _startDate;
    } else {
      final cyclesCompleted = diff ~/ _cycleDuration;
      _nextPeriodDate = _startDate!.add(
        Duration(days: (cyclesCompleted + 1) * _cycleDuration),
      );
    }

    // ovulation & fertile window
    _ovulationDate = _nextPeriodDate!.subtract(const Duration(days: 14));
    _fertileWindow = [
      for (int i = -5; i <= 1; i++) _ovulationDate!.add(Duration(days: i)),
    ];

    // phase
    _determineCyclePhase();
    // đảm bảo item hiện tại ở đầu history
    if (_startDate != null) {
      if (_cycleHistory.isEmpty ||
          !_isSameDay(_cycleHistory.first.startDate, _startDate!)) {
        _cycleHistory.insert(
          0,
          CycleData(
            startDate: _startDate!,
            periodDays: _periodDuration,
            cycleDays: _cycleDuration,
          ),
        );
      } else {
        // cập nhật lại chu kỳ hiện tại (nếu thông số thay đổi)
        _cycleHistory[0] = CycleData(
          startDate: _startDate!,
          periodDays: _periodDuration,
          cycleDays: _cycleDuration,
        );
      }
    }
  }

  void _determineCyclePhase() {
    if (_currentCycleDay <= _periodDuration) {
      _cyclePhase = 'Kinh nguyệt';
      return;
    }
    final ovulationDay = _cycleDuration - 14;
    if (_currentCycleDay >= ovulationDay - 5 &&
        _currentCycleDay <= ovulationDay + 1) {
      _cyclePhase = (_currentCycleDay == ovulationDay)
          ? 'Rụng trứng'
          : 'Dễ thụ thai';
    } else if (_currentCycleDay > _periodDuration &&
        _currentCycleDay < ovulationDay - 5) {
      _cyclePhase = 'Giai đoạn nang';
    } else {
      _cyclePhase = 'Giai đoạn hoàng thể';
    }
  }

  void _addCycleToHistory(DateTime start, int periodDays, int cycleDays) {
    _cycleHistory.insert(
      0,
      CycleData(startDate: start, periodDays: periodDays, cycleDays: cycleDays),
    );
    _cycleHistory.sort((a, b) => b.startDate.compareTo(a.startDate));
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  // ----- Persistence -----

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    final startDateString = prefs.getString('startDate');
    if (startDateString != null && startDateString.isNotEmpty) {
      _startDate = DateTime.parse(startDateString);
    }
    _periodDuration = prefs.getInt('periodDuration') ?? _periodDuration;
    _cycleDuration = prefs.getInt('cycleDuration') ?? _cycleDuration;

    final cycleHistoryString = prefs.getString('cycleHistory');
    if (cycleHistoryString != null && cycleHistoryString.isNotEmpty) {
      final List<dynamic> arr = jsonDecode(cycleHistoryString);
      _cycleHistory
        ..clear()
        ..addAll(arr.map((e) => CycleData.fromJson(e)));
      _cycleHistory.sort((a, b) => b.startDate.compareTo(a.startDate));
    }

    final remindersString = prefs.getString('reminders');
    if (remindersString != null && remindersString.isNotEmpty) {
      _reminders = ReminderSettings.fromJson(jsonDecode(remindersString));
    }

    if (_startDate != null) {
      _recompute();
    }
    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    if (_startDate != null) {
      await prefs.setString('startDate', _startDate!.toIso8601String());
    } else {
      await prefs.remove('startDate');
    }
    await prefs.setInt('periodDuration', _periodDuration);
    await prefs.setInt('cycleDuration', _cycleDuration);

    final jsonList = _cycleHistory.map((c) => c.toJson()).toList();
    await prefs.setString('cycleHistory', jsonEncode(jsonList));

    await prefs.setString('reminders', jsonEncode(_reminders.toJson()));
  }

  Future<void> setReminderEnabled(ReminderType type, bool enabled) async {
    switch (type) {
      case ReminderType.smart:
        _reminders.smartEnabled = enabled;
        break;
      case ReminderType.period:
        _reminders.periodEnabled = enabled;
        break;
      case ReminderType.ovulation:
        _reminders.ovulationEnabled = enabled;
        break;
      case ReminderType.pill:
        _reminders.pillEnabled = enabled;
        break;
    }
    await _saveData();
    notifyListeners();
  }

  Future<void> initialize() async {
    await _notificationService.initialize();
    // Load dữ liệu đã lưu từ SharedPreferences nếu có
    _loadReminderSettings();
  }

  // Đặt giờ nhắc nhở
  Future<void> setReminderTime(ReminderType type, TimeOfDay time) async {
    switch (type) {
      case ReminderType.smart:
        _reminders.smartTime = time;
        if (_reminders.smartEnabled) {
          await _notificationService.scheduleSmartReminder(time);
        }
        break;
      case ReminderType.period:
        _reminders.periodTime = time;
        if (_reminders.periodEnabled) {
          await _notificationService.schedulePeriodReminder(time, 2);
        }
        break;
      case ReminderType.ovulation:
        _reminders.ovulationTime = time;
        if (_reminders.ovulationEnabled) {
          await _notificationService.scheduleOvulationReminder(time);
        }
        break;
      case ReminderType.pill:
        _reminders.pillTime = time;
        if (_reminders.pillEnabled) {
          await _notificationService.schedulePillReminder(time);
        }
        break;
    }

    _saveReminderSettings();
    notifyListeners();
  }

  // Reset dữ liệu
  Future<void> reset() async {
    // reset dữ liệu
    _startDate = null;
    _cycleDuration = 28;
    _periodDuration = 5;
    _nextPeriodDate = null;
    _ovulationDate = null;
    _fertileWindow = [];
    _currentCycleDay = 1;
    _cyclePhase = '';
    _cycleHistory.clear();

    // reset reminder + notification
    await _notificationService.cancelAllNotifications();
    _reminders = ReminderSettings();
    _saveReminderSettings();

    await _saveData();
    notifyListeners();
  }
}
