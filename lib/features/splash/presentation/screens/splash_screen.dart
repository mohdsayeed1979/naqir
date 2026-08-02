import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:naqirgiftbox/core/constants/app_durations.dart';
import 'package:naqirgiftbox/core/router/route_paths.dart';
import 'package:naqirgiftbox/core/storage/hive/hive_boxes.dart';
import 'package:naqirgiftbox/features/authentication/presentation/providers/auth_providers.dart';
import 'package:naqirgiftbox/shared/widgets/brand_logo.dart';

const onboardingSeenKey = 'onboarding_seen';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: AppDurations.slow)
      ..forward();
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scale = Tween(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _navigateWhenReady();
  }

  Future<void> _navigateWhenReady() async {
    final minimumDisplay = Future<void>.delayed(AppDurations.splashMinimum);
    // Ensures the cached-session check (AuthNotifier.build) has resolved
    // before deciding where to land, so a logged-in user never briefly
    // flashes onboarding/login.
    final authReady = ref.read(authProvider.future);
    await Future.wait([minimumDisplay, authReady]);
    if (!mounted) return;

    final hasSeenOnboarding =
        HiveBoxes.settings.get(onboardingSeenKey) == 'true';
    context.go(hasSeenOnboarding ? RoutePaths.home : RoutePaths.onboarding);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: const BrandLogo(size: 120),
          ),
        ),
      ),
    );
  }
}
