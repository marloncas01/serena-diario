import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/journal_entry.dart';
import '../../services/user_profile.dart';
import '../../theme/brand/brand_radius.dart';
import '../../theme/brand/brand_spacing.dart';

import '../../utils/journal_insights.dart';
import '../../widgets/glass_card.dart';

class HeroHeaderPremium extends StatelessWidget {
  const HeroHeaderPremium({
    super.key,
    required this.entries,
    required this.profile,
  });

  final List<JournalEntry> entries;
  final UserProfile profile;

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Buenos días';
    if (hour < 19) return 'Buenas tardes';
    return 'Buenas noches';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final streak = JournalInsights.streak(entries);
    final mood = JournalInsights.predominantMood(entries);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isWide = screenWidth > 600;

    return GlassCard(
      padding: EdgeInsets.all(isWide ? BrandSpacing.xxl : BrandSpacing.xl),
      gradient: LinearGradient(
        colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary],
      ),
      elevation: true,
      borderColor: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: isWide ? 56 : 48,
                height: isWide ? 56 : 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(BrandRadius.lg),
                ),
                child: Center(
                  child: Text(
                    profile.avatar,
                    style: TextStyle(fontSize: isWide ? 30 : 26),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_greeting()}, ${profile.greetingName}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isWide ? 22 : 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat("EEEE, d 'de' MMMM", 'es_ES')
                          .format(DateTime.now()),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: BrandSpacing.lg),
          Row(
            children: [
              _StatChip(
                icon: Icons.local_fire_department_rounded,
                value: '$streak',
                label: 'racha',
              ),
              const SizedBox(width: BrandSpacing.sm),
              _StatChip(
                icon: Icons.menu_book_rounded,
                value: '${entries.length}',
                label: 'entradas',
              ),
              const SizedBox(width: BrandSpacing.sm),
              _StatChip(
                icon: Icons.emoji_emotions_outlined,
                value: mood.name,
                label: 'predominante',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(BrandRadius.sm),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 14),
            const SizedBox(width: 4),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 10,
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
}
