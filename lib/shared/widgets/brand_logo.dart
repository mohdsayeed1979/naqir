import 'package:flutter/material.dart';
import 'package:naqirgiftbox/core/constants/asset_paths.dart';

/// The gift-box brand mark, switching art per brightness so it stays legible
/// on both the light and dark surface colors.
class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.size = 96});

  final double size;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Image.asset(
      isDark ? AssetPaths.splashLogoDark : AssetPaths.splashLogo,
      width: size,
      height: size,
    );
  }
}
