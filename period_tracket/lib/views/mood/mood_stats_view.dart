// views/mood_stats_view.dart - Trang thống kê mood chi tiết

import 'package:flutter/material.dart';
import 'package:period_tracket/models/mood_data.dart';
import 'package:period_tracket/services/mood_service.dart';

class MoodStatsView extends StatefulWidget {
  const MoodStatsView({Key? key}) : super(key: key);

  @override
  State<MoodStatsView> createState() => _MoodStatsViewState();
}

class _MoodStatsViewState extends State<MoodStatsView>
    with SingleTickerProviderStateMixin {
  // Dữ liệu thống kê
  Map<String, int> moodStats = {};
  Map<String, int> symptomStats = {};
  List<Map<String, dynamic>> weeklyTrend = [];
  List<Map<String, dynamic>> monthlyTrend = [];
  List<MoodData> recentMoods = [];

  // UI state
  bool isLoading = true;
  int selectedTabIndex = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAllStats();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Tải tất cả dữ liệu thống kê
  Future<void> _loadAllStats() async {
    setState(() => isLoading = true);

    try {
      final stats = await MoodService.getMoodStatistics();
      final symptomStatistics = await MoodService.getSymptomStatistics();
      final weeklyData = await MoodService.getWeeklyMoodTrend();
      final monthlyData = await MoodService.getMonthlyMoodTrend();
      final recent = await MoodService.getRecentMoods(7); // 7 ngày gần nhất

      setState(() {
        moodStats = stats;
        symptomStats = symptomStatistics;
        weeklyTrend = weeklyData;
        monthlyTrend = monthlyData;
        recentMoods = recent;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      _showError('Không thể tải dữ liệu thống kê: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Thống kê tâm trạng',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFFFF4081),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFFFF4081),
              indicatorWeight: 3,
              tabs: const [
                Tab(text: 'Tổng quan'),
                Tab(text: 'Xu hướng'),
                Tab(text: 'Chi tiết'),
              ],
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildTrendTab(),
                _buildDetailTab(),
              ],
            ),
    );
  }

  // Tab 1: Tổng quan
  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thống kê tổng quan
          _buildOverviewCards(),

          const SizedBox(height: 24),

          // Tâm trạng phổ biến nhất
          const Text(
            'Tâm trạng phổ biến',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildTopMoods(),

          const SizedBox(height: 24),

          // Triệu chứng thường gặp
          const Text(
            'Triệu chứng thường gặp',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildTopSymptoms(),
        ],
      ),
    );
  }

  // Tab 2: Xu hướng
  Widget _buildTrendTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Xu hướng tuần
          const Text(
            'Xu hướng 7 ngày qua',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildWeeklyChart(),

          const SizedBox(height: 32),

          // Xu hướng tháng
          const Text(
            'Xu hướng tháng này',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildMonthlyChart(),

          const SizedBox(height: 32),

          // Phân tích xu hướng
          _buildTrendAnalysis(),
        ],
      ),
    );
  }

  // Tab 3: Chi tiết
  Widget _buildDetailTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Lịch sử gần đây
          const Text(
            'Hoạt động gần đây',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildRecentActivity(),

          const SizedBox(height: 24),

          // Thống kê theo chu kỳ
          const Text(
            'Thống kê theo chu kỳ kinh nguyệt',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildCycleStats(),
        ],
      ),
    );
  }

  // Các thẻ thống kê tổng quan
  Widget _buildOverviewCards() {
    final totalEntries = recentMoods.length;
    final totalMoods = moodStats.values.fold(0, (sum, count) => sum + count);
    final totalSymptoms = symptomStats.values.fold(
      0,
      (sum, count) => sum + count,
    );
    final avgMoodsPerDay = totalEntries > 0
        ? (totalMoods / totalEntries).toStringAsFixed(1)
        : '0';

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Ngày theo dõi',
            value: totalEntries.toString(),
            icon: Icons.calendar_today,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'Tâm trạng/ngày',
            value: avgMoodsPerDay,
            icon: Icons.mood,
            color: Colors.pink,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'Triệu chứng',
            value: totalSymptoms.toString(),
            icon: Icons.health_and_safety,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Top 5 tâm trạng phổ biến
  Widget _buildTopMoods() {
    if (moodStats.isEmpty) {
      return _buildEmptyState('Chưa có dữ liệu tâm trạng');
    }

    final sortedMoods = moodStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: sortedMoods.take(5).map((entry) {
        final total = moodStats.values.fold(0, (sum, count) => sum + count);
        final percentage = ((entry.value / total) * 100).round();

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Progress bar
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: _getMoodColor(entry.key),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 16),

              // Mood info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${entry.value} lần • $percentage%',
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),

              // Count badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getMoodColor(entry.key).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${entry.value}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getMoodColor(entry.key),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // Top triệu chứng
  Widget _buildTopSymptoms() {
    if (symptomStats.isEmpty) {
      return _buildEmptyState('Chưa có dữ liệu triệu chứng');
    }

    final sortedSymptoms = symptomStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: sortedSymptoms.take(3).map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.health_and_safety,
                    color: Colors.purple,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    entry.key,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                Text(
                  '${entry.value}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // Biểu đồ xu hướng tuần
  Widget _buildWeeklyChart() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Số lượng tâm trạng theo ngày',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: weeklyTrend.map((day) {
                final dayNames = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
                final dayName = dayNames[(day['date'] as DateTime).weekday % 7];
                final moodCount = day['moodCount'] as int;
                final maxCount = weeklyTrend.fold(
                  0,
                  (max, d) => (d['moodCount'] as int) > max
                      ? d['moodCount'] as int
                      : max,
                );
                final height = maxCount > 0
                    ? (moodCount / maxCount * 120)
                    : 8.0;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      moodCount.toString(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 800),
                      width: 24,
                      height: height,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: day['hasData']
                              ? [Colors.pink[300]!, Colors.pink[500]!]
                              : [Colors.grey[300]!, Colors.grey[400]!],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      dayName,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // Biểu đồ xu hướng tháng
  Widget _buildMonthlyChart() {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Hoạt động tháng này',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              children: monthlyTrend.map((week) {
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: week['hasActivity']
                          ? Colors.green.withOpacity(0.7)
                          : Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        'T${week['week']}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // Phân tích xu hướng
  Widget _buildTrendAnalysis() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[50]!, Colors.indigo[50]!],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: Colors.blue[600]),
              const SizedBox(width: 8),
              const Text(
                'Phân tích xu hướng',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildAnalysisPoint(
            '📈',
            'Bạn có xu hướng ghi nhận tâm trạng thường xuyên hơn vào cuối tuần',
          ),
          const SizedBox(height: 8),
          _buildAnalysisPoint(
            '😊',
            'Tâm trạng tích cực chiếm ${_getPositiveMoodPercentage()}% tổng số lần ghi nhận',
          ),
          const SizedBox(height: 8),
          _buildAnalysisPoint(
            '📅',
            'Bạn đã theo dõi tâm trạng được ${recentMoods.length} ngày gần đây',
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisPoint(String emoji, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
      ],
    );
  }

  // Hoạt động gần đây
  Widget _buildRecentActivity() {
    if (recentMoods.isEmpty) {
      return _buildEmptyState('Chưa có hoạt động nào');
    }

    return Column(
      children: recentMoods.map((mood) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDate(mood.date),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Ngày ${mood.cycleDay}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),

              if (mood.selectedMoods.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: mood.selectedMoods
                      .map(
                        (moodName) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.pink.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            moodName,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.pink,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],

              if (mood.note != null) ...[
                const SizedBox(height: 8),
                Text(
                  mood.note!,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  // Thống kê theo chu kỳ
  Widget _buildCycleStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Column(
        children: [
          Text(
            'Tính năng đang phát triển',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Thống kê tâm trạng theo từng giai đoạn của chu kỳ kinh nguyệt sẽ sớm có mặt',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // Widget trạng thái trống
  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.mood_bad, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  Color _getMoodColor(String mood) {
    final colorMap = {
      'Vui vẻ': Colors.yellow,
      'Bình tĩnh': Colors.blue,
      'Buồn': Colors.indigo,
      'Lo lắng': Colors.orange,
      'Bực bội': Colors.red,
      'Mạnh mẽ': Colors.green,
    };
    return colorMap[mood] ?? Colors.grey;
  }

  String _formatDate(DateTime date) {
    final days = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
    final dayName = days[date.weekday % 7];
    return '$dayName, ${date.day}/${date.month}';
  }

  int _getPositiveMoodPercentage() {
    final positiveMoods = ['Vui vẻ', 'Bình tĩnh', 'Mạnh mẽ', 'Phấn chấn'];
    final positiveCount = moodStats.entries
        .where((entry) => positiveMoods.contains(entry.key))
        .fold(0, (sum, entry) => sum + entry.value);
    final totalCount = moodStats.values.fold(0, (sum, count) => sum + count);

    return totalCount > 0 ? ((positiveCount / totalCount) * 100).round() : 0;
  }
}
