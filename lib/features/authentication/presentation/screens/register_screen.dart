import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:naqirgiftbox/core/constants/app_dimens.dart';
import 'package:naqirgiftbox/core/localization/gen/app_localizations.dart';
import 'package:naqirgiftbox/core/router/route_paths.dart';
import 'package:naqirgiftbox/features/authentication/presentation/providers/auth_providers.dart';
import 'package:naqirgiftbox/shared/widgets/buttons/primary_button.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _form = FormGroup(
    {
      'fullName': FormControl<String>(validators: [Validators.required]),
      'email': FormControl<String>(
        validators: [Validators.required, Validators.email],
      ),
      'password': FormControl<String>(
        validators: [Validators.required, Validators.minLength(6)],
      ),
      'confirmPassword': FormControl<String>(validators: [Validators.required]),
    },
    validators: [Validators.mustMatch('password', 'confirmPassword')],
  );

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
        .register(
          fullName: _form.control('fullName').value as String,
          email: _form.control('email').value as String,
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
      appBar: AppBar(),
      body: SafeArea(
        child: ReactiveForm(
          formGroup: _form,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.authCreateAccount,
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  l10n.authCreateAccountSubtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                ReactiveTextField<String>(
                  formControlName: 'fullName',
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: l10n.authFullName,
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ReactiveTextField<String>(
                  formControlName: 'email',
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
                  textInputAction: TextInputAction.next,
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
                const SizedBox(height: AppSpacing.md),
                ReactiveTextField<String>(
                  formControlName: 'confirmPassword',
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    labelText: l10n.authConfirmPassword,
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                  ),
                  validationMessages: {
                    'mustMatch': (_) => 'Passwords do not match.',
                  },
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _errorMessage!,
                    style: TextStyle(color: theme.colorScheme.error),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                PrimaryButton(
                  label: l10n.authRegister,
                  isLoading: _isSubmitting,
                  onPressed: _submit,
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(l10n.authAlreadyHaveAccount),
                    TextButton(
                      onPressed: () => context.pop(),
                      child: Text(l10n.authLogin),
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
