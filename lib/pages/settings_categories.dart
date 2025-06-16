import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:obtainium/components/category_editor_selector.dart';

class CategoriesSettingsPage extends StatelessWidget {
  const CategoriesSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr('categories'))),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: CategoryEditorSelector(
          showLabelWhenNotEmpty: false,
        ),
      ),
    );
  }
}