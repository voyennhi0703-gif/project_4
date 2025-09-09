// lib/views/data/cycle_data.dart

/// Mô tả 1 chu kỳ (để hiển thị lịch sử, vẽ chấm, lưu/đọc storage)
class CycleData {
  /// Ngày bắt đầu chu kỳ
  final DateTime startDate;

  /// Số ngày hành kinh trong chu kỳ
  final int periodDays;

  /// Tổng số ngày của chu kỳ
  final int cycleDays;

  /// Các mốc tính sẵn để hiển thị (không cần tính lại ở UI)
  final int ovulationDay; // = cycleDays - 14
  final int fertileStartDay; // = cycleDays - 18
  final int fertileEndDay; // = cycleDays - 10

  CycleData({
    required this.startDate,
    required this.periodDays,
    required this.cycleDays,
  }) : ovulationDay = (cycleDays - 14).clamp(
         1,
         cycleDays,
       ), // Ngày rụng trứng = 14 ngày trước ngày kết thúc chu kỳ
       fertileStartDay = (cycleDays - 18).clamp(
         1,
         cycleDays,
       ), // Cửa sổ thụ thai bắt đầu = 18 ngày trước ngày kết thúc
       fertileEndDay = (cycleDays - 10).clamp(
         1,
         cycleDays,
       ); // Cửa sổ thụ thai kết thúc = 10 ngày trước ngày kết thúc

  /// Serialize sang JSON (để lưu SharedPreferences)
  Map<String, dynamic> toJson() => {
    'startDate': startDate.millisecondsSinceEpoch,
    'periodDays': periodDays,
    'cycleDays': cycleDays,
  };

  /// Parse từ JSON (đọc SharedPreferences)
  factory CycleData.fromJson(Map<String, dynamic> json) => CycleData(
    startDate: DateTime.fromMillisecondsSinceEpoch(json['startDate']),
    periodDays: json['periodDays'],
    cycleDays: json['cycleDays'],
  );
}
