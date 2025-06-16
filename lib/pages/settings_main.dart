import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:obtainium/pages/settings_updates.dart';
import 'package:obtainium/pages/settings_source.dart';
import 'package:obtainium/pages/settings_appearance.dart';
import 'package:obtainium/pages/settings_categories.dart';
import 'package:obtainium/providers/settings_provider.dart';
import 'package:obtainium/providers/logs_provider.dart';
import 'package:obtainium/custom_errors.dart';
import 'package:obtainium/components/logs_dialog.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

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
          const Divider(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  onPressed: () {
                    final settingsProvider = context.read<SettingsProvider>();
                    launchUrlString(settingsProvider.sourceUrl,
                        mode: LaunchMode.externalApplication);
                  },
                  icon: const Icon(Icons.code),
                  tooltip: tr('appSource'),
                ),
                IconButton(
                  onPressed: () {
                    context.read<LogsProvider>().get().then((logs) {
                      if (logs.isEmpty) {
                        showMessage(ObtainiumError(tr('noLogs')), context);
                      } else {
                        showDialog(
                          context: context,
                          builder: (BuildContext ctx) {
                            return const LogsDialog();
                          });
                      }
                    });
                  },
                  icon: const Icon(Icons.bug_report_outlined),
                  tooltip: tr('appLogs'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}