import 'package:flutter/material.dart';

import '../core/app_texts.dart';
import '../theme/brand/brand_spacing.dart';
import '../widgets/glass_card.dart';
import '../widgets/ui/section_title_premium.dart';

/// Información legal y de privacidad para la publicación en Google Play.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text(AppTexts.legalInfo)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            BrandSpacing.base,
            16,
            BrandSpacing.base,
            32,
          ),
          children: [
            Center(
              child: Image.asset(
                isDark
                    ? 'assets/images/logo_dark.png'
                    : 'assets/images/logo.png',
                width: 72,
                height: 72,
                cacheWidth: (72 * MediaQuery.devicePixelRatioOf(context))
                    .round(),
                filterQuality: FilterQuality.medium,
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                AppTexts.appName,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.8,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                '${AppTexts.version} · ${AppTexts.designedFor}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Política de privacidad ──
            _LegalSection(
              title: 'Política de privacidad',
              icon: Icons.privacy_tip_outlined,
              paragraphs: const [
                'Serena está diseñada para que tus escritos y datos personales '
                    'permanezcan, por defecto, únicamente en tu dispositivo. No '
                    'vendemos, alquilamos ni compartimos tu información con '
                    'terceros.',
                'Las entradas, el progreso de tus objetivos y tus logros se '
                    'guardan localmente en tu teléfono mediante almacenamiento '
                    'seguro. Al eliminar la aplicación, estos datos se '
                    'eliminarán con ella.',
                'Serena ofrece, de forma opcional, una conexión con tu cuenta '
                    'de Google para futuras funciones en la nube. Si decides '
                    'activarla, solo se utilizan los datos necesarios para la '
                    'sincronización y puedes revocar el acceso en cualquier '
                    'momento desde los ajustes de tu cuenta de Google.',
                'Si activas la asistencia con IA, algunos fragmentos de tu '
                    'entrada actual pueden enviarse a un servicio externo de '
                    'procesamiento de lenguaje natural para generar una '
                    'respuesta empática. La IA está desactivada por defecto y '
                    'solo se usa cuando tú la habilitas.',
                'No recopilamos datos de salud, ubicación ni de contacto sin '
                    'tu consentimiento explícito.',
              ],
            ),
            const SizedBox(height: 16),

            // ── Términos de uso ──
            _LegalSection(
              title: 'Términos de uso',
              icon: Icons.description_outlined,
              paragraphs: const [
                'Serena es una herramienta de reflexión y bienestar personal. '
                    'No constituye consejo médico, psicológico ni psiquiátrico '
                    'profesional, ni sustituye la atención de un especialista.',
                'Si atraviesas una crisis grave o tienes pensamientos que te '
                    'preocupan, contacta con los servicios de emergencia de tu '
                    'país o con un profesional de la salud. En muchos países el '
                    'número es 112 o 911.',
                'Al usar Serena aceptas usar la aplicación de forma '
                    'responsable y respetuosa. Está prohibido su uso para '
                    'actividades ilícitas o que infrinjan derechos de terceros.',
                'La aplicación puede actualizarse para mejorar su '
                    'funcionamiento. El contenido generado por la IA es '
                    'orientativo y puede contener errores.',
              ],
            ),
            const SizedBox(height: 16),

            // ── Licencias ──
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitlePremium(
                    title: 'Licencias y créditos',
                    subtitle: 'Software de código abierto',
                    icon: Icons.workspace_premium_outlined,
                  ),
                  const SizedBox(height: 4),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.code_rounded,
                      color: theme.colorScheme.primary,
                    ),
                    title: const Text('Licencias de dependencias'),
                    subtitle: const Text('Revisa las licencias de cada '
                        'paquete utilizado'),
                    trailing: Icon(
                      Icons.chevron_right_rounded,
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.4,
                      ),
                    ),
                    onTap: () => showLicensePage(
                      context: context,
                      applicationName: AppTexts.appName,
                      applicationVersion: AppTexts.version,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Center(
              child: Text(
                AppTexts.aboutDescription,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Creado por ${AppTexts.developedBy}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegalSection extends StatelessWidget {
  const _LegalSection({
    required this.title,
    required this.icon,
    required this.paragraphs,
  });

  final String title;
  final IconData icon;
  final List<String> paragraphs;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitlePremium(title: title, icon: icon),
          ...paragraphs.map(
            (paragraph) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                paragraph,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.85),
                      height: 1.5,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
