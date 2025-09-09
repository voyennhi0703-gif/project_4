import 'package:flutter/material.dart';
import 'package:period_tracket/common/colo_extension.dart';

class CareView extends StatefulWidget {
  const CareView({super.key});

  @override
  State<CareView> createState() => _CareViewState();
}

class _CareViewState extends State<CareView> {
  Map<int, bool> completedExercises = {};
  String selectedCategory = "Tất cả";

  final List<String> categories = [
    "Tất cả",
    "Thư giãn",
    "Massage",
    "Yoga",
    "Vận động",
    "Trị liệu",
  ];

  final List<Exercise> exercises = [
    Exercise(
      id: 1,
      title: "Thở sâu và thư giãn",
      duration: "5 phút",
      description: "Kỹ thuật thở sâu giúp giảm căng thẳng và đau bụng kinh",
      icon: "🧘‍♀️",
      category: "Thư giãn",
      steps: [
        "Ngồi hoặc nằm ở tư thế thoải mái",
        "Đặt một tay lên ngực, một tay lên bụng",
        "Hít thở chậm qua mũi trong 4 giây",
        "Giữ hơi thở trong 4 giây",
        "Thở ra chậm qua miệng trong 6 giây",
        "Lặp lại 10-15 lần",
      ],
    ),
    Exercise(
      id: 2,
      title: "Massage bụng nhẹ nhàng",
      duration: "10 phút",
      description: "Massage vùng bụng giúp giảm co thắt và đau bụng",
      icon: "💆‍♀️",
      category: "Massage",
      steps: [
        "Nằm ngửa, gối hơi cong",
        "Dùng đầu ngón tay massage nhẹ nhàng theo chiều kim đồng hồ",
        "Bắt đầu từ rốn, từ từ mở rộng ra",
        "Áp dụng áp lực nhẹ, thoải mái",
        "Massage trong 2-3 phút mỗi khu vực",
        "Có thể sử dụng tinh dầu lavender để thư giãn",
      ],
    ),
    Exercise(
      id: 3,
      title: "Tư thế mèo - bò",
      duration: "8 phút",
      description: "Bài tập yoga giúp giảm đau lưng và bụng dưới",
      icon: "🐱",
      category: "Yoga",
      steps: [
        "Quỳ gối, hai tay chống đất",
        "Cong lưng lên như con mèo, hạ đầu",
        "Giữ trong 5 giây",
        "Võng lưng xuống, ngẩng đầu lên",
        "Giữ trong 5 giây",
        "Lặp lại 10-15 lần chậm rãi",
      ],
    ),
    Exercise(
      id: 4,
      title: "Tư thế em bé",
      duration: "5 phút",
      description: "Tư thế thư giãn giúp giảm căng thẳng vùng bụng",
      icon: "🤱",
      category: "Yoga",
      steps: [
        "Quỳ gối trên thảm",
        "Ngồi gót chân, tách đầu gối rộng bằng hông",
        "Cúi người về phía trước, đặt trán xuống thảm",
        "Duỗi tay về phía trước hoặc để hai bên",
        "Thở sâu và giữ tư thế 3-5 phút",
        "Cảm nhận sự thư giãn ở lưng và bụng",
      ],
    ),
    Exercise(
      id: 5,
      title: "Đi bộ nhẹ nhàng",
      duration: "15 phút",
      description: "Vận động nhẹ giúp cải thiện tuần hoàn và giảm đau",
      icon: "🚶‍♀️",
      category: "Vận động",
      steps: [
        "Chọn địa điểm yên tĩnh, không khí trong lành",
        "Đi bộ với nhịp độ chậm, thoải mái",
        "Tập trung vào hơi thở đều đặn",
        "Làm các động tác duỗi tay nhẹ khi đi",
        "Nghỉ ngơi khi cần thiết",
        "Kết thúc với 2-3 phút duỗi cơ nhẹ",
      ],
    ),
    Exercise(
      id: 6,
      title: "Chườm ấm",
      duration: "20 phút",
      description: "Nhiệt độ ấm giúp giãn cơ và giảm đau hiệu quả",
      icon: "🔥",
      category: "Trị liệu",
      steps: [
        "Chuẩn bị túi chườm nóng hoặc khăn ấm",
        "Kiểm tra nhiệt độ vừa phải (không quá nóng)",
        "Đặt lên vùng bụng dưới hoặc lưng",
        "Nằm thư giãn trong 15-20 phút",
        "Có thể kết hợp với nhạc nhẹ nhàng",
        "Uống nước ấm để tăng hiệu quả",
      ],
    ),
  ];

  List<Exercise> get filteredExercises {
    if (selectedCategory == "Tất cả") {
      return exercises;
    }
    return exercises
        .where((exercise) => exercise.category == selectedCategory)
        .toList();
  }

  void toggleComplete(int exerciseId) {
    setState(() {
      completedExercises[exerciseId] =
          !(completedExercises[exerciseId] ?? false);
    });
  }

  void startExercise(Exercise exercise) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExerciseDetailView(
          exercise: exercise,
          isCompleted: completedExercises[exercise.id] ?? false,
          onToggleComplete: () => toggleComplete(exercise.id),
        ),
      ),
    );
  }

  double get progressPercentage {
    int completedCount = completedExercises.values
        .where((completed) => completed)
        .length;
    return completedCount / exercises.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [TColor.lightGray, TColor.softPink.withOpacity(0.3)],
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [TColor.rosePink, TColor.coral],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.favorite, color: TColor.white, size: 28),
                          const SizedBox(width: 12),
                          Text(
                            "Chăm sóc bản thân",
                            style: TextStyle(
                              color: TColor.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Các bài tập giảm đau kỳ kinh nguyệt tự nhiên và hiệu quả",
                        style: TextStyle(
                          color: TColor.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Category Filter
                    Container(
                      height: 40,
                      margin: const EdgeInsets.only(bottom: 24),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          final isSelected = selectedCategory == category;
                          return Container(
                            margin: const EdgeInsets.only(right: 8),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  selectedCategory = category;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isSelected
                                    ? TColor.rosePink
                                    : TColor.white,
                                foregroundColor: isSelected
                                    ? TColor.white
                                    : TColor.gray,
                                elevation: isSelected ? 2 : 0,
                                side: isSelected
                                    ? null
                                    : BorderSide(
                                        color: TColor.gray.withOpacity(0.3),
                                      ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: Text(category),
                            ),
                          );
                        },
                      ),
                    ),

                    // Progress Card
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 24),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: TColor.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: TColor.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Tiến độ hôm nay",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: TColor.black,
                                ),
                              ),
                              Text(
                                "${completedExercises.values.where((completed) => completed).length}/${exercises.length}",
                                style: TextStyle(
                                  color: TColor.gray,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: progressPercentage,
                            backgroundColor: TColor.lightGray,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              TColor.rosePink,
                            ),
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      ),
                    ),

                    // Exercise List
                    ...filteredExercises
                        .map(
                          (exercise) => ExerciseCard(
                            exercise: exercise,
                            isCompleted:
                                completedExercises[exercise.id] ?? false,
                            onStart: () => startExercise(exercise),
                          ),
                        )
                        .toList(),

                    // Bottom Tip
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 32),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            TColor.softPink.withOpacity(0.3),
                            TColor.blushPink.withOpacity(0.3),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("💡", style: TextStyle(fontSize: 24)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Lời khuyên",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: TColor.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Thực hiện đều đặn các bài tập này sẽ giúp giảm đáng kể cơn đau kinh nguyệt. Hãy lắng nghe cơ thể và dừng lại khi cần thiết.",
                                  style: TextStyle(
                                    color: TColor.gray,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
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

class ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final bool isCompleted;
  final VoidCallback onStart;

  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.isCompleted,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TColor.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: TColor.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: TColor.softPink,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(exercise.icon, style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 16),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        exercise.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: TColor.black,
                        ),
                      ),
                    ),
                    if (isCompleted)
                      Icon(
                        Icons.check_circle,
                        color: Colors.green.shade500,
                        size: 20,
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  exercise.description,
                  style: TextStyle(color: TColor.gray, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 12, color: TColor.gray),
                    const SizedBox(width: 4),
                    Text(
                      exercise.duration,
                      style: TextStyle(color: TColor.gray, fontSize: 12),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: TColor.blushPink.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        exercise.category,
                        style: TextStyle(color: TColor.rosePink, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onStart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TColor.rosePink,
                      foregroundColor: TColor.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.play_arrow, size: 16),
                        SizedBox(width: 4),
                        Text("Bắt đầu", style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ExerciseDetailView extends StatelessWidget {
  final Exercise exercise;
  final bool isCompleted;
  final VoidCallback onToggleComplete;

  const ExerciseDetailView({
    super.key,
    required this.exercise,
    required this.isCompleted,
    required this.onToggleComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [TColor.lightGray, TColor.softPink.withOpacity(0.3)],
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [TColor.rosePink, TColor.coral],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          InkWell(
                            onTap: () => Navigator.pop(context),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.arrow_back,
                                  color: TColor.white.withOpacity(0.7),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Quay lại",
                                  style: TextStyle(
                                    color: TColor.white.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Text(
                            exercise.icon,
                            style: const TextStyle(fontSize: 32),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  exercise.title,
                                  style: TextStyle(
                                    color: TColor.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      color: TColor.white,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      exercise.duration,
                                      style: TextStyle(
                                        color: TColor.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.description,
                      style: TextStyle(color: TColor.gray, fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Các bước thực hiện:",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: TColor.black,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Steps
                    ...exercise.steps.asMap().entries.map((entry) {
                      int index = entry.key;
                      String step = entry.value;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: TColor.lightGray,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: TColor.rosePink,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  "${index + 1}",
                                  style: TextStyle(
                                    color: TColor.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                step,
                                style: TextStyle(
                                  color: TColor.black,
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),

                    const SizedBox(height: 24),

                    // Complete Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          onToggleComplete();
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isCompleted
                              ? Colors.green.shade500
                              : TColor.rosePink,
                          foregroundColor: TColor.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isCompleted) ...[
                              const Icon(Icons.check_circle),
                              const SizedBox(width: 8),
                              const Text("Đã hoàn thành"),
                            ] else
                              const Text("Đánh dấu hoàn thành"),
                          ],
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
    );
  }
}

class Exercise {
  final int id;
  final String title;
  final String duration;
  final String description;
  final String icon;
  final String category;
  final List<String> steps;

  Exercise({
    required this.id,
    required this.title,
    required this.duration,
    required this.description,
    required this.icon,
    required this.category,
    required this.steps,
  });
}
