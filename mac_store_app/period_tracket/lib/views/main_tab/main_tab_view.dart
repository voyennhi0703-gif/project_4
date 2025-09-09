import 'package:flutter/material.dart';
import 'package:period_tracket/common/colo_extension.dart';
import 'package:period_tracket/common_widget/tab_button.dart';
import 'package:period_tracket/views/analytics/analytics_view.dart';
import 'package:period_tracket/views/calendar/calendar_view.dart';
import 'package:period_tracket/views/care/care_view.dart';
import 'package:period_tracket/views/home/home_view.dart';

class MainTabView extends StatefulWidget {
  const MainTabView({super.key});

  @override
  State<MainTabView> createState() => _MainTabViewState();
}

class _MainTabViewState extends State<MainTabView> {
  int selectTab = 0;
  final PageStorageBucket pageBucket = PageStorageBucket();

  // Tạo danh sách các tab để dễ quản lý
  late List<Widget> tabWidgets;

  @override
  void initState() {
    super.initState();
    tabWidgets = [
      const HomeView(),
      const CalendarView(),
      const CareView(),
      const AnalyticsView(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.white,
      body: PageStorage(bucket: pageBucket, child: tabWidgets[selectTab]),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: TColor.white,
          boxShadow: [
            BoxShadow(
              color: TColor.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              children: [
                // Tab: Hôm nay
                Expanded(
                  child: TabButton(
                    icon: "assets/img/home_tab.png",
                    selectIcon: "assets/img/home_tab_select.png",
                    label: "Hôm nay",
                    isActive: selectTab == 0,
                    onTap: () {
                      setState(() {
                        selectTab = 0;
                      });
                    },
                  ),
                ),

                // Tab: Lịch
                Expanded(
                  child: TabButton(
                    icon: "assets/img/calendar_tab.png",
                    selectIcon: "assets/img/calendar_tab_select.png",
                    label: "Lịch",
                    isActive: selectTab == 1,
                    onTap: () {
                      setState(() {
                        selectTab = 1;
                      });
                    },
                  ),
                ),

                // Tab: Chăm sóc
                Expanded(
                  child: TabButton(
                    icon: "assets/img/care_tab.png",
                    selectIcon: "assets/img/care_tab_select.png",
                    label: "Chăm sóc",
                    isActive: selectTab == 2,
                    onTap: () {
                      setState(() {
                        selectTab = 2;
                      });
                    },
                  ),
                ),

                // Tab: Phân tích
                Expanded(
                  child: TabButton(
                    icon: "assets/img/analytics_tab.png",
                    selectIcon: "assets/img/analytics_tab_select.png",
                    label: "Phân tích",
                    isActive: selectTab == 3,
                    onTap: () {
                      setState(() {
                        selectTab = 3;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
