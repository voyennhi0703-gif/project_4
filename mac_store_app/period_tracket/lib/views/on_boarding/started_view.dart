import 'package:flutter/material.dart';
import 'package:period_tracket/common/colo_extension.dart';

class StartedView extends StatefulWidget {
  const StartedView({super.key});

  @override
  State<StartedView> createState() => _StartedViewState();
}

class _StartedViewState extends State<StartedView> {
  @override
  void initState() {
    super.initState();
    // Chờ 6 giây rồi chuyển sang OnboardingFlow bằng named route
    Future.delayed(const Duration(seconds: 4), () {
      // Check if widget is still mounted before navigating
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/onboarding');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: TColor.white,
      body: Container(
        width: media.width,
        height: media.height, // Đảm bảo chiều cao đầy đủ
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: TColor.primaryG,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    media.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Thêm khoảng trống phía trên
                      SizedBox(height: media.height * 0.1),

                      // App Logo/Icon
                      Container(
                        width: 120,
                        height: 120,
                        margin: const EdgeInsets.only(bottom: 30),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(60),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
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

                      // App Title
                      Text(
                        "Period Tracker",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: TColor.white,
                          fontSize: 38,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          height: 1.2,
                        ),
                      ), 

                      const SizedBox(height: 16),

                      // Subtitle
                      Text(
                        "Theo dõi chu kỳ thông minh",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: TColor.white.withOpacity(0.8),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.5,
                        ),
                      ),

                      // Thêm không gian linh hoạt
                      SizedBox(height: media.height * 0.08),

                      // Loading indicator
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            TColor.white,
                          ),
                          strokeWidth: 3,
                        ),
                      ),

                      const SizedBox(height: 20),

                      Text(
                        "Đang khởi tạo...",
                        style: TextStyle(
                          color: TColor.white.withOpacity(0.7),
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                        ),
                      ),

                      // Thêm không gian linh hoạt để đẩy phần skip button và version xuống dưới
                      const Spacer(),

                      // Skip button - giờ nằm trong Column thay vì Positioned
                      Container(
                        width: double.infinity,
                        alignment: Alignment.centerRight,
                        margin: const EdgeInsets.only(right: 10, bottom: 20),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushReplacementNamed(
                              context,
                              '/onboarding',
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              "Bỏ qua",
                              style: TextStyle(
                                color: TColor.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Version info
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
