import 'package:flutter/material.dart';
import 'package:period_tracket/common/colo_extension.dart';

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
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Icon(
              _getIconData(),
              size: 22,
              color: isActive ? TColor.rosePink : TColor.gray,
            ),
            const SizedBox(height: 2),
            // Label text
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: isActive ? TColor.rosePink : TColor.gray,
              ),
            ),
            const SizedBox(height: 1),
            // Active indicator dot
            if (isActive)
              Container(
                width: 3,
                height: 3,
                decoration: BoxDecoration(
                  color: TColor.rosePink,
                  shape: BoxShape.circle,
                ),
              )
            else
              const SizedBox(height: 3),
          ],
        ),
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
