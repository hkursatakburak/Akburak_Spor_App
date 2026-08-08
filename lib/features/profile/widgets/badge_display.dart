import 'package:flutter/material.dart';

class InstructorBadgeWidget extends StatelessWidget {
  final String level; // "Bronze" | "Silver" | "Gold"
  final double fontSize;
  final EdgeInsets padding;

  const InstructorBadgeWidget({
    super.key,
    required this.level,
    this.fontSize = 10,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  });

  @override
  Widget build(BuildContext context) {
    LinearGradient gradient;
    Color borderColor;
    String label;
    IconData icon;

    switch (level.toLowerCase()) {
      case 'gold':
        gradient = const LinearGradient(
          colors: [
            Color(0xFFFFE082),
            Color(0xFFFFB300),
            Color(0xFFFFA000),
            Color(0xFFFFD54F),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        borderColor = const Color(0xFFFFB300);
        label = "GOLD ANTRENÖR";
        icon = Icons.star;
        break;
      case 'silver':
        gradient = const LinearGradient(
          colors: [
            Color(0xFFE0E0E0),
            Color(0xFFBDBDBD),
            Color(0xFF9E9E9E),
            Color(0xFFEEEEEE),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        borderColor = const Color(0xFFBDBDBD);
        label = "SILVER ANTRENÖR";
        icon = Icons.workspace_premium;
        break;
      case 'bronze':
      default:
        gradient = const LinearGradient(
          colors: [
            Color(0xFFA1887F),
            Color(0xFF8D6E63),
            Color(0xFF795548),
            Color(0xFFBCAAA4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        borderColor = const Color(0xFF8D6E63);
        label = "BRONZE ANTRENÖR";
        icon = Icons.shield;
        break;
    }

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor.withOpacity(0.5), width: 1),
        boxShadow: [
          BoxShadow(
            color: borderColor.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: fontSize + 2, color: Colors.black87),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.black87,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// User badge widget to show in profile screen
class UserBadgeCard extends StatelessWidget {
  final String name;
  final String description;
  final String? dateEarned;
  final String level; // "Bronze" | "Silver" | "Gold"

  const UserBadgeCard({
    super.key,
    required this.name,
    required this.description,
    this.dateEarned,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    LinearGradient gradient;
    Color accentColor;

    switch (level.toLowerCase()) {
      case 'gold':
        gradient = const LinearGradient(
          colors: [Color(0xFFFFF8E1), Color(0xFFFFECB3), Color(0xFFFFD54F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        accentColor = const Color(0xFFFFB300);
        break;
      case 'silver':
        gradient = const LinearGradient(
          colors: [Color(0xFFFAFAFA), Color(0xFFF5F5F5), Color(0xFFE0E0E0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        accentColor = const Color(0xFF9E9E9E);
        break;
      case 'bronze':
      default:
        gradient = const LinearGradient(
          colors: [Color(0xFFEFEBE9), Color(0xFFD7CCC8), Color(0xFFBCAAA4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        accentColor = const Color(0xFF8D6E63);
        break;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: gradient,
              shape: BoxShape.circle,
              border: Border.all(color: accentColor, width: 2),
            ),
            child: Icon(
              level.toLowerCase() == 'gold'
                  ? Icons.emoji_events
                  : level.toLowerCase() == 'silver'
                      ? Icons.workspace_premium
                      : Icons.military_tech,
              size: 28,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(color: Colors.grey[600], fontSize: 10),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
