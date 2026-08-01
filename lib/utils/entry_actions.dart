import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/app_texts.dart';
import '../models/journal_entry.dart';
import '../models/mood.dart';
import '../providers/journal_provider.dart';
import '../theme/brand/brand_durations.dart';
import 'app_feedback.dart';

/// Muestra el bottom sheet de edición de una entrada y persiste los cambios.
/// Devuelve `true` si se guardaron cambios correctamente.
Future<bool> editEntrySheet(
  BuildContext context,
  JournalEntry entry,
) async {
  HapticFeedback.lightImpact();
  final note = TextEditingController(text: entry.note);
  final tags = TextEditingController(text: entry.tags.join(', '));
  var mood = entry.mood;
  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.viewInsetsOf(sheetContext).bottom + 24,
      ),
      child: StatefulBuilder(
        builder: (context, setSheetState) => SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                AppTexts.editEntry,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: moods
                    .map(
                      (item) => AnimatedScale(
                        scale: mood == item.name ? 1.05 : 1.0,
                        duration: BrandDurations.fast,
                        curve: Curves.easeOutCubic,
                        child: ChoiceChip(
                          label: Text('${item.emoji} ${item.name}'),
                          selected: mood == item.name,
                          selectedColor: item.color,
                          onSelected: (_) =>
                              setSheetState(() => mood = item.name),
                        ),
                      ),
                    )
                    .toList(growable: false),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: note,
                minLines: 4,
                maxLines: 8,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Escribe tu reflexión',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: tags,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.sell_outlined),
                  hintText: AppTexts.tagsCommaHint,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(sheetContext, true),
                  child: const Text('Guardar cambios'),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  if (!context.mounted || saved != true) {
    note.dispose();
    tags.dispose();
    return false;
  }
  final updated = await context.read<JournalProvider>().update(
    entry.copyWith(mood: mood, note: note.text, tags: tags.text.split(',')),
  );
  note.dispose();
  tags.dispose();
  if (!context.mounted) return updated;
  if (updated) {
    AppFeedback.success(context, AppTexts.editSaved);
  } else {
    AppFeedback.error(context, AppTexts.editFailed);
  }
  return updated;
}

/// Confirma y elimina una entrada, con opción de deshacer.
/// Devuelve `true` si se eliminó.
Future<bool> confirmDeleteEntry(BuildContext context, String id) async {
  HapticFeedback.mediumImpact();
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      icon: const Icon(Icons.delete_outline_rounded),
      title: const Text('¿Eliminar esta entrada?'),
      content: const Text(
        'Podrás deshacer esta acción durante unos segundos.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text(AppTexts.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text(AppTexts.deleteEntry),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return false;
  final deleted = await context.read<JournalProvider>().delete(id);
  if (!context.mounted || deleted == null) return false;
  HapticFeedback.mediumImpact();
  AppFeedback.show(
    context,
    'Entrada eliminada',
    action: SnackBarAction(
      label: AppTexts.undo.toUpperCase(),
      onPressed: () => context.read<JournalProvider>().restore(deleted),
    ),
  );
  return true;
}
