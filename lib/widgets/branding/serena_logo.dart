import 'package:flutter/material.dart';
import 'logo_text.dart';

enum SerenaLogoLayout { horizontal, vertical }

enum SerenaLogoVariant { full, isotipo, wordmark }

class SerenaLogo extends StatelessWidget {
  const SerenaLogo({
    super.key,
    this.size = 64,
    this.color = Colors.white,
    this.showGlow = false,
    this.showTagline = false,
    this.tagline,
    this.layout = SerenaLogoLayout.vertical,
    this.variant = SerenaLogoVariant.full,
  });

  final double size;
  final Color color;
  final bool showGlow;
  final bool showTagline;
  final String? tagline;
  final SerenaLogoLayout layout;
  final SerenaLogoVariant variant;

  const SerenaLogo.isotipo({
    super.key,
    this.size = 64,
    this.color = Colors.white,
    this.showGlow = false,
  })  : showTagline = false,
        tagline = null,
        layout = SerenaLogoLayout.vertical,
        variant = SerenaLogoVariant.isotipo;

  const SerenaLogo.wordmark({
    super.key,
    this.size = 32,
    this.color = Colors.white,
    this.showTagline = false,
    this.tagline,
  })  : showGlow = false,
        layout = SerenaLogoLayout.horizontal,
        variant = SerenaLogoVariant.wordmark;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final logoAsset = isDark ? 'assets/images/logo_dark.png' : 'assets/images/logo.png';
    final cacheWidth =
        (size * MediaQuery.devicePixelRatioOf(context)).round();

    if (variant == SerenaLogoVariant.isotipo) {
      return Image.asset(
        logoAsset,
        width: size,
        height: size,
        cacheWidth: cacheWidth,
        filterQuality: FilterQuality.medium,
      );
    }

    if (variant == SerenaLogoVariant.wordmark) {
      return LogoText(
        size: size,
        color: color,
        showTagline: showTagline,
        tagline: tagline,
      );
    }

    final iconSize = size;
    final textSize = size * 0.48;

    if (layout == SerenaLogoLayout.horizontal) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            logoAsset,
            width: iconSize,
            height: iconSize,
            cacheWidth: cacheWidth,
            filterQuality: FilterQuality.medium,
          ),
          SizedBox(width: size * 0.18),
          LogoText(
            size: textSize,
            color: color,
            showTagline: showTagline,
            tagline: tagline,
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          logoAsset,
          width: iconSize,
          height: iconSize,
          cacheWidth: cacheWidth,
          filterQuality: FilterQuality.medium,
        ),
        SizedBox(height: size * 0.12),
        LogoText(
          size: textSize,
          color: color,
          showTagline: showTagline,
          tagline: tagline,
        ),
      ],
    );
  }
}
