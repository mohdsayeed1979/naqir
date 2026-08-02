import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:naqirgiftbox/core/constants/app_dimens.dart';

ImageProvider _resolveImageProvider(String path) {
  if (path.startsWith('http://') || path.startsWith('https://')) {
    return NetworkImage(path);
  }
  return AssetImage(path);
}

/// Pinch-to-zoom, swipeable product gallery with a dot indicator. Falls back
/// to a plain placeholder when a product has no images rather than crashing
/// on an empty [PhotoViewGallery].
class ProductImageGallery extends StatefulWidget {
  const ProductImageGallery({required this.images, super.key, this.heroTag});

  final List<String> images;
  final Object? heroTag;

  @override
  State<ProductImageGallery> createState() => _ProductImageGalleryState();
}

class _ProductImageGalleryState extends State<ProductImageGallery> {
  final _pageController = PageController();
  int _index = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );
    }

    return Stack(
      children: [
        Hero(
          tag: widget.heroTag ?? 'product-gallery',
          child: PhotoViewGallery.builder(
            pageController: _pageController,
            itemCount: widget.images.length,
            onPageChanged: (index) => setState(() => _index = index),
            builder: (context, index) => PhotoViewGalleryPageOptions(
              imageProvider: _resolveImageProvider(widget.images[index]),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2.5,
              initialScale: PhotoViewComputedScale.contained,
            ),
            backgroundDecoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
            ),
            loadingBuilder: (context, _) =>
                const Center(child: CircularProgressIndicator()),
          ),
        ),
        if (widget.images.length > 1)
          Positioned(
            bottom: AppSpacing.sm,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.images.length,
                (dotIndex) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _index == dotIndex ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _index == dotIndex
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
