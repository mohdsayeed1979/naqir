import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:naqirgiftbox/core/constants/app_dimens.dart';
import 'package:naqirgiftbox/core/localization/gen/app_localizations.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  Future<void> _open(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).profileContactUs),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        children: [
          ListTile(
            leading: const Icon(Icons.call_outlined),
            title: const Text('Call us'),
            subtitle: const Text('+966 50 545 7678'),
            onTap: () => _open(Uri.parse('tel:+966505457678')),
          ),
          ListTile(
            leading: const Icon(Icons.chat_bubble_outline_rounded),
            title: const Text('WhatsApp'),
            subtitle: const Text('+966 50 545 7678'),
            onTap: () => _open(Uri.parse('https://wa.me/966505457678')),
          ),
          ListTile(
            leading: const Icon(Icons.email_outlined),
            title: const Text('Email'),
            subtitle: const Text('r.albuthi@almousa.com.sa'),
            onTap: () => _open(Uri.parse('mailto:r.albuthi@almousa.com.sa')),
          ),
          ListTile(
            leading: const Icon(Icons.location_on_outlined),
            title: const Text('Our workshop'),
            subtitle: const Text('Al-Diya, Riyadh, Saudi Arabia'),
            onTap: () => _open(
              Uri.parse('https://maps.google.com/?q=24.736143,46.717257'),
            ),
          ),
        ],
      ),
    );
  }
}
