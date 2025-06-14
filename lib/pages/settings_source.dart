import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:obtainium/components/generated_form.dart';
import 'package:obtainium/providers/settings_provider.dart';
import 'package:obtainium/providers/source_provider.dart';
import 'package:provider/provider.dart';

class SourceSpecificSettingsPage extends StatelessWidget {
  const SourceSpecificSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final sourceProvider = SourceProvider();
    if (settingsProvider.prefs == null) settingsProvider.initializeSettings();

    // Generate dynamic source-specific fields
    final sourceSpecificFields = sourceProvider.sources.map((e) {
      if (e.sourceConfigSettingFormItems.isNotEmpty) {
        return GeneratedForm(
            items: e.sourceConfigSettingFormItems.map((item) {
              item.defaultValue = settingsProvider.getSettingString(item.key);
              return [item];
            }).toList(),
            onValueChanges: (values, valid, isBuilding) {
              if (valid && !isBuilding) {
                values.forEach((key, value) {
                  settingsProvider.setSettingString(key, value);
                });
              }
            });
      } else {
        return const SizedBox.shrink();
      }
    }).toList();

    return Scaffold(
      appBar: AppBar(title: Text(tr('sourceSpecific'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String>(
            decoration: InputDecoration(labelText: tr('discoveriumBranch')),
            value: settingsProvider.discoveriumBranch,
            items: const [
              DropdownMenuItem(value: 'main', child: Text('main')),
              DropdownMenuItem(value: 'test', child: Text('test')),
            ],
            onChanged: (value) {
              if (value != null) settingsProvider.discoveriumBranch = value;
            },
          ),
          const SizedBox(height: 16),
          ...sourceSpecificFields,
        ],
      ),
    );
  }
}