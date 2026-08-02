import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:naqirgiftbox/core/constants/app_dimens.dart';
import 'package:naqirgiftbox/core/localization/gen/app_localizations.dart';
import 'package:naqirgiftbox/features/checkout/domain/entities/address.dart';
import 'package:naqirgiftbox/features/checkout/presentation/providers/address_providers.dart';
import 'package:naqirgiftbox/shared/widgets/buttons/primary_button.dart';

class AddAddressScreen extends ConsumerStatefulWidget {
  const AddAddressScreen({super.key});

  @override
  ConsumerState<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends ConsumerState<AddAddressScreen> {
  final _form = FormGroup({
    'label': FormControl<String>(
      value: 'Home',
      validators: [Validators.required],
    ),
    'fullName': FormControl<String>(validators: [Validators.required]),
    'phone': FormControl<String>(validators: [Validators.required]),
    'city': FormControl<String>(validators: [Validators.required]),
    'district': FormControl<String>(validators: [Validators.required]),
    'streetAddress': FormControl<String>(validators: [Validators.required]),
    'buildingNumber': FormControl<String>(),
    'additionalDirections': FormControl<String>(),
    'isDefault': FormControl<bool>(value: false),
  });

  bool _isSubmitting = false;

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
    final address = Address(
      id: 'addr-${DateTime.now().millisecondsSinceEpoch}',
      label: _form.control('label').value as String,
      fullName: _form.control('fullName').value as String,
      phone: _form.control('phone').value as String,
      city: _form.control('city').value as String,
      district: _form.control('district').value as String,
      streetAddress: _form.control('streetAddress').value as String,
      buildingNumber: _form.control('buildingNumber').value as String?,
      additionalDirections:
          _form.control('additionalDirections').value as String?,
      isDefault: _form.control('isDefault').value as bool? ?? false,
    );
    await ref.read(addressListProvider.notifier).save(address);
    if (!mounted) return;
    context.pop(address.id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.checkoutAddAddress)),
      body: SafeArea(
        child: ReactiveForm(
          formGroup: _form,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              ReactiveTextField<String>(
                formControlName: 'label',
                decoration: const InputDecoration(
                  labelText: 'Label (e.g. Home, Office)',
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ReactiveTextField<String>(
                formControlName: 'fullName',
                decoration: InputDecoration(labelText: l10n.authFullName),
              ),
              const SizedBox(height: AppSpacing.md),
              ReactiveTextField<String>(
                formControlName: 'phone',
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: l10n.authPhoneNumber),
              ),
              const SizedBox(height: AppSpacing.md),
              ReactiveTextField<String>(
                formControlName: 'city',
                decoration: const InputDecoration(labelText: 'City'),
              ),
              const SizedBox(height: AppSpacing.md),
              ReactiveTextField<String>(
                formControlName: 'district',
                decoration: const InputDecoration(labelText: 'District'),
              ),
              const SizedBox(height: AppSpacing.md),
              ReactiveTextField<String>(
                formControlName: 'streetAddress',
                decoration: const InputDecoration(labelText: 'Street address'),
              ),
              const SizedBox(height: AppSpacing.md),
              ReactiveTextField<String>(
                formControlName: 'buildingNumber',
                decoration: const InputDecoration(
                  labelText: 'Building number (optional)',
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ReactiveTextField<String>(
                formControlName: 'additionalDirections',
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Additional directions (optional)',
                ),
              ),
              ReactiveSwitchListTile(
                formControlName: 'isDefault',
                contentPadding: EdgeInsets.zero,
                title: const Text('Set as default address'),
              ),
              const SizedBox(height: AppSpacing.lg),
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
