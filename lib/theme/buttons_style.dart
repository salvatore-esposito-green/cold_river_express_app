import 'package:flutter/material.dart';

class ButtonStyles {
  static ButtonStyle primary(ColorScheme colorScheme) =>
      ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        minimumSize: const Size(300, 50),
        elevation: 4,
        shadowColor: colorScheme.primary.withValues(alpha: .4),
      );
}
