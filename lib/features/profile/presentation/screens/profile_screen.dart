import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:naqirgiftbox/core/constants/app_dimens.dart';
import 'package:naqirgiftbox/core/localization/gen/app_localizations.dart';
import 'package:naqirgiftbox/core/router/route_paths.dart';
import 'package:naqirgiftbox/features/authentication/domain/entities/user.dart';
import 'package:naqirgiftbox/features/authentication/presentation/providers/auth_providers.dart';
import 'package:naqirgiftbox/features/profile/presentation/screens/contact_screen.dart';
import 'package:naqirgiftbox/features/profile/presentation/screens/faq_screen.dart';
import 'package:naqirgiftbox/features/profile/presentation/screens/info_page_screen.dart';
import 'package:naqirgiftbox/features/profile/presentation/screens/static_content.dart';
import 'package:naqirgiftbox/shared/widgets/buttons/primary_button.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final user = ref.watch(authProvider).valueOrNull;

    void requireAuth(VoidCallback action) {
      if (user != null) {
        action();
      } else {
        context.push(RoutePaths.login);
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTitle)),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: user != null
                ? _AccountHeader(user: user)
                : _GuestHeader(l10n: l10n),
          ),
          const Divider(height: 1),
          _MenuTile(
            icon: Icons.person_outline_rounded,
            label: l10n.profileEditProfile,
            onTap: () =>
                requireAuth(() => context.push(RoutePaths.editProfile)),
          ),
          _MenuTile(
            icon: Icons.receipt_long_outlined,
            label: l10n.profileMyOrders,
            onTap: () => requireAuth(() => context.push(RoutePaths.orders)),
          ),
          _MenuTile(
            icon: Icons.location_on_outlined,
            label: l10n.profileAddresses,
            onTap: () => requireAuth(() => context.push(RoutePaths.addresses)),
          ),
          _MenuTile(
            icon: Icons.notifications_none_rounded,
            label: l10n.profileNotifications,
            onTap: () {},
          ),
          _MenuTile(
            icon: Icons.settings_outlined,
            label: l10n.profileSettings,
            onTap: () => context.push(RoutePaths.settings),
          ),
          const Divider(height: 1),
          _MenuTile(
            icon: Icons.info_outline_rounded,
            label: l10n.profileAboutUs,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => InfoPageScreen(
                  title: l10n.profileAboutUs,
                  sections: aboutUsSections,
                ),
              ),
            ),
          ),
          _MenuTile(
            icon: Icons.support_agent_outlined,
            label: l10n.profileContactUs,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const ContactScreen()),
            ),
          ),
          _MenuTile(
            icon: Icons.help_outline_rounded,
            label: l10n.profileFaq,
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute<void>(builder: (_) => const FaqScreen())),
          ),
          _MenuTile(
            icon: Icons.privacy_tip_outlined,
            label: l10n.profilePrivacyPolicy,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => InfoPageScreen(
                  title: l10n.profilePrivacyPolicy,
                  sections: privacyPolicySections,
                ),
              ),
            ),
          ),
          _MenuTile(
            icon: Icons.description_outlined,
            label: l10n.profileTermsConditions,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => InfoPageScreen(
                  title: l10n.profileTermsConditions,
                  sections: termsAndConditionsSections,
                ),
              ),
            ),
          ),
          if (user != null) ...[
            const Divider(height: 1),
            _MenuTile(
              icon: Icons.logout_rounded,
              label: l10n.authLogout,
              color: theme.colorScheme.error,
              onTap: () => _confirmLogout(context, ref),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.authLogout),
        content: Text(l10n.authLogoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.authLogout),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(authProvider.notifier).logout();
    }
  }
}

class _AccountHeader extends StatelessWidget {
  const _AccountHeader({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Text(
            user.fullName.isNotEmpty ? user.fullName.characters.first : '?',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user.fullName, style: theme.textTheme.titleMedium),
              Text(
                user.email,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GuestHeader extends StatelessWidget {
  const _GuestHeader({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            l10n.authWelcomeBackSubtitle,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        SizedBox(
          width: 120,
          child: PrimaryButton(
            label: l10n.authLogin,
            onPressed: () => context.push(RoutePaths.login),
          ),
        ),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: TextStyle(color: color)),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}
