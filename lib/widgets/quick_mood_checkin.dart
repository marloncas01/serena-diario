import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/emotion.dart';
import '../models/journal_entry.dart';
import '../providers/journal_provider.dart';
import '../theme/brand/brand_durations.dart';

import '../theme/brand/brand_radius.dart';
import '../theme/brand/brand_spacing.dart';
import 'glass_card.dart';

/// Nota con la que se guarda cada check-in de ánimo rápido.
const String quickCheckInNote = 'Check-in de ánimo rápido';

/// Etiqueta que identifica los check-ins rápidos.
const String quickCheckInTag = 'check-in';

/// Devuelve el check-in reciente (menos de [window]) que debería actualizarse
/// al registrar un nuevo estado, evitando entradas duplicadas en segundos.
JournalEntry? recentCheckInToUpdate(
  List<JournalEntry> entries,
  DateTime now, {
  Duration window = const Duration(minutes: 2),
}) {
  for (final entry in entries) {
    if (entry.tags.contains(quickCheckInTag) &&
        now.difference(entry.createdAt) < window) {
      return entry;
    }
  }
  return null;
}

/// Check-in de ánimo rápido.
///
/// Permite registrar el estado de ánimo en un solo toque desde la pantalla
/// principal. Si ya existe un check-in reciente (menos de 2 minutos) se
/// actualiza su emoción en lugar de crear una entrada duplicada.
class QuickMoodCheckIn extends StatefulWidget {
  const QuickMoodCheckIn({super.key});

  @override
  State<QuickMoodCheckIn> createState() => _QuickMoodCheckInState();
}

class _QuickMoodCheckInState extends State<QuickMoodCheckIn> {
  static const List<({String id, String label})> _quickMoodIds = [
    (id: 'felicidad', label: 'Feliz'),
    (id: 'neutral', label: 'Neutral'),
    (id: 'tristeza', label: 'Triste'),
    (id: 'enojo', label: 'Molesto'),
    (id: 'ansiedad', label: 'Ansioso'),
    (id: 'amor', label: 'Amor'),
  ];

  String? _lastSavedId;

  Future<void> _save(EmotionDefinition emotion) async {
    HapticFeedback.lightImpact();
    final provider = context.read<JournalProvider>();
    final recent = recentCheckInToUpdate(provider.entries, DateTime.now());

    if (recent == null) {
      await provider.add(
        mood: emotion.name,
        note: quickCheckInNote,
        tags: const [quickCheckInTag],
      );
    } else {
      await provider.update(recent.copyWith(mood: emotion.name));
    }

    if (!mounted) return;
    setState(() => _lastSavedId = emotion.id);
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text('${emotion.emoji} Registraste: ${emotion.name}'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primaryContainer,
                      theme.colorScheme.tertiaryContainer,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(BrandRadius.md),
                ),
                child: Icon(
                  Icons.emoji_emotions_outlined,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¿Cómo te sientes ahora?',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Registra tu estado en un toque',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: BrandSpacing.md),
          Row(
            children: _quickMoodIds.map((quick) {
              final emotion = emotionById(quick.id);
              if (emotion == null) return const SizedBox.shrink();
              final active = _lastSavedId == emotion.id;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Semantics(
                    button: true,
                    label: 'Registrar estado ${emotion.name}',
                    child: InkWell(
                      onTap: () => _save(emotion),
                      borderRadius: BorderRadius.circular(BrandRadius.lg),
                      child: AnimatedContainer(
                        duration: BrandDurations.fast,
                        curve: Curves.easeOutCubic,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: active
                              ? emotion.color.withValues(alpha: 0.22)
                              : theme.colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(BrandRadius.lg),
                          border: active
                              ? Border.all(color: emotion.color, width: 1.5)
                              : null,
                        ),
                        child: Column(
                          children: [
                            AnimatedScale(
                              duration: BrandDurations.fast,
                              scale: active ? 1.15 : 1,
                              child: Text(
                                emotion.emoji,
                                style: const TextStyle(fontSize: 26),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              quick.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontSize: 10.5,
                                fontWeight: active
                                    ? FontWeight.w800
                                    : FontWeight.w500,
                                color: active
                                    ? emotion.color
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(growable: false),
          ),
        ],
      ),
    );
  }
}
