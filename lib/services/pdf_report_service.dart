import 'dart:io';
import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../models/emotion.dart';
import '../models/journal_entry.dart';
import '../utils/journal_insights.dart';

/// Exportación profesional del diario en PDF.
///
/// Genera un informe con portada, resumen, distribución de emociones,
/// actividad semanal y extracto de las entradas recientes, y lo comparte
/// mediante el selector del sistema.
class PdfReportService {
  static const _primary = PdfColor.fromInt(0xFF7C6FE0);
  static const _dark = PdfColor.fromInt(0xFF1C1B2E);
  static const _muted = PdfColor.fromInt(0xFF6E6C87);
  static const _soft = PdfColor.fromInt(0xFFF2F0FA);
  static const _positive = PdfColor.fromInt(0xFF4CAF50);
  static const _negative = PdfColor.fromInt(0xFFEF5350);
  static const _neutral = PdfColor.fromInt(0xFF9E9E9E);
  static const _white70 = PdfColor.fromInt(0xB3FFFFFF);
  static const _white38 = PdfColor.fromInt(0x61FFFFFF);

  /// Construye los bytes del informe sin compartirlos (útil en tests).
  Future<Uint8List> buildReportPdf({
    required List<JournalEntry> entries,
    required String userName,
    DateTime? generatedAt,
  }) async {
    final now = generatedAt ?? DateTime.now();
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (context) => _buildCover(entries, userName, now),
      ),
    );

    if (entries.isNotEmpty) {
      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.fromLTRB(48, 48, 48, 56),
          footer: (context) => _buildFooter(now),
          build: (context) => [
            _buildSummary(entries),
            _buildSectionTitle('Distribución de emociones'),
            ..._buildMoodDistribution(entries),
            _buildSectionTitle('Actividad de la última semana'),
            _buildWeeklyActivity(entries),
            if (_recentEntries(entries).isNotEmpty) ...[
              _buildSectionTitle('Entradas recientes'),
              ..._buildRecentEntries(entries),
            ],
            _buildSectionTitle('Cierre'),
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 8),
              child: pw.Text(
                'Gracias por escribir. Cada palabra que dejas aquí es un paso '
                'hacia una comprensión más amable de ti mismo. Este informe es '
                'solo tuyo: los datos se guardan en tu dispositivo y no se '
                'comparten con terceros.',
                style: pw.TextStyle(
                  fontSize: 11,
                  color: _muted,
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return doc.save();
  }

  /// Genera el informe y abre el selector para compartirlo. Devuelve la ruta
  /// del archivo temporal creado.
  Future<String> generateAndShare({
    required List<JournalEntry> entries,
    required String userName,
  }) async {
    final now = DateTime.now();
    final bytes = await buildReportPdf(
      entries: entries,
      userName: userName,
      generatedAt: now,
    );

    final file = File(
      '${Directory.systemTemp.path}/serena_informe_'
      '${DateFormat('yyyyMMdd_HHmmss').format(now)}.pdf',
    );
    await file.writeAsBytes(bytes);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/pdf')],
        text: 'Mi informe emocional de Serena',
        subject: 'Informe emocional · Serena',
      ),
    );
    return file.path;
  }

  pw.Widget _buildCover(
    List<JournalEntry> entries,
    String userName,
    DateTime now,
  ) {
    final firstEntry = entries.isEmpty ? null : entries.last;
    final range = firstEntry == null
        ? 'Comienza tu viaje de autoconocimiento'
        : '${DateFormat('d MMM yyyy', 'es_ES').format(firstEntry.createdAt)} — '
            '${DateFormat('d MMM yyyy', 'es_ES').format(now)}';

    return pw.Stack(
      children: [
        pw.Positioned.fill(
          child: pw.Container(color: _dark),
        ),
        pw.Positioned(
          top: -120,
          right: -100,
          child: pw.Container(
            width: 320,
            height: 320,
            decoration: pw.BoxDecoration(
              shape: pw.BoxShape.circle,
              color: _primary.withAlpha(0.25),
            ),
          ),
        ),
        pw.Positioned(
          bottom: -140,
          left: -120,
          child: pw.Container(
            width: 380,
            height: 380,
            decoration: pw.BoxDecoration(
              shape: pw.BoxShape.circle,
              color: PdfColors.deepPurple.withAlpha(0.18),
            ),
          ),
        ),
        pw.Center(
          child: pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 48),
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: pw.BoxDecoration(
                    color: _primary,
                    borderRadius: pw.BorderRadius.circular(20),
                  ),
                  child: pw.Text(
                    'SERENA',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 12,
                      letterSpacing: 3,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 28),
                pw.Text(
                  'Informe\nemocional',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 46,
                    height: 1.1,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 16),
                pw.Text(
                  range,
                  style: pw.TextStyle(color: _white70, fontSize: 14),
                ),
                pw.SizedBox(height: 32),
                pw.Container(
                  width: 56,
                  height: 4,
                  decoration: pw.BoxDecoration(
                    color: _primary,
                    borderRadius: pw.BorderRadius.circular(2),
                  ),
                ),
                pw.SizedBox(height: 24),
                pw.Text(
                  'Preparado para ${userName.trim().isEmpty ? 'ti' : userName.trim()}',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Text(
                  '${entries.length} ${entries.length == 1 ? 'reflexión' : 'reflexiones'} '
                  'que merecen ser contadas.',
                  style: pw.TextStyle(color: _white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        pw.Positioned(
          left: 48,
          right: 48,
          bottom: 32,
          child: pw.Text(
            'Uso personal y confidencial · Los datos nunca salen de tu '
            'dispositivo.',
            style: pw.TextStyle(color: _white38, fontSize: 9),
          ),
        ),
      ],
    );
  }

  pw.Widget _buildFooter(DateTime now) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          'Serena · Informe emocional',
          style: pw.TextStyle(color: _muted, fontSize: 9),
        ),
        pw.Text(
          'Generado el ${DateFormat('d MMM yyyy', 'es_ES').format(now)}',
          style: pw.TextStyle(color: _muted, fontSize: 9),
        ),
      ],
    );
  }

  pw.Widget _buildSectionTitle(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 24, bottom: 12),
      child: pw.Row(
        children: [
          pw.Container(
            width: 4,
            height: 18,
            decoration: pw.BoxDecoration(
              color: _primary,
              borderRadius: pw.BorderRadius.circular(2),
            ),
          ),
          pw.SizedBox(width: 10),
          pw.Text(
            title,
            style: pw.TextStyle(
              color: _dark,
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildSummary(List<JournalEntry> entries) {
    final streak = JournalInsights.streak(entries);
    final distinctDays = entries
        .map((e) => DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day))
        .toSet()
        .length;
    final words = JournalInsights.totalWords(entries);
    final avg = (words / entries.length).round();
    final predominant = JournalInsights.predominantMood(entries);

    final rows = [
      _StatRow('Reflexiones', '${entries.length}'),
      _StatRow('Racha actual', '$streak días'),
      _StatRow('Días con escritura', '$distinctDays'),
      _StatRow('Palabras escritas', '$words'),
      _StatRow('Palabras promedio', '$avg'),
    ];

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Resumen'),
        pw.Container(
          padding: const pw.EdgeInsets.all(20),
          decoration: pw.BoxDecoration(
            color: _soft,
            borderRadius: pw.BorderRadius.circular(12),
          ),
          child: pw.Column(
            children: [
              ...rows.map(
                (row) => pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 6),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        row.label,
                        style: pw.TextStyle(color: _muted, fontSize: 12),
                      ),
                      pw.Text(
                        row.value,
                        style: pw.TextStyle(
                          color: _dark,
                          fontSize: 13,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Container(
                height: 1,
                color: PdfColors.grey300,
              ),
              pw.SizedBox(height: 12),
              pw.Row(
                children: [
                  pw.Container(
                    width: 14,
                    height: 14,
                    decoration: pw.BoxDecoration(
                      color: _categoryColor(predominant.category),
                      shape: pw.BoxShape.circle,
                    ),
                  ),
                  pw.SizedBox(width: 10),
                  pw.Text(
                    'Emoción predominante',
                    style: pw.TextStyle(color: _muted, fontSize: 12),
                  ),
                  pw.Spacer(),
                  pw.Text(
                    predominant.name,
                    style: pw.TextStyle(
                      color: _dark,
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<pw.Widget> _buildMoodDistribution(List<JournalEntry> entries) {
    final counts = JournalInsights.moodCounts(entries);
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.take(6).toList();
    final maxCount = top.isEmpty ? 1 : top.first.value;

    return top.map((entry) {
      final emotion = emotionForLabel(entry.key);
      final fraction = entry.value / maxCount;
      return pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 10),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Text(
                    emotion.name,
                    style: pw.TextStyle(
                      color: _dark,
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.Text(
                  '${entry.value}',
                  style: pw.TextStyle(color: _muted, fontSize: 11),
                ),
              ],
            ),
            pw.SizedBox(height: 5),
            pw.Align(
              alignment: pw.Alignment.centerLeft,
              child: pw.Container(
                height: 10,
                width: (fraction * 320).clamp(8, 320),
                decoration: pw.BoxDecoration(
                  color: _categoryColor(emotion.category),
                  borderRadius: pw.BorderRadius.circular(5),
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  pw.Widget _buildWeeklyActivity(List<JournalEntry> entries) {
    final counts = JournalInsights.dailyCounts(entries, days: 7);
    final maxCount = counts.fold(1, (max, value) => value > max ? value : max);
    const labels = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

    return pw.Container(
      height: 140,
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: _soft,
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: List.generate(7, (index) {
          final count = counts[index];
          final barHeight = 16.0 + ((count / maxCount) * 72);
          return pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Text(
                count > 0 ? '$count' : '',
                style: pw.TextStyle(color: _muted, fontSize: 8),
              ),
              pw.SizedBox(height: 4),
              pw.Container(
                width: 22,
                height: barHeight,
                decoration: pw.BoxDecoration(
                  color: count > 0 ? _primary : PdfColors.grey300,
                  borderRadius: pw.BorderRadius.circular(6),
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Text(
                labels[index],
                style: pw.TextStyle(color: _muted, fontSize: 10),
              ),
            ],
          );
        }),
      ),
    );
  }

  List<pw.Widget> _buildRecentEntries(List<JournalEntry> entries) {
    return _recentEntries(entries).map((entry) {
      final emotion = emotionForLabel(entry.mood);
      final date = DateFormat("EEEE d 'de' MMMM, yyyy", 'es_ES')
          .format(entry.createdAt);
      final excerpt = entry.note.trim();
      final preview = excerpt.length > 220
          ? '${excerpt.substring(0, 220)}…'
          : excerpt;

      return pw.Container(
        margin: const pw.EdgeInsets.only(bottom: 12),
        padding: const pw.EdgeInsets.all(14),
        decoration: pw.BoxDecoration(
          color: PdfColors.white,
          borderRadius: pw.BorderRadius.circular(10),
          border: pw.Border.all(color: PdfColors.grey300, width: 0.6),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: pw.BoxDecoration(
                    color: _categoryColor(emotion.category).withAlpha(0.15),
                    borderRadius: pw.BorderRadius.circular(12),
                  ),
                  child: pw.Text(
                    emotion.name,
                    style: pw.TextStyle(
                      color: _categoryColor(emotion.category),
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.Spacer(),
                pw.Text(
                  date,
                  style: pw.TextStyle(color: _muted, fontSize: 9),
                ),
              ],
            ),
            if (preview.isNotEmpty) ...[
              pw.SizedBox(height: 8),
              pw.Text(
                preview,
                style: pw.TextStyle(
                  color: _dark,
                  fontSize: 11,
                  height: 1.5,
                ),
              ),
            ],
          ],
        ),
      );
    }).toList();
  }

  List<JournalEntry> _recentEntries(List<JournalEntry> entries) {
    final recent = entries.take(8).toList();
    recent.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return recent;
  }

  PdfColor _categoryColor(EmotionCategory category) => switch (category) {
        EmotionCategory.positiva => _positive,
        EmotionCategory.negativa => _negative,
        EmotionCategory.mixta => _neutral,
      };
}

class _StatRow {
  const _StatRow(this.label, this.value);
  final String label;
  final String value;
}
