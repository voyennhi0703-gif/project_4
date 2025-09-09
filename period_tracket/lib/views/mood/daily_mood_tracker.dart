import 'package:flutter/material.dart';

class DailyMoodTracker extends StatefulWidget {
  final int currentCycleDay;
  final Function(Map<String, dynamic>) onMoodSaved;

  const DailyMoodTracker({
    Key? key,
    required this.currentCycleDay,
    required this.onMoodSaved,
  }) : super(key: key);

  @override
  State<DailyMoodTracker> createState() => _DailyMoodTrackerState();
}

class _DailyMoodTrackerState extends State<DailyMoodTracker> {
  // Selected items
  List<String> selectedMoods = [];
  List<String> selectedSymptoms = [];
  List<String> selectedDischarge = [];
  List<String> selectedSexualActivity = [];
  List<String> selectedOvulationTest = [];
  List<String> selectedPhysicalActivity = [];
  List<String> selectedDigestion = [];
  List<String> selectedPregnancyTest = [];
  List<String> selectedOther = [];

  @override
  Widget build(BuildContext context) {
    return Container(
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
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, size: 24),
                ),
                const Text(
                  'Hôm nay',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 48), // Placeholder for symmetry
              ],
            ),
          ),

          // Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                const SizedBox(height: 16),

                // Cycle day info
                Text(
                  'Ngày chu kỳ ${widget.currentCycleDay}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
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
                      Text('Tìm kiếm', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // How do you feel today section
                _buildSection(
                  title: 'Hôm nay bạn cảm thấy thế nào?',
                  items: [
                    {
                      'icon': '🥚',
                      'label': 'Như lòng trắng trứng',
                      'color': Colors.purple[100]!,
                    },
                    {
                      'icon': '😊',
                      'label': 'Bình tĩnh',
                      'color': Colors.orange[100]!,
                    },
                    {
                      'icon': '💧',
                      'label': 'Trắng đục',
                      'color': Colors.purple[100]!,
                    },
                    {
                      'icon': '🍔',
                      'label': 'Thèm ăn',
                      'color': Colors.brown[100]!,
                    },
                  ],
                  selectedItems: selectedMoods,
                  onItemSelected: (item) {
                    setState(() {
                      if (selectedMoods.contains(item)) {
                        selectedMoods.remove(item);
                      } else {
                        selectedMoods.add(item);
                      }
                    });
                  },
                ),

                const SizedBox(height: 24),

                // Categories section
                _buildCategoriesSection(),

                const SizedBox(height: 24),

                // Save button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final moodData = {
                        'moods': selectedMoods,
                        'symptoms': selectedSymptoms,
                        'discharge': selectedDischarge,
                        'sexualActivity': selectedSexualActivity,
                        'ovulationTest': selectedOvulationTest,
                        'physicalActivity': selectedPhysicalActivity,
                        'digestion': selectedDigestion,
                        'pregnancyTest': selectedPregnancyTest,
                        'other': selectedOther,
                      };
                      widget.onMoodSaved(moodData);
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF26C6DA),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'Lưu',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Danh mục',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'Chỉnh sửa',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Ovulation test
        _buildSection(
          title: 'Thử rụng trứng',
          subtitle: 'Ghi lại để biết thời điểm rụng trứng',
          items: [
            {'icon': '↔️', 'label': 'Đã không thử', 'color': Colors.teal[100]!},
            {
              'icon': '↔️',
              'label': 'Kết quả: có thai',
              'color': Colors.teal[100]!,
            },
            {
              'icon': '↔️',
              'label': 'Kết quả: không có thai',
              'color': Colors.teal[100]!,
            },
            {
              'icon': '↔️',
              'label': 'Rụng trứng: tự tính toán',
              'color': Colors.teal[100]!,
            },
          ],
          selectedItems: selectedOvulationTest,
          onItemSelected: (item) {
            setState(() {
              if (selectedOvulationTest.contains(item)) {
                selectedOvulationTest.remove(item);
              } else {
                selectedOvulationTest.add(item);
              }
            });
          },
        ),

        const SizedBox(height: 24),

        // Sexual activity
        _buildSection(
          title: 'Hoạt động tình dục và nhu cầu tình dục',
          items: [
            {
              'icon': '❤️',
              'label': 'Không quan hệ tình dục',
              'color': Colors.red[100]!,
            },
            {
              'icon': '🔒',
              'label': 'Quan hệ tình dục có bảo vệ',
              'color': Colors.red[100]!,
            },
            {
              'icon': '🔓',
              'label': 'Quan hệ tình dục không bảo vệ',
              'color': Colors.red[100]!,
            },
          ],
          selectedItems: selectedSexualActivity,
          onItemSelected: (item) {
            setState(() {
              if (selectedSexualActivity.contains(item)) {
                selectedSexualActivity.remove(item);
              } else {
                selectedSexualActivity.add(item);
              }
            });
          },
        ),

        const SizedBox(height: 24),

        // Mood section
        _buildSection(
          title: 'Tâm trạng',
          items: [
            {'icon': '😊', 'label': 'Bình tĩnh', 'color': Colors.orange[100]!},
            {'icon': '😄', 'label': 'Vui vẻ', 'color': Colors.orange[100]!},
            {'icon': '⚡', 'label': 'Mạnh mẽ', 'color': Colors.orange[100]!},
            {'icon': '😁', 'label': 'Phấn chấn', 'color': Colors.orange[100]!},
            {
              'icon': '😔',
              'label': 'Thất thường',
              'color': Colors.orange[100]!,
            },
            {'icon': '😠', 'label': 'Bực bội', 'color': Colors.orange[100]!},
            {'icon': '😞', 'label': 'Buồn', 'color': Colors.orange[100]!},
            {'icon': '😟', 'label': 'Lo lắng', 'color': Colors.orange[100]!},
            {'icon': '😩', 'label': 'Trầm cảm', 'color': Colors.orange[100]!},
            {
              'icon': '😥',
              'label': 'Cảm thấy có lỗi',
              'color': Colors.orange[100]!,
            },
            {
              'icon': '☁️',
              'label': 'Suy nghĩ ám ảnh',
              'color': Colors.orange[100]!,
            },
            {
              'icon': '😴',
              'label': 'Thiếu năng lượng',
              'color': Colors.orange[100]!,
            },
            {'icon': '😐', 'label': 'Lãnh đạm', 'color': Colors.orange[100]!},
            {'icon': '😕', 'label': 'Bối rối', 'color': Colors.orange[100]!},
            {
              'icon': '😡',
              'label': 'Rất hay tự trách mình',
              'color': Colors.orange[100]!,
            },
          ],
          selectedItems: selectedMoods,
          onItemSelected: (item) {
            setState(() {
              if (selectedMoods.contains(item)) {
                selectedMoods.remove(item);
              } else {
                selectedMoods.add(item);
              }
            });
          },
        ),

        const SizedBox(height: 24),

        // Symptoms section
        _buildSection(
          title: 'Triệu chứng',
          items: [
            {
              'icon': '👍',
              'label': 'Mọi thứ đều ổn',
              'color': Colors.pink[100]!,
            },
            {'icon': '🤰', 'label': 'Chuột rút', 'color': Colors.pink[100]!},
            {
              'icon': '👙',
              'label': 'Sưng đau ngực',
              'color': Colors.pink[100]!,
            },
            {'icon': '🤕', 'label': 'Đau đầu', 'color': Colors.pink[100]!},
            {'icon': '😷', 'label': 'Mụn', 'color': Colors.pink[100]!},
            {'icon': '🦴', 'label': 'Đau lưng', 'color': Colors.pink[100]!},
            {'icon': '🔋', 'label': 'Mệt mỏi', 'color': Colors.pink[100]!},
            {'icon': '🍔', 'label': 'Thèm ăn', 'color': Colors.pink[100]!},
            {'icon': '🌙', 'label': 'Mất ngủ', 'color': Colors.purple[100]!},
            {'icon': '🤰', 'label': 'Đau bụng', 'color': Colors.pink[100]!},
            {
              'icon': '🌸',
              'label': 'Ngứa âm đạo',
              'color': Colors.purple[100]!,
            },
            {'icon': '💧', 'label': 'Khô âm đạo', 'color': Colors.purple[100]!},
          ],
          selectedItems: selectedSymptoms,
          onItemSelected: (item) {
            setState(() {
              if (selectedSymptoms.contains(item)) {
                selectedSymptoms.remove(item);
              } else {
                selectedSymptoms.add(item);
              }
            });
          },
        ),

        const SizedBox(height: 24),

        // Vaginal discharge section
        _buildSection(
          title: 'Tiết dịch âm đạo',
          items: [
            {
              'icon': '❌',
              'label': 'Không có dịch',
              'color': Colors.purple[100]!,
            },
            {'icon': '💧', 'label': 'Trắng đục', 'color': Colors.purple[100]!},
            {'icon': '💧', 'label': 'Ẩm ướt', 'color': Colors.purple[100]!},
            {'icon': '💧', 'label': 'Dạng dính', 'color': Colors.purple[100]!},
            {
              'icon': '🥚',
              'label': 'Như lòng trắng trứng',
              'color': Colors.purple[100]!,
            },
            {'icon': '🩸', 'label': 'Dạng đốm', 'color': Colors.purple[100]!},
            {'icon': '⚠️', 'label': 'Bất thường', 'color': Colors.purple[100]!},
            {
              'icon': '🔘',
              'label': 'Trắng, vón cục',
              'color': Colors.purple[100]!,
            },
            {'icon': '🔘', 'label': 'Xám', 'color': Colors.purple[100]!},
          ],
          selectedItems: selectedDischarge,
          onItemSelected: (item) {
            setState(() {
              if (selectedDischarge.contains(item)) {
                selectedDischarge.remove(item);
              } else {
                selectedDischarge.add(item);
              }
            });
          },
        ),

        const SizedBox(height: 24),

        // Physical activity section
        _buildSection(
          title: 'Hoạt động thể chất',
          items: [
            {'icon': '❌', 'label': 'Không tập', 'color': Colors.green[100]!},
            {'icon': '🧘', 'label': 'Yoga', 'color': Colors.green[100]!},
            {'icon': '🏋️', 'label': 'Gym', 'color': Colors.green[100]!},
            {
              'icon': '💃',
              'label': 'Aerobic & nhảy múa',
              'color': Colors.green[100]!,
            },
            {'icon': '🏊', 'label': 'Bơi lội', 'color': Colors.green[100]!},
            {
              'icon': '🏀',
              'label': 'Thể thao đồng đội',
              'color': Colors.green[100]!,
            },
            {'icon': '🏃', 'label': 'Chạy', 'color': Colors.green[100]!},
            {'icon': '🚴', 'label': 'Đạp xe đạp', 'color': Colors.green[100]!},
            {'icon': '🚶', 'label': 'Đi bộ', 'color': Colors.green[100]!},
          ],
          selectedItems: selectedPhysicalActivity,
          onItemSelected: (item) {
            setState(() {
              if (selectedPhysicalActivity.contains(item)) {
                selectedPhysicalActivity.remove(item);
              } else {
                selectedPhysicalActivity.add(item);
              }
            });
          },
        ),

        const SizedBox(height: 24),

        // Digestion section
        _buildSection(
          title: 'Tiêu hóa và chất thải',
          items: [
            {'icon': '🤢', 'label': 'Buồn nôn', 'color': Colors.purple[100]!},
            {'icon': '🎈', 'label': 'Đầy hơi', 'color': Colors.purple[100]!},
            {'icon': '🔒', 'label': 'Táo bón', 'color': Colors.purple[100]!},
            {'icon': '🧻', 'label': 'Tiêu chảy', 'color': Colors.purple[100]!},
          ],
          selectedItems: selectedDigestion,
          onItemSelected: (item) {
            setState(() {
              if (selectedDigestion.contains(item)) {
                selectedDigestion.remove(item);
              } else {
                selectedDigestion.add(item);
              }
            });
          },
        ),

        const SizedBox(height: 24),

        // Pregnancy test section
        _buildSection(
          title: 'Thử thai',
          items: [
            {
              'icon': '↔️',
              'label': 'Đã không thử',
              'color': Colors.orange[100]!,
            },
            {'icon': '↔️', 'label': 'Có thai', 'color': Colors.orange[100]!},
            {
              'icon': '↔️',
              'label': 'Không có thai',
              'color': Colors.orange[100]!,
            },
            {'icon': '❓', 'label': 'Không chắc', 'color': Colors.orange[100]!},
          ],
          selectedItems: selectedPregnancyTest,
          onItemSelected: (item) {
            setState(() {
              if (selectedPregnancyTest.contains(item)) {
                selectedPregnancyTest.remove(item);
              } else {
                selectedPregnancyTest.add(item);
              }
            });
          },
        ),

        const SizedBox(height: 24),

        // Other section
        _buildSection(
          title: 'Khác',
          items: [
            {'icon': '📍', 'label': 'Đi lại', 'color': Colors.orange[100]!},
            {'icon': '⚡', 'label': 'Căng thẳng', 'color': Colors.orange[100]!},
            {'icon': '🪷', 'label': 'Thiền', 'color': Colors.orange[100]!},
            {
              'icon': '📖',
              'label': 'Viết nhật ký',
              'color': Colors.orange[100]!,
            },
            {
              'icon': '🦴',
              'label': 'Bài tập Kegel',
              'color': Colors.orange[100]!,
            },
            {
              'icon': '🫁',
              'label': 'Bài tập thở',
              'color': Colors.orange[100]!,
            },
            {
              'icon': '🩹',
              'label': 'Bị bệnh hay bị thương',
              'color': Colors.orange[100]!,
            },
            {'icon': '🍷', 'label': 'Rượu', 'color': Colors.orange[100]!},
          ],
          selectedItems: selectedOther,
          onItemSelected: (item) {
            setState(() {
              if (selectedOther.contains(item)) {
                selectedOther.remove(item);
              } else {
                selectedOther.add(item);
              }
            });
          },
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    String? subtitle,
    required List<Map<String, dynamic>> items,
    required List<String> selectedItems,
    required Function(String) onItemSelected,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.map((item) {
              final label = item['label'] as String;
              final isSelected = selectedItems.contains(label);

              return GestureDetector(
                onTap: () => onItemSelected(label),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? item['color']
                        : item['color'].withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                    border: isSelected
                        ? Border.all(color: Colors.grey[400]!, width: 1)
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(item['icon'], style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}




