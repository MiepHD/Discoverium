import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:obtainium/providers/settings_provider.dart';
import 'package:obtainium/providers/native_provider.dart';
import 'package:provider/provider.dart';
import 'package:obtainium/main.dart';

class AppearanceSettingsPage extends StatefulWidget {
  const AppearanceSettingsPage({super.key});

  @override
  State<AppearanceSettingsPage> createState() => _AppearanceSettingsPageState();
}

class _AppearanceSettingsPageState extends State<AppearanceSettingsPage> {
  final Map<ColorSwatch<Object>, String> _colorsNameMap =
      <ColorSwatch<Object>, String>{
    ColorTools.createPrimarySwatch(obtainiumThemeColor): 'Obtainium'
  };

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    if (settingsProvider.prefs == null) settingsProvider.initializeSettings();

    Future<bool> colorPickerDialog() async {
      return ColorPicker(
        color: settingsProvider.themeColor,
        onColorChanged: (Color color) =>
            setState(() => settingsProvider.themeColor = color),
        actionButtons: const ColorPickerActionButtons(
          okButton: true,
          closeButton: true,
          dialogActionButtons: false,
        ),
        pickersEnabled: const <ColorPickerType, bool>{
          ColorPickerType.both: false,
          ColorPickerType.primary: false,
          ColorPickerType.accent: false,
          ColorPickerType.bw: false,
          ColorPickerType.custom: true,
          ColorPickerType.wheel: true,
        },
        pickerTypeLabels: <ColorPickerType, String>{
          ColorPickerType.custom: tr('standard'),
          ColorPickerType.wheel: tr('custom')
        },
        title: Text(tr('selectX', args: [tr('colour')]),
            style: Theme.of(context).textTheme.titleLarge),
        wheelDiameter: 192,
        wheelSquareBorderRadius: 32,
        width: 48,
        height: 48,
        borderRadius: 24,
        spacing: 8,
        runSpacing: 8,
        enableShadesSelection: false,
        customColorSwatchesAndNames: _colorsNameMap,
        showMaterialName: true,
        showColorName: true,
        materialNameTextStyle: Theme.of(context).textTheme.bodySmall,
        colorNameTextStyle: Theme.of(context).textTheme.bodySmall,
        copyPasteBehavior:
            const ColorPickerCopyPasteBehavior(longPressMenu: true),
      ).showPickerDialog(
        context,
        transitionBuilder: (BuildContext context, Animation<double> a1,
            Animation<double> a2, Widget widget) {
          final double curvedValue = Curves.easeInCubic.transform(a1.value);
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.diagonal3Values(curvedValue, curvedValue, 1),
            child: Opacity(opacity: curvedValue, child: widget),
          );
        },
        transitionDuration: const Duration(milliseconds: 250),
      );
    }

    final colorPickerTile = ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(tr('selectX', args: [tr('colour')])),
      subtitle: Text("${ColorTools.nameThatColor(settingsProvider.themeColor)} "
          "(${ColorTools.materialNameAndCode(settingsProvider.themeColor, colorSwatchNameMap: _colorsNameMap)})"),
      trailing: ColorIndicator(
          width: 40,
          height: 40,
          borderRadius: 20,
          color: settingsProvider.themeColor,
          onSelectFocus: false,
          onSelect: () async {
            final Color colorBeforeDialog = settingsProvider.themeColor;
            if (!(await colorPickerDialog())) {
              setState(() {
                settingsProvider.themeColor = colorBeforeDialog;
              });
            }
          }),
    );

    final sortDropdown = DropdownButtonFormField(
      isExpanded: true,
      decoration: InputDecoration(labelText: tr('appSortBy')),
      value: settingsProvider.sortColumn,
      items: [
        DropdownMenuItem(
          value: SortColumnSettings.authorName,
          child: Text(tr('authorName')),
        ),
        DropdownMenuItem(
          value: SortColumnSettings.nameAuthor,
          child: Text(tr('nameAuthor')),
        ),
        DropdownMenuItem(
          value: SortColumnSettings.added,
          child: Text(tr('asAdded')),
        ),
        DropdownMenuItem(
          value: SortColumnSettings.releaseDate,
          child: Text(tr('releaseDate')),
        )
      ],
      onChanged: (value) {
        if (value != null) settingsProvider.sortColumn = value;
      },
    );

    final orderDropdown = DropdownButtonFormField(
      isExpanded: true,
      decoration: InputDecoration(labelText: tr('appSortOrder')),
      value: settingsProvider.sortOrder,
      items: [
        DropdownMenuItem(
          value: SortOrderSettings.ascending,
          child: Text(tr('ascending')),
        ),
        DropdownMenuItem(
          value: SortOrderSettings.descending,
          child: Text(tr('descending')),
        ),
      ],
      onChanged: (value) {
        if (value != null) settingsProvider.sortOrder = value;
      },
    );

    final localeDropdown = DropdownButtonFormField(
      decoration: InputDecoration(labelText: tr('language')),
      value: settingsProvider.forcedLocale,
      items: [
        DropdownMenuItem(value: null, child: Text(tr('followSystem'))),
        ...supportedLocales.map((e) => DropdownMenuItem(
              value: e.key,
              child: Text(e.value),
            ))
      ],
      onChanged: (value) {
        settingsProvider.forcedLocale = value;
        if (value != null) {
          context.setLocale(value);
        } else {
          settingsProvider.resetLocaleSafe(context);
        }
      },
    );

    const height16 = SizedBox(height: 16);
    const height8 = SizedBox(height: 8);

    Widget _useMaterialYouSwitch() {
      return FutureBuilder(
        future: DeviceInfoPlugin().androidInfo,
        builder: (ctx, val) {
          return ((val.data?.version.sdkInt ?? 0) >= 31)
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(child: Text(tr('useMaterialYou'))),
                    Switch(
                        value: settingsProvider.useMaterialYou,
                        onChanged: (v) => settingsProvider.useMaterialYou = v),
                  ],
                )
              : const SizedBox.shrink();
        },
      );
    }

    Widget _useSystemFontSwitch() {
      return FutureBuilder(
        future: DeviceInfoPlugin().androidInfo,
        builder: (ctx, val) {
          return (val.data?.version.sdkInt ?? 0) >= 34
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(child: Text(tr('useSystemFont'))),
                    Switch(
                        value: settingsProvider.useSystemFont,
                        onChanged: (useSystemFont) {
                          if (useSystemFont) {
                            NativeFeatures.loadSystemFont().then((val) {
                              settingsProvider.useSystemFont = true;
                            });
                          } else {
                            settingsProvider.useSystemFont = false;
                          }
                        }),
                  ],
                )
              : const SizedBox.shrink();
        },
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(tr('appearance'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField(
            decoration: InputDecoration(labelText: tr('theme')),
            value: settingsProvider.theme,
            items: [
              DropdownMenuItem(
                value: ThemeSettings.system,
                child: Text(tr('followSystem')),
              ),
              DropdownMenuItem(
                value: ThemeSettings.light,
                child: Text(tr('light')),
              ),
              DropdownMenuItem(
                value: ThemeSettings.dark,
                child: Text(tr('dark')),
              ),
            ],
            onChanged: (value) {
              if (value != null) settingsProvider.theme = value;
            },
          ),
          height16,
          if (settingsProvider.theme != ThemeSettings.light)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(child: Text(tr('useBlackTheme'))),
                Switch(
                    value: settingsProvider.useBlackTheme,
                    onChanged: (v) => settingsProvider.useBlackTheme = v),
              ],
            ),
          height8,
          _useMaterialYouSwitch(),
          if (!settingsProvider.useMaterialYou) colorPickerTile,
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: sortDropdown),
              const SizedBox(width: 16),
              Expanded(child: orderDropdown),
            ],
          ),
          height16,
          localeDropdown,
          height16,
          _useSystemFontSwitch(),
          height16,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: Text(tr('showWebInAppView'))),
              Switch(
                  value: settingsProvider.showAppWebpage,
                  onChanged: (v) => settingsProvider.showAppWebpage = v),
            ],
          ),
          height16,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: Text(tr('pinUpdates'))),
              Switch(
                  value: settingsProvider.pinUpdates,
                  onChanged: (v) => settingsProvider.pinUpdates = v),
            ],
          ),
          height16,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: Text(tr('moveNonInstalledAppsToBottom'))),
              Switch(
                  value: settingsProvider.buryNonInstalled,
                  onChanged: (v) => settingsProvider.buryNonInstalled = v),
            ],
          ),
          height16,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: Text(tr('groupByCategory'))),
              Switch(
                  value: settingsProvider.groupByCategory,
                  onChanged: (v) => settingsProvider.groupByCategory = v),
            ],
          ),
          height16,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: Text(tr('highlightTouchTargets'))),
              Switch(
                  value: settingsProvider.highlightTouchTargets,
                  onChanged: (v) => settingsProvider.highlightTouchTargets = v),
            ],
          ),
          height16,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: Text(tr('allowUnverifiedApps'))),
              Switch(
                  value: settingsProvider.allowUnverifiedApps,
                  onChanged: (v) => settingsProvider.allowUnverifiedApps = v),
            ],
          ),
          height16,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(child: Text('Allow commercial apps')),
              Switch(
                  value: settingsProvider.allowCommercialApps,
                  onChanged: (v) => settingsProvider.allowCommercialApps = v),
            ],
          ),
          const SizedBox(height: 64), // Padding equal to one element height
        ],
      ),
    );
  }
}