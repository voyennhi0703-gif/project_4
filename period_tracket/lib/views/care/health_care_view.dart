import 'package:flutter/material.dart';
import 'package:period_tracket/views/data/data_manager.dart';
import 'package:provider/provider.dart';

class HealthCareView extends StatefulWidget {
  const HealthCareView({super.key});

  @override
  State<HealthCareView> createState() => _HealthCareViewState();
}

class _HealthCareViewState extends State<HealthCareView> {
  String? selectedSection; // 'exercise' hoặc 'nutrition'

  void _showHealthSection(String type) {
    setState(() {
      selectedSection = type;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildHealthModal(type),
    );
  }

  void _closeHealthSection() {
    setState(() {
      selectedSection = null;
    });
  }

  Widget _buildHealthCards() {
    return Row(
      children: [
        Expanded(
          child: _buildHealthCard(
            'exercise',
            '💪',
            'Vận động',
            'Bài tập phù hợp cho hôm nay',
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildHealthCard(
            'nutrition',
            '🥗',
            'Dinh dưỡng',
            'Chế độ ăn phù hợp',
          ),
        ),
      ],
    );
  }

  Widget _buildHealthCard(
    String type,
    String icon,
    String title,
    String subtitle,
  ) {
    bool isActive = selectedSection == type;

    return GestureDetector(
      onTap: () => _showHealthSection(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        height: 180, // Tăng chiều cao để đủ diện tích hiển thị
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isActive
                  ? Colors.blue.withOpacity(0.3)
                  : Colors.black.withOpacity(0.08),
              blurRadius: isActive ? 15 : 10,
              offset: Offset(0, isActive ? 6 : 4),
            ),
          ],
          border: isActive
              ? Border.all(color: Colors.blue.shade300, width: 2)
              : null,
        ),
        transform: Matrix4.identity()
          ..scale(isActive ? 0.95 : 1.0), // Hiệu ứng scale khi được chọn
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Icon section với kích thước lớn hơn
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isActive ? Colors.blue.shade50 : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                icon,
                style: TextStyle(
                  fontSize: 36,
                  color: isActive ? Colors.blue.shade600 : null,
                ),
              ),
            ),
            // Text section với spacing tốt hơn
            Column(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isActive ? Colors.blue.shade700 : Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: isActive ? Colors.blue.shade600 : Colors.grey[600],
                    fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthModal(String type) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) {
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
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _closeHealthSection();
                      },
                      icon: const Icon(Icons.close),
                    ),
                    Row(
                      children: [
                        Text(
                          type == 'exercise' ? '💪' : '🥗',
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          type == 'exercise' ? 'Vận động' : 'Dinh dưỡng',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Consumer<DataManager>(
                      builder: (context, dataManager, child) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            dataManager.cyclePhase.isNotEmpty
                                ? dataManager.cyclePhase
                                : 'Dễ thụ thai',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: type == 'exercise'
                    ? _buildExerciseContent(scrollController)
                    : _buildNutritionContent(scrollController),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExerciseContent(ScrollController scrollController) {
    return Consumer<DataManager>(
      builder: (context, dataManager, child) {
        List<Map<String, String>> exercises = _getExercisesForPhase(
          dataManager.cyclePhase,
        );
        List<String> tips = _getExerciseTips(dataManager.cyclePhase);

        return ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          children: [
            // Exercise list
            ...exercises.map((exercise) => _buildExerciseItem(exercise)),

            const SizedBox(height: 20),

            // Tips section
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange[50]!, Colors.yellow[50]!],
                ),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.orange[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Text('💡', style: TextStyle(fontSize: 16)),
                      SizedBox(width: 8),
                      Text(
                        'Lưu ý quan trọng',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...tips.map(
                    (tip) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '•',
                            style: TextStyle(
                              color: Colors.orange[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              tip,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNutritionContent(ScrollController scrollController) {
    return Consumer<DataManager>(
      builder: (context, dataManager, child) {
        Map<String, List<Map<String, String>>> nutritionData =
            _getNutritionForPhase(dataManager.cyclePhase);
        List<String> nutritionTips = _getNutritionTips(dataManager.cyclePhase);

        return ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          children: [
            // Good foods
            _buildFoodCategory(
              'Nên ăn',
              '✅',
              nutritionData['good']!,
              Colors.green,
            ),

            const SizedBox(height: 20),

            // Foods to avoid
            _buildFoodCategory(
              'Nên tránh',
              '⚠️',
              nutritionData['avoid']!,
              Colors.red,
            ),

            const SizedBox(height: 20),

            // Nutrition tips
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[50]!, Colors.cyan[50]!],
                ),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.blue[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Text('🌟', style: TextStyle(fontSize: 16)),
                      SizedBox(width: 8),
                      Text(
                        'Gợi ý dinh dưỡng',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...nutritionTips.map(
                    (tip) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '•',
                            style: TextStyle(
                              color: Colors.blue[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              tip,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildExerciseItem(Map<String, String> exercise) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Text(exercise['emoji']!, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise['name']!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  exercise['description']!,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              exercise['duration']!,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodCategory(
    String title,
    String icon,
    List<Map<String, String>> foods,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.8,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: foods.length,
          itemBuilder: (context, index) {
            return _buildFoodItem(foods[index], color);
          },
        ),
      ],
    );
  }

  Widget _buildFoodItem(Map<String, String> food, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color == Colors.green ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color == Colors.green ? Colors.green[300]! : Colors.red[300]!,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(food['emoji']!, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 6),
          Text(
            food['name']!,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            food['note']!,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  // Data methods
  List<Map<String, String>> _getExercisesForPhase(String phase) {
    switch (phase) {
      case 'Kỳ kinh':
        return [
          {
            'emoji': '🧘‍♀️',
            'name': 'Yoga nhẹ nhàng',
            'description': 'Giảm đau bụng, thư giãn cơ bắp',
            'duration': '10-15p',
          },
          {
            'emoji': '🚶‍♀️',
            'name': 'Đi bộ chậm',
            'description': 'Cải thiện lưu thông máu',
            'duration': '20-30p',
          },
          {
            'emoji': '🛁',
            'name': 'Tắm nước ấm',
            'description': 'Giảm căng thẳng và đau',
            'duration': '15-20p',
          },
        ];
      default:
        return [
          {
            'emoji': '🧘‍♀️',
            'name': 'Yoga nhẹ nhàng',
            'description': 'Giúp thư giãn và cân bằng hormone',
            'duration': '15-20p',
          },
          {
            'emoji': '🚶‍♀️',
            'name': 'Đi bộ',
            'description': 'Tăng cường tuần hoàn máu, hỗ trợ rụng trứng',
            'duration': '30p',
          },
          {
            'emoji': '🏊‍♀️',
            'name': 'Bơi lội',
            'description': 'Vận động toàn thân, không gây căng thẳng',
            'duration': '20-30p',
          },
        ];
    }
  }

  List<String> _getExerciseTips(String phase) {
    switch (phase) {
      case 'Kỳ kinh':
        return [
          'Tránh vận động mạnh có thể làm tăng đau bụng',
          'Nghỉ ngơi nhiều hơn, nghe theo cơ thể',
          'Uống nhiều nước để bù đắp lượng mất nước',
        ];
      default:
        return [
          'Tránh vận động quá mức có thể ảnh hưởng đến chu kỳ rụng trứng',
          'Thời gian này cơ thể dễ bị thương, hãy khởi động kỹ trước khi tập',
        ];
    }
  }

  Map<String, List<Map<String, String>>> _getNutritionForPhase(String phase) {
    switch (phase) {
      case 'Kỳ kinh':
        return {
          'good': [
            {
              'emoji': '🥬',
              'name': 'Rau xanh',
              'note': 'Bổ sung sắt và folate',
            },
            {'emoji': '🍫', 'name': 'Socola đen', 'note': 'Giảm căng thẳng'},
            {'emoji': '🐟', 'name': 'Cá hồi', 'note': 'Omega-3 chống viêm'},
            {'emoji': '🥜', 'name': 'Hạt óc chó', 'note': 'Magiê giảm đau'},
          ],
          'avoid': [
            {'emoji': '🧂', 'name': 'Đồ mặn', 'note': 'Gây phù nề, khó chịu'},
            {'emoji': '☕', 'name': 'Café nhiều', 'note': 'Làm tăng lo âu'},
            {'emoji': '🍟', 'name': 'Đồ chiên', 'note': 'Gây viêm nhiễm'},
            {
              'emoji': '🥤',
              'name': 'Đồ uống có gas',
              'note': 'Làm đầy hơi bụng',
            },
          ],
        };
      default:
        return {
          'good': [
            {
              'emoji': '🥑',
              'name': 'Bơ',
              'note': 'Giàu folate, tốt cho thụ thai',
            },
            {
              'emoji': '🐟',
              'name': 'Cá hồi',
              'note': 'Omega-3 cân bằng hormone',
            },
            {
              'emoji': '🥬',
              'name': 'Rau xanh',
              'note': 'Vitamin E, sắt cho cơ thể',
            },
            {
              'emoji': '🥜',
              'name': 'Hạt óc chó',
              'note': 'Protein, chất béo tốt',
            },
          ],
          'avoid': [
            {
              'emoji': '☕',
              'name': 'Café quá nhiều',
              'note': 'Có thể ảnh hưởng rụng trứng',
            },
            {
              'emoji': '🍷',
              'name': 'Rượu bia',
              'note': 'Giảm khả năng thụ thai',
            },
            {
              'emoji': '🍟',
              'name': 'Đồ chiên rán',
              'note': 'Gây viêm, mất cân bằng',
            },
            {
              'emoji': '🍭',
              'name': 'Đường tinh luyện',
              'note': 'Làm dao động hormone',
            },
          ],
        };
    }
  }

  List<String> _getNutritionTips(String phase) {
    switch (phase) {
      case 'Kỳ kinh':
        return [
          'Uống đủ nước (2-2.5L/ngày) để giảm chuột rút',
          'Ăn nhiều thực phẩm giàu sắt để bù đắp lượng mất máu',
          'Bổ sung magiê từ hạt và rau xanh để giảm đau',
        ];
      default:
        return [
          'Uống đủ nước (2-2.5L/ngày) để hỗ trợ quá trình rụng trứng',
          'Bổ sung axit folic để chuẩn bị cho khả năng thụ thai',
          'Ăn nhiều bữa nhỏ để ổn định đường huyết',
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildHealthCards();
  }
}
