import 'package:flutter/material.dart';
import '../widgets/branding/serena_logo.dart' as branding;

@Deprecated('Use SerenaLogo from widgets/branding/serena_logo.dart instead')
class SerenaLogo extends StatelessWidget {
  const SerenaLogo({super.key, this.size = 64, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return branding.SerenaLogo(
      size: size,
      color: color ?? Colors.white,
    );
  }
}

class SmallLogo extends StatelessWidget {
  const SmallLogo({super.key, this.size = 28, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return branding.SerenaLogo(
      size: size,
      color: color ?? Colors.white,
      layout: branding.SerenaLogoLayout.horizontal,
    );
  }
}
