import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:naqirgiftbox/shared/widgets/loaders/shimmer_box.dart';

/// Renders either a bundled asset (mock catalog images, `assets/...`) or a
/// cached network image (`http(s)://...`) behind one call site — screens
/// don't need to know which the current data source produced.
class AppImage extends StatelessWidget {
  const AppImage(
    this.path, {
    super.key,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
  });

  final String path;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  bool get _isNetwork =>
      path.startsWith('http://') || path.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    final image = path.isEmpty
        ? _ErrorPlaceholder(width: width, height: height)
        : _isNetwork
        ? CachedNetworkImage(
            imageUrl: path,
            fit: fit,
            width: width,
            height: height,
            placeholder: (context, _) => ShimmerBox(
              width: width,
              height: height,
              borderRadius: borderRadius ?? BorderRadius.zero,
            ),
            errorWidget: (context, _, _) =>
                _ErrorPlaceholder(width: width, height: height),
          )
        : Image.asset(
            path,
            fit: fit,
            width: width,
            height: height,
            errorBuilder: (context, _, _) =>
                _ErrorPlaceholder(width: width, height: height),
          );

    if (borderRadius == null) return image;
    return ClipRRect(borderRadius: borderRadius!, child: image);
  }
}

class _ErrorPlaceholder extends StatelessWidget {
  const _ErrorPlaceholder({this.width, this.height});

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: width,
      height: height,
      color: colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(
        Icons.image_not_supported_outlined,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }
}
