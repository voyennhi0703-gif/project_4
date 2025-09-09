import 'package:flutter/material.dart';
import 'package:period_tracket/common/colo_extension.dart';
import 'package:period_tracket/views/data/data_manager.dart';
import 'package:period_tracket/views/home/dpregnancy_questionnaire_dialog.dart';
import 'package:provider/provider.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  // Controllers for profile editing
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  // App settings (giữ lại các phần không liên quan đến nhắc)
  // REMOVED: _notificationsEnabled, _reminderEnabled và 4 biến reminder cục bộ
  bool _darkModeEnabled = false;
  bool _pregnantModeEnabled = false;
  bool _trackPregnancyMode = false;
  bool _healthAppConnected = false;
  String _selectedLanguage = 'Tiếng Việt';
  String _currentAccessCode = '1234';

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  void _loadUserProfile() {
    _nameController.text = 'Người dùng';
    _ageController.text = '25';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataManager>(
      builder: (context, dataManager, child) {
        final r = dataManager.reminders; // NEW: truy cập trạng thái nhắc nhở

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  TColor.lightGray,
                  TColor.softPink.withValues(alpha: 0.3),
                  TColor.blushPink.withValues(alpha: 0.2),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(Icons.arrow_back_ios, color: TColor.gray),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Cài đặt',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: TColor.black,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Column(
                          children: [
                            const SizedBox(height: 10),

                            // Mode Settings
                            _buildSettingsSection(
                              title: 'Chế độ theo dõi',
                              icon: Icons.track_changes_outlined,
                              children: [
                                _buildSwitchTile(
                                  icon: Icons.pregnant_woman_outlined,
                                  title: 'Chế độ mang thai',
                                  subtitle: 'Theo dõi hành trình mang thai',
                                  value: _pregnantModeEnabled,
                                  onChanged: (value) {
                                    setState(() {
                                      _pregnantModeEnabled = value;
                                      if (value) {
                                        _trackPregnancyMode = false;
                                        _showPregnancyQuestionnaire();
                                      }
                                    });
                                    _showSnackBar(
                                      value
                                          ? 'Đã bật chế độ mang thai'
                                          : 'Đã tắt chế độ mang thai',
                                    );
                                  },
                                ),
                                _buildSwitchTile(
                                  icon: Icons.baby_changing_station_outlined,
                                  title: 'Chế độ theo dõi thai kỳ',
                                  subtitle: 'Theo dõi sức khỏe trong thai kỳ',
                                  value: _trackPregnancyMode,
                                  onChanged: (value) {
                                    setState(() {
                                      _trackPregnancyMode = value;
                                      if (value) _pregnantModeEnabled = false;
                                    });
                                    _showSnackBar(
                                      value
                                          ? 'Đã bật chế độ theo dõi thai kỳ'
                                          : 'Đã tắt chế độ theo dõi thai kỳ',
                                    );
                                  },
                                ),
                                _buildSettingsTile(
                                  icon: Icons.calendar_month_outlined,
                                  title: 'Chu kỳ và rụng trứng',
                                  subtitle:
                                      'Cài đặt thông tin chu kỳ kinh nguyệt',
                                  onTap: () => _showCycleDialog(),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // App Settings
                            _buildSettingsSection(
                              title: 'Cài đặt ứng dụng',
                              icon: Icons.settings_outlined,
                              children: [
                                _buildSwitchTile(
                                  icon: Icons.dark_mode_outlined,
                                  title: 'Chế độ tối',
                                  subtitle: 'Sử dụng giao diện tối',
                                  value: _darkModeEnabled,
                                  onChanged: (value) {
                                    setState(() => _darkModeEnabled = value);
                                    _showSnackBar(
                                      value
                                          ? 'Đã bật chế độ tối'
                                          : 'Đã tắt chế độ tối',
                                    );
                                  },
                                ),
                                _buildSwitchTile(
                                  icon: Icons.health_and_safety_outlined,
                                  title: 'Kết nối Health App',
                                  subtitle: 'Đồng bộ với ứng dụng sức khỏe',
                                  value: _healthAppConnected,
                                  onChanged: (value) {
                                    setState(() => _healthAppConnected = value);
                                    _showSnackBar(
                                      value
                                          ? 'Đã kết nối Health App'
                                          : 'Đã ngắt kết nối Health App',
                                    );
                                  },
                                ),
                                _buildSettingsTile(
                                  icon: Icons.language_outlined,
                                  title: 'Ngôn ngữ',
                                  subtitle: _selectedLanguage,
                                  onTap: () => _showLanguageDialog(),
                                ),
                                _buildSettingsTile(
                                  icon: Icons.lock_outline,
                                  title: 'Mã truy cập',
                                  subtitle: 'Thiết lập mã bảo vệ ứng dụng',
                                  onTap: () => _showAccessCodeDialog(),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // REMOVED: "Thông báo"
                            // NEW: "Nhắc nhở" với chọn giờ cho từng loại
                            _buildSettingsSection(
                              title: 'Nhắc nhở',
                              icon: Icons.alarm_outlined,
                              children: [
                                _buildReminderRow(
                                  icon: Icons.auto_awesome_outlined,
                                  title: 'Nhắc nhở thông minh',
                                  subtitle: 'Chọn giờ nhắc phù hợp thói quen',
                                  enabled: r.smartEnabled,
                                  time: r.smartTime,
                                  onToggle: (v) =>
                                      dataManager.setReminderEnabled(
                                        ReminderType.smart,
                                        v,
                                      ),
                                  onPickTime: () async {
                                    final t = await _pickTime(
                                      context,
                                      r.smartTime,
                                    );
                                    if (t != null) {
                                      await dataManager.setReminderTime(
                                        ReminderType.smart,
                                        t,
                                      );
                                      _showSnackBar('Đã đặt giờ: ${_fmt(t)}');
                                    }
                                  },
                                ),
                                _buildReminderRow(
                                  icon: Icons.calendar_today_outlined,
                                  title: 'Nhắc kỳ kinh sắp tới',
                                  subtitle:
                                      'Thông báo trước ngày dự đoán hành kinh',
                                  enabled: r.periodEnabled,
                                  time: r.periodTime,
                                  onToggle: (v) =>
                                      dataManager.setReminderEnabled(
                                        ReminderType.period,
                                        v,
                                      ),
                                  onPickTime: () async {
                                    final t = await _pickTime(
                                      context,
                                      r.periodTime,
                                    );
                                    if (t != null) {
                                      await dataManager.setReminderTime(
                                        ReminderType.period,
                                        t,
                                      );
                                      _showSnackBar('Đã đặt giờ: ${_fmt(t)}');
                                    }
                                  },
                                ),
                                _buildReminderRow(
                                  icon: Icons.egg_outlined,
                                  title: 'Nhắc ngày rụng trứng',
                                  subtitle:
                                      'Thông báo trước và trong cửa sổ rụng trứng',
                                  enabled: r.ovulationEnabled,
                                  time: r.ovulationTime,
                                  onToggle: (v) =>
                                      dataManager.setReminderEnabled(
                                        ReminderType.ovulation,
                                        v,
                                      ),
                                  onPickTime: () async {
                                    final t = await _pickTime(
                                      context,
                                      r.ovulationTime,
                                    );
                                    if (t != null) {
                                      await dataManager.setReminderTime(
                                        ReminderType.ovulation,
                                        t,
                                      );
                                      _showSnackBar('Đã đặt giờ: ${_fmt(t)}');
                                    }
                                  },
                                ),
                                _buildReminderRow(
                                  icon: Icons.medication_outlined,
                                  title: 'Nhắc uống thuốc tránh thai',
                                  subtitle:
                                      'Nhắc đúng giờ uống hằng ngày (nếu có)',
                                  enabled: r.pillEnabled,
                                  time: r.pillTime,
                                  onToggle: (v) => dataManager
                                      .setReminderEnabled(ReminderType.pill, v),
                                  onPickTime: () async {
                                    final t = await _pickTime(
                                      context,
                                      r.pillTime,
                                    );
                                    if (t != null) {
                                      await dataManager.setReminderTime(
                                        ReminderType.pill,
                                        t,
                                      );
                                      _showSnackBar('Đã đặt giờ: ${_fmt(t)}');
                                    }
                                  },
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Profile
                            _buildSettingsSection(
                              title: 'Hồ sơ',
                              icon: Icons.person_outline,
                              children: [
                                _buildSettingsTile(
                                  icon: Icons.edit_outlined,
                                  title: 'Chỉnh sửa thông tin',
                                  subtitle: 'Cập nhật tên, tuổi',
                                  onTap: () => _showEditProfileDialog(),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Help
                            _buildSettingsSection(
                              title: 'Trợ giúp',
                              icon: Icons.help_outline,
                              children: [
                                _buildSettingsTile(
                                  icon: Icons.help_outline,
                                  title: 'Trợ giúp',
                                  subtitle: 'Hướng dẫn và FAQ',
                                  onTap: () => _showHelpDialog(),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Privacy
                            _buildSettingsSection(
                              title: 'Bảo mật',
                              icon: Icons.security_outlined,
                              children: [
                                _buildSettingsTile(
                                  icon: Icons.privacy_tip_outlined,
                                  title: 'Quyền riêng tư & Bảo mật',
                                  subtitle: 'Cài đặt bảo mật',
                                  onTap: () => _showPrivacyDialog(),
                                ),
                                _buildSettingsTile(
                                  icon: Icons.policy_outlined,
                                  title: 'Chính sách bảo mật',
                                  subtitle: 'Xem chính sách',
                                  onTap: () => _showPolicyDialog(),
                                ),
                                _buildSettingsTile(
                                  icon: Icons.description_outlined,
                                  title: 'Điều khoản sử dụng',
                                  subtitle: 'Xem điều khoản',
                                  onTap: () => _showTermsDialog(),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Data Management
                            _buildSettingsSection(
                              title: 'Quản lý dữ liệu',
                              icon: Icons.storage_outlined,
                              children: [
                                _buildSettingsTile(
                                  icon: Icons.backup_outlined,
                                  title: 'Sao lưu dữ liệu',
                                  subtitle: 'Sao lưu lên cloud',
                                  onTap: () => _showBackupDialog(),
                                ),
                                _buildSettingsTile(
                                  icon: Icons.restore_outlined,
                                  title: 'Khôi phục dữ liệu',
                                  subtitle: 'Khôi phục từ bản sao',
                                  onTap: () => _showRestoreDialog(),
                                ),
                                _buildSettingsTile(
                                  icon: Icons.refresh_outlined,
                                  title: 'Đặt lại dữ liệu',
                                  subtitle: 'Xóa tất cả dữ liệu',
                                  onTap: () =>
                                      _showResetDataDialog(dataManager),
                                  isDestructive: true,
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Logout
                            _buildSettingsSection(
                              title: 'Tài khoản',
                              icon: Icons.logout_outlined,
                              children: [
                                _buildSettingsTile(
                                  icon: Icons.logout_outlined,
                                  title: 'Đăng xuất',
                                  subtitle: 'Thoát khỏi tài khoản',
                                  onTap: () => _showLogoutDialog(),
                                ),
                              ],
                            ),

                            const SizedBox(height: 40),

                            // App Info
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: TColor.white.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'Period Tracker',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: TColor.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Phiên bản 1.0.0',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: TColor.gray,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ===== Helpers chung =====
  Widget _buildSettingsSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
    bool isDestructive = false,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: TColor.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: TColor.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isDestructive ? Colors.red[600] : TColor.rosePink,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDestructive ? Colors.red[600] : TColor.black,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDestructive
                      ? Colors.red.withValues(alpha: 0.1)
                      : TColor.rosePink.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: isDestructive ? Colors.red[600] : TColor.rosePink,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDestructive ? Colors.red[600] : TColor.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: TColor.gray),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: TColor.gray),
            ],
          ),
        ),
      ),
    );
  }

  /// Switch tile mặc định
  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool enabled = true,
  }) {
    final tileOpacity = enabled ? 1.0 : 0.5;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Opacity(
            opacity: tileOpacity,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: TColor.rosePink.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: TColor.rosePink),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Opacity(
              opacity: tileOpacity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: TColor.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: TColor.gray),
                  ),
                ],
              ),
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: enabled ? onChanged : null,
            activeColor: TColor.rosePink,
          ),
        ],
      ),
    );
  }

  // ===== NEW: Dòng nhắc nhở có nút chọn giờ
  Widget _buildReminderRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool enabled,
    required TimeOfDay? time,
    required ValueChanged<bool> onToggle,
    required VoidCallback onPickTime,
  }) {
    final timeLabel = time != null ? _fmt(time) : 'Chọn giờ';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: TColor.rosePink.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: TColor.rosePink),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Opacity(
              opacity: enabled ? 1 : 0.55,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: TColor.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: TColor.gray),
                  ),
                ],
              ),
            ),
          ),
          TextButton.icon(
            onPressed: enabled ? onPickTime : null,
            icon: const Icon(Icons.schedule, size: 18),
            label: Text(timeLabel),
            style: TextButton.styleFrom(
              foregroundColor: enabled ? TColor.rosePink : TColor.gray,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Switch.adaptive(
            value: enabled,
            onChanged: (v) async => onToggle(v),
            activeColor: TColor.rosePink,
          ),
        ],
      ),
    );
  }

  // ===== NEW: chọn giờ (Material picker). Có thể đổi sang Cupertino nếu muốn
  Future<TimeOfDay?> _pickTime(BuildContext context, TimeOfDay? initial) async {
    final now = TimeOfDay.now();
    return showTimePicker(
      context: context,
      initialTime: initial ?? TimeOfDay(hour: now.hour, minute: 0),
      builder: (ctx, child) => child!,
    );
  }

  String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  // ====== Dialogs & helpers khác giữ nguyên ======
  void _showSnackBar(String message, {Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color ?? TColor.rosePink,
      ),
    );
  }

  void _showCycleDialog() {
    /* giữ nguyên như bản của bạn */
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cài đặt chu kỳ'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Độ dài chu kỳ'),
              subtitle: Text('28 ngày'),
              trailing: Icon(Icons.edit),
            ),
            ListTile(
              title: Text('Thời gian kinh nguyệt'),
              subtitle: Text('5 ngày'),
              trailing: Icon(Icons.edit),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    /* giữ nguyên */
    final languages = ['Tiếng Việt', 'English', '中文', '日本語'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn ngôn ngữ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages
              .map(
                (lang) => ListTile(
                  title: Text(lang),
                  onTap: () {
                    setState(() => _selectedLanguage = lang);
                    Navigator.pop(context);
                    _showSnackBar('Đã chọn ngôn ngữ: $lang');
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  void _showAccessCodeDialog() {
    /* giữ nguyên */
    final controller = TextEditingController(text: _currentAccessCode);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mã truy cập'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          maxLength: 4,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Nhập mã 4 chữ số',
            border: OutlineInputBorder(),
            counterText: '',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.length == 4) {
                setState(() => _currentAccessCode = controller.text);
                Navigator.pop(context);
                _showSnackBar('Đã cập nhật mã truy cập');
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog() {
    /* giữ nguyên như bản của bạn */
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chỉnh sửa hồ sơ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Tên',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Tuổi',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar('Đã cập nhật thông tin');
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    /* giữ nguyên */
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Trợ giúp'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.help_outline),
              title: Text('Hướng dẫn sử dụng'),
            ),
            ListTile(
              leading: Icon(Icons.question_answer),
              title: Text('Câu hỏi thường gặp'),
            ),
            ListTile(
              leading: Icon(Icons.contact_support),
              title: Text('Liên hệ hỗ trợ'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    /* giữ nguyên */
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bảo mật'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.fingerprint),
              title: Text('Xác thực sinh trắc học'),
            ),
            ListTile(leading: Icon(Icons.lock), title: Text('Khóa tự động')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showPolicyDialog() {
    /* giữ nguyên */
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chính sách bảo mật'),
        content: const Text('Đây là nội dung chính sách bảo mật...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog() {
    /* giữ nguyên */
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Điều khoản sử dụng'),
        content: const Text('Đây là nội dung điều khoản sử dụng...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showBackupDialog() {
    /* giữ nguyên */
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sao lưu dữ liệu'),
        content: const Text('Chức năng sao lưu đang được phát triển.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showRestoreDialog() {
    /* giữ nguyên */
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Khôi phục dữ liệu'),
        content: const Text('Chức năng khôi phục đang được phát triển.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showResetDataDialog(DataManager dataManager) {
    /* giữ nguyên */
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đặt lại dữ liệu'),
        content: const Text('Bạn có chắc muốn xóa tất cả dữ liệu?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              dataManager.reset();
              Navigator.pop(context);
              _showSnackBar('Đã đặt lại dữ liệu', color: Colors.orange);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Đặt lại'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    /* giữ nguyên */
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/login', (route) => false);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }

  void _showPregnancyQuestionnaire() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PregnancyQuestionnaireDialog(),
    );
  }
}
