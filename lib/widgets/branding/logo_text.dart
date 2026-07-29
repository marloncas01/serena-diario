import 'package:flutter/material.dart';

class LogoText extends StatelessWidget {
  const LogoText({
    super.key,
    this.size = 32,
    this.color = Colors.white,
    this.showTagline = false,
    this.tagline,
  });

  final double size;
  final Color color;
  final bool showTagline;
  final String? tagline;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Serena',
          style: TextStyle(
            fontSize: size,
            fontWeight: FontWeight.w700,
            letterSpacing: size > 30 ? -1.0 : -0.5,
            height: 1.0,
            color: color,
          ),
        ),
        if (showTagline && tagline != null) ...[
          SizedBox(height: size * 0.15),
          Text(
            tagline!,
            style: TextStyle(
              fontSize: size * 0.30,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.8,
              height: 1.3,
              color: color.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
