import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:period_tracket/views/data/data_manager.dart'; // ← THÊM IMPORT
import 'package:provider/provider.dart'; // ← THÊM IMPORT

import 'duration_page.dart';
import 'end_date_page.dart';
import 'start_date_page.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({Key? key}) : super(key: key);

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  // Form data to store user selections
  Map<String, dynamic> formData = {
    'startDate': null,
    'endDate': null,
    'duration': null,
  };

  void updateFormData(String key, dynamic value) {
    setState(() {
      formData[key] = value;
    });
  }

  bool get isFormComplete {
    return formData['startDate'] != null &&
        formData['endDate'] != null &&
        formData['duration'] != null;
  }

  void navigateToPage(String pageType) {
    Widget page;

    switch (pageType) {
      case 'startDate':
        page = StartDatePage(
          formData: formData,
          onSave: (value) => updateFormData('startDate', value),
        );
        break;
      case 'endDate':
        page = EndDatePage(
          formData: formData,
          onSave: (value) => updateFormData('endDate', value),
        );
        break;
      case 'duration':
        page = DurationPage(
          formData: formData,
          onSave: (value) => updateFormData('duration', value),
        );
        break;
      default:
        return;
    }

    Navigator.of(context).push(MaterialPageRoute(builder: (context) => page));
  }

  void completeOnboarding() {
    // Handle completion logic here
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (context) => CupertinoAlertDialog(
        title: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFF34C759),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 30),
            ),
            const SizedBox(height: 16),
            const Text(
              'Setup Complete!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
        content: const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Text(
            'Your menstrual cycle information has been saved successfully.\n\nWould you like to go to the home page to start tracking your cycle?',
            style: TextStyle(fontSize: 16, color: Colors.black87, height: 1.4),
            textAlign: TextAlign.center,
          ),
        ),
        actions: [
          // Cancel button
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Edit Again',
              style: TextStyle(
                fontSize: 17,
                color: Color(0xFF007AFF),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          // OK button - Navigate to home
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              // Save data to DataManager
              _saveDataPermanently();

              // Close dialog first
              Navigator.of(context).pop();

              // Navigate to home view and remove all previous routes
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/home', // You need to define this route in your main.dart
                (Route<dynamic> route) => false,
              );
            },
            child: const Text(
              'Go to Home',
              style: TextStyle(
                fontSize: 17,
                color: Color(0xFF007AFF),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Method to save data permanently (you can implement this based on your storage solution)
  Future<void> _saveDataPermanently() async {
    // Save to DataManager using Provider
    final dataManager = Provider.of<DataManager>(context, listen: false);

    // Convert form data to proper format
    Map<String, dynamic> userData = {
      'startDate': formData['startDate']?.toString(),
      'cycleDuration': formData['endDate'], // This should be cycle duration
      'periodDuration': formData['duration'], // This should be period duration
    };

    // Initialize DataManager with onboarding data
    dataManager.initializeFromOnboarding(userData);

    // Optional: Save to SharedPreferences for persistence
    // await dataManager.saveToStorage();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final availableHeight =
        screenHeight -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: availableHeight),
            child: Column(
              children: [
                // Main content area
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // Illustration - Responsive size
                      Container(
                        width: MediaQuery.of(context).size.width * 0.6,
                        height: MediaQuery.of(context).size.width * 0.45,
                        constraints: const BoxConstraints(
                          maxWidth: 256,
                          maxHeight: 192,
                        ),
                        margin: const EdgeInsets.only(bottom: 24),
                        child: Stack(
                          children: [
                            // Main circle
                            Center(
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFCDD2),
                                  borderRadius: BorderRadius.circular(60),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(60),
                                  child: Image.asset(
                                    'assets/img/logo.png',
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            // Decorative elements
                            Positioned(
                              top: 8,
                              right: 24,
                              child: Container(
                                width: 40,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF9AAD),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 24,
                              left: 24,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF7A9A),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 36,
                              left: 36,
                              child: Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF8A9B),
                                  borderRadius: BorderRadius.circular(7),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Title
                      const Text(
                        'Thiết lập chu kỳ kinh nguyệt',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          height: 1.3,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 28),

                      // Navigation buttons
                      Column(
                        children: [
                          // Start Date Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => navigateToPage('startDate'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: formData['startDate'] != null
                                    ? const Color(0xFFFF6B7A)
                                    : const Color(0xFFFF9AAD),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 2,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Expanded(
                                    child: Text(
                                      'Ngày bắt đầu chu kỳ kinh',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  if (formData['startDate'] != null)
                                    const Icon(Icons.check, size: 20),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // End Date Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => navigateToPage('endDate'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: formData['endDate'] != null
                                    ? const Color(0xFFFF6B7A)
                                    : const Color(0xFFFF7A9A),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 2,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Expanded(
                                    child: Text(
                                      'Thời gian kéo dài chu kỳ',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  if (formData['endDate'] != null)
                                    const Icon(Icons.check, size: 20),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Duration Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => navigateToPage('duration'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: formData['duration'] != null
                                    ? const Color(0xFFFF6B7A)
                                    : const Color(0xFFFFADB7),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 2,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Expanded(
                                    child: Text(
                                      'Thời gian kéo dài kỳ kinh',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  if (formData['duration'] != null)
                                    const Icon(Icons.check, size: 20),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),

                // Summary section
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0F3),
                    border: Border(
                      top: BorderSide(color: const Color(0xFFFFCDD2)),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Thông tin đã nhập:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Summary items
                      _buildSummaryItem(
                        'Ngày bắt đầu:',
                        formData['startDate']?.toString() ?? 'Chưa chọn',
                        formData['startDate'] != null,
                      ),
                      const SizedBox(height: 8),
                      _buildSummaryItem(
                        'Ngày kết thúc:',
                        formData['endDate']?.toString() ?? 'Chưa chọn',
                        formData['endDate'] != null,
                      ),
                      const SizedBox(height: 8),
                      _buildSummaryItem(
                        'Thời gian kéo dài:',
                        formData['duration'] != null
                            ? '${formData['duration']} ngày'
                            : 'Chưa chọn',
                        formData['duration'] != null,
                      ),

                      // Complete button
                      if (isFormComplete) ...[
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: completeOnboarding,
                            icon: const Icon(Icons.check, size: 20),
                            label: const Text(
                              'Hoàn thành thiết lập',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF6B7A),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 3,
                            ),
                          ),
                        ),
                      ] else ...[
                        const SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE1E6),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFFCDD2)),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: const Color(0xFFFF7A9A),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Vui lòng hoàn thành tất cả thông tin để tiếp tục',
                                  style: TextStyle(
                                    color: const Color(0xFFFF6B7A),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Add some bottom padding for better spacing
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, bool isCompleted) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ),
        Expanded(
          flex: 3,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isCompleted
                        ? const Color(0xFFFF6B7A)
                        : Colors.grey[500],
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
              const SizedBox(width: 8),
              if (isCompleted)
                Icon(
                  Icons.check_circle,
                  size: 16,
                  color: const Color(0xFFFF9AAD),
                )
              else
                Icon(
                  Icons.radio_button_unchecked,
                  size: 16,
                  color: Colors.grey[400],
                ),
            ],
          ),
        ),
      ],
    );
  }
}
