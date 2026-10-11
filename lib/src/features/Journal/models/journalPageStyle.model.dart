import 'package:flutter/material.dart';

/// A paper + ink colour pair for the diary's pages.
class JournalPageStyle {
  final String id;
  final String name;
  final Color paper;
  final Color ink;
  final Color inkFaded;
  final Color rule;
  final Brightness brightness;

  const JournalPageStyle({
    required this.id,
    required this.name,
    required this.paper,
    required this.ink,
    required this.inkFaded,
    required this.rule,
    this.brightness = Brightness.light,
  });

  bool get isDark => brightness == Brightness.dark;

  static const ivory = JournalPageStyle(
    id: 'ivory',
    name: 'Ivory',
    paper: Color(0xFFFFFDF8),
    ink: Color(0xFF2B2A28),
    inkFaded: Color(0xFF8C867B),
    rule: Color(0xFFE6DFD0),
  );

  static const sepia = JournalPageStyle(
    id: 'sepia',
    name: 'Sepia',
    paper: Color(0xFFF3E7D3),
    ink: Color(0xFF4A3423),
    inkFaded: Color(0xFF8F7660),
    rule: Color(0xFFDFCCAF),
  );

  static const sage = JournalPageStyle(
    id: 'sage',
    name: 'Sage',
    paper: Color(0xFFEDF4EE),
    ink: Color(0xFF1F3A2E),
    inkFaded: Color(0xFF6B8376),
    rule: Color(0xFFD1E0D5),
  );

  static const blush = JournalPageStyle(
    id: 'blush',
    name: 'Blush',
    paper: Color(0xFFFBEEEE),
    ink: Color(0xFF4A2B33),
    inkFaded: Color(0xFF9A7980),
    rule: Color(0xFFECD5D8),
  );

  static const mist = JournalPageStyle(
    id: 'mist',
    name: 'Mist',
    paper: Color(0xFFEDF1F7),
    ink: Color(0xFF1E2C3C),
    inkFaded: Color(0xFF6A798B),
    rule: Color(0xFFD4DDE8),
  );

  static const night = JournalPageStyle(
    id: 'night',
    name: 'Night',
    paper: Color(0xFF12201C),
    ink: Color(0xFFE6F1EC),
    inkFaded: Color(0xFF8CA59B),
    rule: Color(0xFF293B35),
    brightness: Brightness.dark,
  );

  static const charcoal = JournalPageStyle(
    id: 'charcoal',
    name: 'Charcoal',
    paper: Color(0xFF1F1E1D),
    ink: Color(0xFFEDE6D8),
    inkFaded: Color(0xFF9C958A),
    rule: Color(0xFF353331),
    brightness: Brightness.dark,
  );

  static const presets = [ivory, sepia, sage, blush, mist, night, charcoal];

  static JournalPageStyle byId(String? id) {
    return presets.firstWhere((s) => s.id == id, orElse: () => ivory);
  }
}
