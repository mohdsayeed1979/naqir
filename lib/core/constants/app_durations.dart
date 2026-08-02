/// Animation duration/curve scale shared across the app so motion feels
/// consistent rather than every screen picking its own numbers.
abstract final class AppDurations {
  static const fast = Duration(milliseconds: 150);
  static const normal = Duration(milliseconds: 250);
  static const slow = Duration(milliseconds: 400);
  static const splashMinimum = Duration(milliseconds: 1200);
  static const searchDebounce = Duration(milliseconds: 400);
  static const snackBar = Duration(seconds: 3);
}
