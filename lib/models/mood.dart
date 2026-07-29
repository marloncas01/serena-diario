import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class Mood {
  const Mood(this.name, this.emoji, this.color);
  final String name, emoji;
  final Color color;
}

const moods = [
  Mood('Feliz', '😊', AppColors.peach),
  Mood('En calma', '😌', AppColors.mint),
  Mood('Normal', '🙂', AppColors.lavender),
  Mood('Triste', '😔', AppColors.rose),
  Mood('Cansada', '😵‍💫', Color(0xFFE4DEF4)),
];
Mood moodByName(String name) =>
    moods.firstWhere((m) => m.name == name, orElse: () => moods[2]);
