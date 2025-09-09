class MoodData {
  final String id;
  final DateTime date;
  final List<String> selectedMoods;
  final List<String> selectedSymptoms;
  final String? note;
  final int cycleDay;

  MoodData({
    required this.id,
    required this.date,
    required this.selectedMoods,
    required this.selectedSymptoms,
    this.note,
    required this.cycleDay,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'selectedMoods': selectedMoods,
      'selectedSymptoms': selectedSymptoms,
      'note': note,
      'cycleDay': cycleDay,
    };
  }

  static MoodData fromJson(Map<String, dynamic> json) {
    return MoodData(
      id: json['id'],
      date: DateTime.parse(json['date']),
      selectedMoods: List<String>.from(json['selectedMoods']),
      selectedSymptoms: List<String>.from(json['selectedSymptoms']),
      note: json['note'],
      cycleDay: json['cycleDay'],
    );
  }
}
