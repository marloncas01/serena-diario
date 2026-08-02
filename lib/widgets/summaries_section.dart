import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/journal_summary_service.dart';
import '../theme/brand/brand_durations.dart';
import '../theme/brand/brand_spacing.dart';
import 'glass_card.dart';
import 'monthly_summary_card.dart';
import 'weekly_summary_card.dart';

enum _SummaryTab { week, month }

/// Sección premium que agrupa los resúmenes semanal y mensual generados
/// automáticamente, con un conmutador Semana / Mes.
class SummariesSection extends StatefulWidget {
  const SummariesSection({
    super.key,
    required this.weekly,
    required this.monthly,
  });

  final WeeklySummary weekly;
  final MonthlySummary monthly;

  @override
  State<SummariesSection> createState() => _SummariesSectionState();
}

class _SummariesSectionState extends State<SummariesSection> {
  _SummaryTab _tab = _SummaryTab.week;

  void _select(_SummaryTab tab) {
    HapticFeedback.selectionClick();
    setState(() => _tab = tab);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        GlassCard(
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.secondary,
                      theme.colorScheme.tertiary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  size: 20,
                  color: theme.colorScheme.onSecondary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tus resúmenes',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Se generan automáticamente',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    _TabButton(
                      label: 'Semana',
                      selected: _tab == _SummaryTab.week,
                      onTap: () => _select(_SummaryTab.week),
                    ),
                    _TabButton(
                      label: 'Mes',
                      selected: _tab == _SummaryTab.month,
                      onTap: () => _select(_SummaryTab.month),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: BrandSpacing.sm),
        AnimatedSwitcher(
          duration: BrandDurations.normal,
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: _tab == _SummaryTab.week
              ? WeeklySummaryCard(
                  key: const ValueKey('weekly'),
                  summary: widget.weekly,
                )
              : MonthlySummaryCard(
                  key: const ValueKey('monthly'),
                  summary: widget.monthly,
                ),
        ),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: selected
          ? theme.colorScheme.primary
          : Colors.transparent,
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: AnimatedDefaultTextStyle(
          duration: BrandDurations.fast,
          style: theme.textTheme.labelSmall!.copyWith(
            color: selected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(label),
          ),
        ),
      ),
    );
  }
}
