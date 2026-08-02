/// Spacing, radius, and elevation scale — keeps layout rhythm consistent
/// across every screen instead of magic numbers.
abstract final class AppSpacing {
  static const xxs = 4.0;
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
}

abstract final class AppRadius {
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const pill = 999.0;
}

abstract final class AppElevation {
  static const flat = 0.0;
  static const card = 1.0;
  static const raised = 4.0;
  static const overlay = 8.0;
}

abstract final class AppBreakpoints {
  static const compact = 600.0; // phone
  static const medium = 1024.0; // tablet
  static const expanded = 1440.0; // desktop/web
}
