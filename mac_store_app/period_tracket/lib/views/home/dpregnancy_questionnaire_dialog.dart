import 'package:flutter/material.dart';

// Model để lưu trữ kết quả questionnaire
class PregnancyQuestionnaireResult {
  final Map<String, dynamic> answers;

  PregnancyQuestionnaireResult({required this.answers});

  Map<String, dynamic> toMap() {
    return answers;
  }
}

// Model cho từng câu hỏi
class QuestionData {
  final String question;
  final List<AnswerOption> options;
  final String key;

  QuestionData({
    required this.question,
    required this.options,
    required this.key,
  });
}

// Model cho từng lựa chọn trả lời
class AnswerOption {
  final String text;
  final String? description;
  final bool isHighlighted;

  AnswerOption({
    required this.text,
    this.description,
    this.isHighlighted = false,
  });
}

class PregnancyQuestionnaireDialog extends StatefulWidget {
  const PregnancyQuestionnaireDialog({super.key});

  @override
  State<PregnancyQuestionnaireDialog> createState() =>
      _PregnancyQuestionnaireDialogState();
}

class _PregnancyQuestionnaireDialogState
    extends State<PregnancyQuestionnaireDialog> {
  int _currentQuestionIndex = 0;
  Map<String, String> _answers = {};
  PageController _pageController = PageController();

  // Danh sách tất cả các câu hỏi
  final List<QuestionData> _questions = [
    // Câu 1: Thời gian nỗ lực thụ thai
    QuestionData(
      key: 'duration',
      question: 'Bạn đã tích cực nỗ lực thụ thai bao lâu rồi?',
      options: [
        AnswerOption(
          text: 'Vừa mới bắt đầu',
          description:
              'Khoảng 84% số cặp đôi thường xuyên quan hệ tình dục không dùng biện pháp bảo vệ (2 - 3 lần/tuần) sẽ thụ thai trong vòng một năm kể từ khi nỗ lực mang thai. Flo sẵn sàng giúp bạn tăng tối đa cơ hội thụ thai dựa trên thông tin dự đoán về chu kỳ và mẹo hữu ích.',
          isHighlighted: true,
        ),
        AnswerOption(text: '1 tháng'),
        AnswerOption(text: '2 tháng'),
        AnswerOption(text: '3 tháng'),
        AnswerOption(text: '4 tháng'),
        AnswerOption(text: '5 tháng'),
        AnswerOption(text: '6 tháng'),
        AnswerOption(text: '7 tháng'),
        AnswerOption(text: '8 tháng'),
        AnswerOption(text: '9 tháng'),
        AnswerOption(text: '10 tháng'),
        AnswerOption(text: '11 tháng'),
        AnswerOption(text: 'Hơn một năm'),
      ],
    ),

    // Câu 2: Tính đều đặn của chu kỳ kinh
    QuestionData(
      key: 'regularity',
      question:
          'Kỳ kinh của bạn có được coi là đều (chênh lệch ít hơn 7 ngày giữa chu kỳ ngắn nhất và dài nhất) không?',
      options: [
        AnswerOption(text: 'Có'),
        AnswerOption(text: 'Không'),
        AnswerOption(
          text: 'Tôi không biết',
          description:
              'Flo có thể giúp bạn tính toán ngay có khả năng thụ thai và ngày bắt đầu chu kỳ tiếp theo ngay cả khi chu kỳ của bạn không đều. Bạn có thể ghi lại các triệu chứng để giúp dự đoán thêm chính xác.',
          isHighlighted: true,
        ),
      ],
    ),

    // Câu 3: Tính toán khung thời gian để thụ thai
    QuestionData(
      key: 'planning_timeframe',
      question:
          'Bạn có tính toán khung thời gian để thụ thai khi lập kế hoạch cho đời sống tình dục không?',
      options: [
        AnswerOption(
          text: 'Có',
          description:
              'Tuyệt lắm! Flo sẽ giúp việc này dễ dàng hơn cho bạn. Hãy tìm những ngày có màu xanh mong kết trong ứng dụng khi bạn có kế hoạch thân mật.',
          isHighlighted: true,
        ),
        AnswerOption(text: 'Tôi có nghĩ về cách này nhưng không làm theo'),
        AnswerOption(text: 'Tôi không biết khung thời gian để thụ thai là gì'),
      ],
    ),

    // Câu 4: Dịch vụ chăm sóc trước khi mang thai
    QuestionData(
      key: 'preconception_care',
      question:
          'Gần đây, bạn có tìm đến dịch vụ chăm sóc trước khi mang thai không?',
      options: [
        AnswerOption(
          text: 'Tôi đã đi kiểm tra',
          description:
              'Thật tuyệt khi có một chuyên gia giúp bạn theo dõi quá trình chuẩn bị mang thai. Flo sẽ cung cấp cho bạn các mẹo bổ sung về cách chăm sóc bản thân bạn và tăng tối đa cơ hội thụ thai.',
          isHighlighted: true,
        ),
        AnswerOption(text: 'Tôi đang trong quá trình điều trị'),
        AnswerOption(text: 'Tôi đã trải qua quá trình điều trị'),
        AnswerOption(text: 'Tôi đang chờ cuộc hẹn khám'),
        AnswerOption(text: 'Tôi đã nghĩ đó là việc không cần thiết'),
      ],
    ),

    // Câu 5: Sử dụng vitamin hoặc sản phẩm bổ sung
    QuestionData(
      key: 'vitamins',
      question:
          'Bạn có dùng vitamin hoặc sản phẩm bổ sung cho bà bầu nào không?',
      options: [
        AnswerOption(text: 'Có, một sản phẩm phức hợp vitamin đặc biệt'),
        AnswerOption(text: 'Tôi dùng axit folic'),
        AnswerOption(
          text: 'Tôi không dùng vitamin hay sản phẩm bổ sung nào',
          description:
              'Bạn có thể đặt lời nhắc uống thuốc hoặc vitamin trong Flo. Nhà cung cấp dịch vụ chăm sóc sức khỏe có thể giúp bạn xác định bạn có cần dùng vitamin đành cho bà bầu hay không và nếu có thì với liều lượng bao nhiêu.',
          isHighlighted: true,
        ),
      ],
    ),

    // Câu 6: Thay đổi lối sống
    QuestionData(
      key: 'lifestyle_changes',
      question:
          'Bạn có thay đổi lối sống (dinh dưỡng, hoạt động thể chất, v.v.) trước khi nỗ lực thụ thai không?',
      options: [
        AnswerOption(text: 'Có, tôi đã điều chỉnh lối sống'),
        AnswerOption(text: 'Tôi không thay đổi điều gì trong thói quen'),
        AnswerOption(
          text: 'Tôi không biết rằng mình cần thay đổi điều gì đó',
          description:
              'Duy trì sức khỏe tốt là điều quan trong cho cả bạn và em bé sắp chào đời. Flo sẽ chia sẻ những cách đơn giản để bạn đưa ra lựa chọn lối sống lành mạnh hơn thông qua các thông tin chuyên sâu hàng ngày về sức khỏe.',
          isHighlighted: true,
        ),
      ],
    ),

    // Câu 7: Thay đổi bất cứ điều gì để chuẩn bị cho việc thụ thai
    QuestionData(
      key: 'preparation_changes',
      question:
          'Bạn đối của bạn có thay đổi bất cứ điều gì để chuẩn bị cho việc thụ thai không?',
      options: [
        AnswerOption(text: 'Thay đổi về lối sống'),
        AnswerOption(text: 'Kiểm tra sức khỏe'),
        AnswerOption(text: 'Tôi không biết rằng họ cần chuẩn bị'),
        AnswerOption(text: 'Bạn đời của tôi không tham gia vào việc thụ thai'),
        AnswerOption(
          text: 'Tôi hiện không có bạn đời',
          description: 'Cảm ơn bạn đã trả lời câu hỏi.',
        ),
      ],
    ),

    // Câu 8: Dự định theo dõi sự phát triển của em bé
    QuestionData(
      key: 'baby_development_tracking',
      question:
          'Bạn dự định theo dõi sự phát triển của em bé trong tương lai như thế nào?',
      options: [
        AnswerOption(text: 'Hàng tuần'),
        AnswerOption(text: 'Hàng tháng'),
        AnswerOption(
          text: 'Theo từng tam cá nguyệt',
          description:
              'Tuy việc theo dõi các tam cá nguyệt cũng quan trọng nhưng mỗi tuần lại đánh dấu ít nhất một cột mốc trong quá trình phát triển của thai nhi. Sau khi có thai, bạn có thể chuyển sang chế độ theo dõi thai kỳ và nhận các mẹo hữu ích về cơ thể bạn cũng như quá trình phát triển của em bé hàng tuần.',
          isHighlighted: true,
        ),
      ],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF8BBD9), Color(0xFFE3F2FD)],
          ),
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Icon(Icons.pregnant_woman, color: Colors.pink[400], size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Chế độ mang thai',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, null),
                    child: Text(
                      'Bỏ qua',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context, null),
                    icon: Icon(Icons.close, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            // Question Content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _questions.length,
                itemBuilder: (context, index) {
                  return _buildQuestionPage(_questions[index]);
                },
              ),
            ),

            // Navigation Buttons
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  if (_currentQuestionIndex > 0)
                    Expanded(
                      child: TextButton(
                        onPressed: _previousQuestion,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        child: Text(
                          'Quay lại',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                  if (_currentQuestionIndex > 0) const SizedBox(width: 16),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: _canContinue() ? _nextQuestion : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink[400],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        disabledBackgroundColor: Colors.grey[300],
                      ),
                      child: Text(
                        _isLastQuestion() ? 'Hoàn thành' : 'Tiếp theo',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionPage(QuestionData question) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / _questions.length,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(Colors.pink[400]!),
          ),

          const SizedBox(height: 24),

          // Question
          Text(
            question.question,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
              height: 1.3,
            ),
          ),

          const SizedBox(height: 24),

          // Options
          Expanded(
            child: ListView.builder(
              itemCount: question.options.length,
              itemBuilder: (context, index) {
                final option = question.options[index];
                final isSelected = _answers[question.key] == option.text;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: option.isHighlighted && isSelected
                        ? Colors.pink[400]
                        : isSelected
                        ? Colors.pink.withOpacity(0.1)
                        : Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? Colors.pink[400]!
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: InkWell(
                    onTap: () => _selectOption(question.key, option.text),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            option.text,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: option.isHighlighted && isSelected
                                  ? Colors.white
                                  : isSelected
                                  ? Colors.pink[600]
                                  : Colors.grey[800],
                            ),
                          ),
                          if (option.description != null && isSelected) ...[
                            const SizedBox(height: 8),
                            Text(
                              option.description!,
                              style: TextStyle(
                                fontSize: 14,
                                color: option.isHighlighted
                                    ? Colors.white.withOpacity(0.9)
                                    : Colors.grey[700],
                                height: 1.4,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _selectOption(String key, String value) {
    setState(() {
      _answers[key] = value;
    });
  }

  bool _canContinue() {
    final currentQuestion = _questions[_currentQuestionIndex];
    return _answers.containsKey(currentQuestion.key);
  }

  bool _isLastQuestion() {
    return _currentQuestionIndex == _questions.length - 1;
  }

  void _nextQuestion() {
    if (_isLastQuestion()) {
      _completeQuestionnaire();
    } else {
      setState(() {
        _currentQuestionIndex++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _completeQuestionnaire() {
    final result = PregnancyQuestionnaireResult(answers: _answers);

    // In kết quả để debug
    print('Questionnaire Results:');
    _answers.forEach((key, value) {
      print('$key: $value');
    });

    Navigator.pop(context, result);

    // Hiển thị thông báo thành công
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Đã lưu thông tin chế độ mang thai'),
            backgroundColor: Colors.pink[400],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    });
  }
}
