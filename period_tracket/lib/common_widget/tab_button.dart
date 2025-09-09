import 'package:flutter/material.dart';

class TabButton extends StatelessWidget {
  final String icon;
  final String selectIcon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  const TabButton({
    super.key,
    required this.icon,
    required this.selectIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon - you can replace with actual icons if needed
          Icon(
            _getIconData(),
            size: 25,
            color: isActive ? const Color(0xFFFF4081) : Colors.grey[600],
          ),
          const SizedBox(height: 4),
          // Label text
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              color: isActive ? const Color(0xFFFF4081) : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          // Active indicator dot
          if (isActive)
            Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: Color(0xFFFF4081),
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  IconData _getIconData() {
    // Map labels to appropriate icons
    switch (label) {
      case 'Hôm nay':
        return Icons.home_outlined;
      case 'Lịch':
        return Icons.calendar_today_outlined;
      case 'Chăm sóc':
        return Icons.favorite_outline;
      case 'Phân tích':
        return Icons.bar_chart_outlined;
      default:
        return Icons.home_outlined;
    }
  }
}
