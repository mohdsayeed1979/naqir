import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:naqirgiftbox/core/constants/app_dimens.dart';
import 'package:naqirgiftbox/core/localization/gen/app_localizations.dart';
import 'package:naqirgiftbox/features/authentication/presentation/providers/auth_providers.dart';
import 'package:naqirgiftbox/shared/widgets/buttons/primary_button.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final FormGroup _form;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).valueOrNull;
    _form = FormGroup({
      'fullName': FormControl<String>(
        value: user?.fullName,
        validators: [Validators.required],
      ),
      'phone': FormControl<String>(value: user?.phone),
    });
  }

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
    setState(() => _isSubmitting = true);
    final result = await ref
        .read(authProvider.notifier)
        .updateProfile(
          fullName: _form.control('fullName').value as String,
          phone: _form.control('phone').value as String?,
        );
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    result.when(
      success: (_) => context.pop(),
      failure: (failure) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.message))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(authProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileEditProfile)),
      body: SafeArea(
        child: ReactiveForm(
          formGroup: _form,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              ReactiveTextField<String>(
                formControlName: 'fullName',
                decoration: InputDecoration(
                  labelText: l10n.authFullName,
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                initialValue: user?.email,
                enabled: false,
                decoration: InputDecoration(
                  labelText: l10n.authEmail,
                  prefixIcon: const Icon(Icons.alternate_email_rounded),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ReactiveTextField<String>(
                formControlName: 'phone',
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: l10n.authPhoneNumber,
                  prefixIcon: const Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                label: l10n.commonSave,
                isLoading: _isSubmitting,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
