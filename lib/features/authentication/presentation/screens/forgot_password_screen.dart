import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:naqirgiftbox/core/constants/app_dimens.dart';
import 'package:naqirgiftbox/core/localization/gen/app_localizations.dart';
import 'package:naqirgiftbox/features/authentication/presentation/providers/auth_providers.dart';
import 'package:naqirgiftbox/shared/widgets/buttons/primary_button.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _form = FormGroup({
    'email': FormControl<String>(
      validators: [Validators.required, Validators.email],
    ),
  });

  bool _isSubmitting = false;
  bool _sent = false;
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
        .forgotPassword(email: _form.control('email').value as String);
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    result.when(
      success: (_) => setState(() => _sent = true),
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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: _sent
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.mark_email_read_outlined,
                      size: 72,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      l10n.authForgotPasswordSubtitle,
                      style: theme.textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
              : ReactiveForm(
                  formGroup: _form,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.authForgotPasswordTitle,
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        l10n.authForgotPasswordSubtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      ReactiveTextField<String>(
                        formControlName: 'email',
                        keyboardType: TextInputType.emailAddress,
                        onSubmitted: (_) => _submit(),
                        decoration: InputDecoration(
                          labelText: l10n.authEmail,
                          prefixIcon: const Icon(Icons.alternate_email_rounded),
                        ),
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
                        label: l10n.authSendResetLink,
                        isLoading: _isSubmitting,
                        onPressed: _submit,
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
