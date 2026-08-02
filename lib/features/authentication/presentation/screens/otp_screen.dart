import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:naqirgiftbox/core/constants/app_dimens.dart';
import 'package:naqirgiftbox/core/localization/gen/app_localizations.dart';
import 'package:naqirgiftbox/core/router/route_paths.dart';
import 'package:naqirgiftbox/features/authentication/presentation/providers/auth_providers.dart';
import 'package:naqirgiftbox/shared/widgets/buttons/primary_button.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _phoneForm = FormGroup({
    'phone': FormControl<String>(
      validators: [Validators.required, Validators.minLength(9)],
    ),
  });
  final _codeForm = FormGroup({
    'code': FormControl<String>(
      validators: [Validators.required, Validators.minLength(4)],
    ),
  });

  bool _codeSent = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  Timer? _cooldownTimer;
  int _cooldownSeconds = 0;

  @override
  void dispose() {
    _phoneForm.dispose();
    _codeForm.dispose();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  String get _phone => _phoneForm.control('phone').value as String;

  void _startCooldown() {
    _cooldownTimer?.cancel();
    setState(() => _cooldownSeconds = 30);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_cooldownSeconds <= 1) {
        timer.cancel();
        setState(() => _cooldownSeconds = 0);
      } else {
        setState(() => _cooldownSeconds -= 1);
      }
    });
  }

  Future<void> _requestCode() async {
    if (_phoneForm.invalid) {
      _phoneForm.markAllAsTouched();
      return;
    }
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    final result = await ref
        .read(authProvider.notifier)
        .requestOtp(phone: _phone);
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    result.when(
      success: (_) {
        setState(() => _codeSent = true);
        _startCooldown();
      },
      failure: (failure) => setState(() => _errorMessage = failure.message),
    );
  }

  Future<void> _verifyCode() async {
    if (_codeForm.invalid) {
      _codeForm.markAllAsTouched();
      return;
    }
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    final result = await ref
        .read(authProvider.notifier)
        .verifyOtp(
          phone: _phone,
          code: _codeForm.control('code').value as String,
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
                _codeSent ? l10n.authOtpTitle : l10n.authLoginWithOtp,
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                _codeSent
                    ? l10n.authOtpSubtitle(_phone)
                    : l10n.authWelcomeBackSubtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              if (!_codeSent)
                ReactiveForm(
                  formGroup: _phoneForm,
                  child: ReactiveTextField<String>(
                    formControlName: 'phone',
                    keyboardType: TextInputType.phone,
                    onSubmitted: (_) => _requestCode(),
                    decoration: InputDecoration(
                      labelText: l10n.authPhoneNumber,
                      prefixIcon: const Icon(Icons.phone_outlined),
                      hintText: '+966 5X XXX XXXX',
                    ),
                  ),
                )
              else
                ReactiveForm(
                  formGroup: _codeForm,
                  child: ReactiveTextField<String>(
                    formControlName: 'code',
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 4,
                    onSubmitted: (_) => _verifyCode(),
                    style: theme.textTheme.headlineSmall,
                    decoration: const InputDecoration(counterText: ''),
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
                label: _codeSent ? l10n.authOtpVerify : l10n.commonContinue,
                isLoading: _isSubmitting,
                onPressed: _codeSent ? _verifyCode : _requestCode,
              ),
              if (_codeSent) ...[
                const SizedBox(height: AppSpacing.md),
                Center(
                  child: TextButton(
                    onPressed: _cooldownSeconds > 0 ? null : _requestCode,
                    child: Text(
                      _cooldownSeconds > 0
                          ? '${l10n.authOtpResend} (${_cooldownSeconds}s)'
                          : l10n.authOtpResend,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
