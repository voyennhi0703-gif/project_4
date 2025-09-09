import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EndDatePage extends StatefulWidget {
  final Map<String, dynamic> formData;
  final Function(int) onSave;

  const EndDatePage({Key? key, required this.formData, required this.onSave})
    : super(key: key);

  @override
  State<EndDatePage> createState() => _EndDatePageState();
}

class _EndDatePageState extends State<EndDatePage> {
  int selectedEnd = 28;
  late FixedExtentScrollController durationController;

  // Duration options từ 21 đến 35 ngày (chu kỳ kinh)
  final List<int> durationOptions = List.generate(60, (index) => index + 1);

  @override
  void initState() {
    super.initState();
    selectedEnd = widget.formData['cycleLength'] ?? 28;

    // Initialize controller với vị trí được chọn
    // Tìm index của selectedEnd trong durationOptions
    int initialIndex = durationOptions.indexOf(selectedEnd);
    if (initialIndex == -1) initialIndex = 7; // default to 28 days (index 7)

    durationController = FixedExtentScrollController(initialItem: initialIndex);
  }

  @override
  void dispose() {
    durationController.dispose();
    super.dispose();
  }

  void handleSave() {
    widget.onSave(selectedEnd);
    Navigator.of(context).pop();
  }

  void handleCancel() {
    Navigator.of(context).pop();
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
                    'Chu kỳ kinh',
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
                      'Chu kỳ của bạn thường kéo dài bao nhiêu ngày?',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Khoảng thời gian từ ngày bắt đầu hai chu kỳ, thường là 21-35 ngày',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 40),

                    // iOS-style duration picker
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
                        child: CupertinoPicker(
                          scrollController: durationController,
                          itemExtent: 40,
                          onSelectedItemChanged: (index) {
                            setState(() {
                              selectedEnd = durationOptions[index];
                            });
                          },
                          selectionOverlay: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF007AFF).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFF007AFF).withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                          ),
                          children: durationOptions
                              .map(
                                (days) => Center(
                                  child: Text(
                                    '$days',
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
                    ),

                    const SizedBox(height: 20),

                    // Selected duration display
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
                      child: Text(
                        '$selectedEnd ngày',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
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
