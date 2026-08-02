import 'dart:async';

import 'package:flutter/material.dart';
import 'package:naqirgiftbox/core/constants/app_dimens.dart';

class PromoBanner {
  const PromoBanner({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.colors,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;
}

/// Auto-advancing promo carousel. Uses gradient cards with an icon + copy
/// rather than photography — there's no real campaign imagery yet, and a
/// gradient card reads as an intentional design choice rather than a
/// placeholder the way a broken image would.
class PromoBannerCarousel extends StatefulWidget {
  const PromoBannerCarousel({required this.banners, super.key});

  final List<PromoBanner> banners;

  @override
  State<PromoBannerCarousel> createState() => _PromoBannerCarouselState();
}

class _PromoBannerCarouselState extends State<PromoBannerCarousel> {
  late final PageController _controller = PageController();
  Timer? _timer;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || widget.banners.length < 2) return;
      final next = (_page + 1) % widget.banners.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.banners.length,
            onPageChanged: (index) => setState(() => _page = index),
            itemBuilder: (context, index) {
              final banner = widget.banners[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    gradient: LinearGradient(
                      colors: banner.colors,
                      begin: AlignmentDirectional.topStart,
                      end: AlignmentDirectional.bottomEnd,
                    ),
                  ),
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -16,
                        bottom: -16,
                        child: Icon(
                          banner.icon,
                          size: 120,
                          color: Colors.white.withValues(alpha: 0.16),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            banner.title,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            banner.subtitle,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.banners.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _page == index ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _page == index
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
