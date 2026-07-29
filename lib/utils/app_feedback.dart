import 'package:flutter/material.dart';

enum FeedbackType { success, error, info }

class AppFeedback {
  const AppFeedback._();

  static void show(
    BuildContext context,
    String message, {
    SnackBarAction? action,
    FeedbackType type = FeedbackType.success,
  }) {
    final icon = switch (type) {
      FeedbackType.success => Icons.check_circle_outline_rounded,
      FeedbackType.error => Icons.error_outline_rounded,
      FeedbackType.info => Icons.info_outline_rounded,
    };

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          duration: const Duration(seconds: 3),
          content: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          action: action != null
              ? SnackBarAction(
                  label: action.label,
                  textColor: Colors.white.withValues(alpha: 0.9),
                  onPressed: action.onPressed,
                )
              : null,
        ),
      );
  }

  static void success(BuildContext context, String message) =>
      show(context, message, type: FeedbackType.success);

  static void error(BuildContext context, String message) =>
      show(context, message, type: FeedbackType.error);

  static void info(BuildContext context, String message) =>
      show(context, message, type: FeedbackType.info);
}
