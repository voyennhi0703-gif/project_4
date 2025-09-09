import 'package:flutter/material.dart';
import 'package:period_tracket/models/mood_data.dart';
import 'package:period_tracket/services/mood_service.dart';

class MoodTrackerView extends StatefulWidget {
  final int currentCycleDay;
  final Function(MoodData) onMoodSaved;

  const MoodTrackerView({
    Key? key,
    required this.currentCycleDay,
    required this.onMoodSaved,
  }) : super(key: key);

  @override
  State<MoodTrackerView> createState() => _MoodTrackerViewState();
}

class _MoodTrackerViewState extends State<MoodTrackerView> {
  List<String> selectedMoods = [];
  List<String> selectedSymptoms = [];
  TextEditingController noteController = TextEditingController();
  bool isLoading = false;

  final List<Map<String, String>> moodOptions = [
    {'icon': '😊', 'label': 'Bình tĩnh'},
    {'icon': '😄', 'label': 'Vui vẻ'},
    {'icon': '⚡', 'label': 'Mạnh mẽ'},
    {'icon': '😌', 'label': 'Phấn chấn'},
    {'icon': '😰', 'label': 'Thất thường'},
    {'icon': '😠', 'label': 'Bực bội'},
    {'icon': '😢', 'label': 'Buồn'},
    {'icon': '😴', 'label': 'Lo lắng'},
    {'icon': '😓', 'label': 'Trầm cảm'},
    {'icon': '🤔', 'label': 'Cảm thấy cô lập'},
    {'icon': '😮', 'label': 'Suy nghĩ âm ảnh'},
    {'icon': '💭', 'label': 'Thiếu năng lượng'},
    {'icon': '😌', 'label': 'Lãnh đạm'},
    {'icon': '😕', 'label': 'Bối rối'},
    {'icon': '🤯', 'label': 'Hay tự trách mình'},
  ];

  final List<Map<String, dynamic>> symptomOptions = [
    {'icon': '🔮', 'label': 'Mọi thứ đều ổn', 'color': Color(0xFFE1BEE7)},
    {'icon': '💦', 'label': 'Chuyết rút', 'color': Color(0xFFE1BEE7)},
    {'icon': '🌀', 'label': 'Sưng đau ngực', 'color': Color(0xFFE1BEE7)},
    {'icon': '💜', 'label': 'Đau đầu', 'color': Color(0xFFE1BEE7)},
    {'icon': '🧠', 'label': 'Mụn', 'color': Color(0xFFE1BEE7)},
    {'icon': '🌺', 'label': 'Đau lưng', 'color': Color(0xFFE1BEE7)},
    {'icon': '💜', 'label': 'Mệt mỏi', 'color': Color(0xFFE1BEE7)},
    {'icon': '🔮', 'label': 'Thèm ăn', 'color': Color(0xFFE1BEE7)},
    {'icon': '💜', 'label': 'Mất ngủ', 'color': Color(0xFFE1BEE7)},
    {'icon': '🌀', 'label': 'Đau bụng', 'color': Color(0xFFE1BEE7)},
  ];

  @override
  void initState() {
    super.initState();
    _loadTodayMood();
  }

  Future<void> _loadTodayMood() async {
    final todayMood = await MoodService.getMoodForDate(DateTime.now());
    if (todayMood != null) {
      setState(() {
        selectedMoods = List.from(todayMood.selectedMoods);
        selectedSymptoms = List.from(todayMood.selectedSymptoms);
        noteController.text = todayMood.note ?? '';
      });
    }
  }

  Future<void> _saveMoodData() async {
    if (selectedMoods.isEmpty && selectedSymptoms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ít nhất một tâm trạng hoặc triệu chứng'),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final moodData = MoodData(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: DateTime.now(),
        selectedMoods: selectedMoods,
        selectedSymptoms: selectedSymptoms,
        note: noteController.text.trim().isEmpty
            ? null
            : noteController.text.trim(),
        cycleDay: widget.currentCycleDay,
      );

      await MoodService.saveMoodData(moodData);
      widget.onMoodSaved(moodData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã lưu tâm trạng hôm nay!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi khi lưu dữ liệu: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
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
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                  Column(
                    children: [
                      const Text(
                        'Hôm nay',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Ngày chu kỳ ${widget.currentCycleDay}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: isLoading ? null : _saveMoodData,
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Lưu',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                children: [
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
                        Text('Tìm kiếm', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Question
                  const Text(
                    'Hôm nay bạn cảm thấy thế nào?',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 16),

                  // Mood section
                  _buildMoodSection(),

                  const SizedBox(height: 24),

                  // Symptoms section
                  _buildSymptomSection(),

                  const SizedBox(height: 24),

                  // Note section
                  _buildNoteSection(),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tâm trạng',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: moodOptions
              .map(
                (mood) =>
                    _buildMoodChip(icon: mood['icon']!, label: mood['label']!),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildSymptomSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Triệu chứng',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: symptomOptions
              .map(
                (symptom) => _buildSymptomChip(
                  icon: symptom['icon']!,
                  label: symptom['label']!,
                  color: symptom['color'] as Color,
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildNoteSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ghi chú (tùy chọn)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextField(
            controller: noteController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Thêm ghi chú về cảm xúc hôm nay...',
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMoodChip({required String icon, required String label}) {
    bool isSelected = selectedMoods.contains(label);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            selectedMoods.remove(label);
          } else {
            selectedMoods.add(label);
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF4081) : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(color: const Color(0xFFFF4081))
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFFF4081).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
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
}
