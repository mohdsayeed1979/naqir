import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:naqirgiftbox/core/constants/app_dimens.dart';
import 'package:naqirgiftbox/core/constants/asset_paths.dart';
import 'package:naqirgiftbox/core/localization/gen/app_localizations.dart';
import 'package:naqirgiftbox/core/router/route_paths.dart';
import 'package:naqirgiftbox/features/authentication/presentation/providers/auth_providers.dart';
import 'package:naqirgiftbox/shared/widgets/buttons/primary_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _form = FormGroup({
    'identifier': FormControl<String>(validators: [Validators.required]),
    'password': FormControl<String>(
      validators: [Validators.required, Validators.minLength(4)],
    ),
  });

  bool _obscurePassword = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_form.invalid) {
      _form.markAllAsTouched();
      return;
    }
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final result = await ref
        .read(authProvider.notifier)
        .login(
          emailOrPhone: _form.control('identifier').value as String,
          password: _form.control('password').value as String,
        );

    if (!mounted) return;
    setState(() => _isSubmitting = false);
    result.when(
      success: (_) => context.go(RoutePaths.home),
      failure: (failure) => setState(() => _errorMessage = failure.message),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: ReactiveForm(
          formGroup: _form,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.xl),
                Center(child: Image.asset(AssetPaths.brandMark, height: 72)),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  l10n.authWelcomeBack,
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  l10n.authWelcomeBackSubtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),
                ReactiveTextField<String>(
                  formControlName: 'identifier',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: l10n.authEmail,
                    prefixIcon: const Icon(Icons.alternate_email_rounded),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ReactiveTextField<String>(
                  formControlName: 'password',
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    labelText: l10n.authPassword,
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: TextButton(
                    onPressed: () => context.push(RoutePaths.forgotPassword),
                    child: Text(l10n.authForgotPassword),
                  ),
                ),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: theme.colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: AppSpacing.xs),
                PrimaryButton(
                  label: l10n.authLogin,
                  isLoading: _isSubmitting,
                  onPressed: _submit,
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: Divider(color: theme.colorScheme.outlineVariant),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                      ),
                      child: Text(
                        l10n.authOrContinueWith,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(color: theme.colorScheme.outlineVariant),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                PrimaryButton(
                  label: l10n.authLoginWithOtp,
                  outlined: true,
                  icon: Icons.sms_outlined,
                  onPressed: () => context.push(RoutePaths.otp),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(l10n.authDontHaveAccount),
                    TextButton(
                      onPressed: () => context.push(RoutePaths.register),
                      child: Text(l10n.authRegister),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
