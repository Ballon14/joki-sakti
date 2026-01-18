import 'package:flutter/material.dart';

/// Extension untuk Color yang menggantikan deprecated withOpacity
extension ColorExtension on Color {
  /// Menggantikan Color.withOpacity yang deprecated
  /// dengan Color.withValues yang lebih presisi
  Color withOpacityValue(double opacity) {
    return withValues(alpha: opacity);
  }
}
