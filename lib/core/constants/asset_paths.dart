/// Central registry of bundled asset paths — avoids typo-prone string
/// literals scattered through the widget tree.
abstract final class AssetPaths {
  static const _images = 'assets/images';
  static const _icons = 'assets/icons';

  static const appIcon = '$_icons/app_icon.png';
  static const brandMark = '$_images/brand_mark.png';
  static const splashLogo = '$_images/splash_logo.png';
  static const splashLogoDark = '$_images/splash_logo_dark.png';
}
