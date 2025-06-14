import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:obtainium/pages/settings_updates.dart';
import 'package:obtainium/pages/settings_source.dart';
import 'package:obtainium/pages/settings_appearance.dart';
import 'package:obtainium/pages/settings_categories.dart';

class SettingsMainPage extends StatelessWidget {
  const SettingsMainPage({super.key});

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr('settings'))),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.update),
            title: Text(tr('updates')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _open(context, const UpdatesSettingsPage()),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.source),
            title: Text(tr('sourceSpecific')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _open(context, const SourceSpecificSettingsPage()),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.palette),
            title: Text(tr('appearance')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _open(context, const AppearanceSettingsPage()),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.category),
            title: Text(tr('categories')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _open(context, const CategoriesSettingsPage()),
          ),
        ],
      ),
    );
  }
}