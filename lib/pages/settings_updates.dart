import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:equations/equations.dart';
import 'package:flutter/material.dart';
import 'package:obtainium/providers/settings_provider.dart';
import 'package:provider/provider.dart';

class UpdatesSettingsPage extends StatefulWidget {
  const UpdatesSettingsPage({super.key});

  @override
  State<UpdatesSettingsPage> createState() => _UpdatesSettingsPageState();
}

class _UpdatesSettingsPageState extends State<UpdatesSettingsPage> {
  final List<int> _intervalNodes = const [
    15,
    30,
    60,
    120,
    180,
    360,
    720,
    1440,
    4320,
    10080,
    20160,
    43200
  ];

  late SplineInterpolation _interpolator;
  int _updateInterval = 0;
  String _updateIntervalLabel = '';
  bool _showIntervalLabel = true;

  @override
  void initState() {
    super.initState();
    _initInterpolator();
  }

  void _initInterpolator() {
    final nodes = _intervalNodes
        .indexed
        .map((e) => InterpolationNode(x: e.$1.toDouble() + 1, y: e.$2.toDouble()))
        .toList();
    _interpolator = SplineInterpolation(nodes: nodes);
  }

  void _processIntervalSliderValue(double val) {
    if (val < 0.5) {
      _updateInterval = 0;
      _updateIntervalLabel = tr('neverManualOnly');
      return;
    }
    int valInterpolated = 0;
    if (val < 1) {
      valInterpolated = 15;
    } else {
      valInterpolated = _interpolator.compute(val).round();
    }
    if (valInterpolated < 60) {
      _updateInterval = valInterpolated;
      _updateIntervalLabel = plural('minute', valInterpolated);
    } else if (valInterpolated < 8 * 60) {
      int valRounded = (valInterpolated / 15).floor() * 15;
      _updateInterval = valRounded;
      _updateIntervalLabel = plural('hour', valRounded ~/ 60);
      int mins = valRounded % 60;
      if (mins != 0) _updateIntervalLabel += " ${plural('minute', mins)}";
    } else if (valInterpolated < 24 * 60) {
      int valRounded = (valInterpolated / 30).floor() * 30;
      _updateInterval = valRounded;
      _updateIntervalLabel = plural('hour', valRounded / 60);
    } else if (valInterpolated < 7 * 24 * 60) {
      int valRounded = (valInterpolated / (12 * 60)).floor() * 12 * 60;
      _updateInterval = valRounded;
      _updateIntervalLabel = plural('day', valRounded / (24 * 60));
    } else {
      int valRounded = (valInterpolated / (24 * 60)).floor() * 24 * 60;
      _updateInterval = valRounded;
      _updateIntervalLabel = plural('day', valRounded ~/ (24 * 60));
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    if (settingsProvider.prefs == null) settingsProvider.initializeSettings();

    _processIntervalSliderValue(settingsProvider.updateIntervalSliderVal);

    const height8 = SizedBox(height: 8);
    const height16 = SizedBox(height: 16);

    final intervalSlider = Slider(
      value: settingsProvider.updateIntervalSliderVal,
      max: _intervalNodes.length.toDouble(),
      divisions: _intervalNodes.length * 20,
      label: _updateIntervalLabel,
      onChanged: (double value) {
        setState(() {
          settingsProvider.updateIntervalSliderVal = value;
          _processIntervalSliderValue(value);
        });
      },
      onChangeStart: (_) => setState(() => _showIntervalLabel = false),
      onChangeEnd: (_) {
        setState(() {
          _showIntervalLabel = true;
          settingsProvider.updateInterval = _updateInterval;
        });
      },
    );

    return Scaffold(
      appBar: AppBar(title: Text(tr('updates'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_showIntervalLabel)
            Text("${tr('bgUpdateCheckInterval')}: $_updateIntervalLabel"),
          intervalSlider,
          FutureBuilder(
            future: DeviceInfoPlugin().androidInfo,
            builder: (ctx, val) {
              return (settingsProvider.updateInterval > 0) &&
                      (((val.data?.version.sdkInt ?? 0) >= 30) ||
                          settingsProvider.useShizuku)
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(child: Text(tr('enableBackgroundUpdates'))),
                            Switch(
                                value: settingsProvider.enableBackgroundUpdates,
                                onChanged: (v) => settingsProvider.enableBackgroundUpdates = v),
                          ],
                        ),
                        height8,
                        Text(tr('backgroundUpdateReqsExplanation'),
                            style: Theme.of(context).textTheme.labelSmall),
                        Text(tr('backgroundUpdateLimitsExplanation'),
                            style: Theme.of(context).textTheme.labelSmall),
                        height8,
                        if (settingsProvider.enableBackgroundUpdates)
                          Column(
                            children: [
                              height16,
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(child: Text(tr('bgUpdatesOnWiFiOnly'))),
                                  Switch(
                                      value: settingsProvider.bgUpdatesOnWiFiOnly,
                                      onChanged: (v) => settingsProvider.bgUpdatesOnWiFiOnly = v),
                                ],
                              ),
                              height16,
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(child: Text(tr('bgUpdatesWhileChargingOnly'))),
                                  Switch(
                                      value: settingsProvider.bgUpdatesWhileChargingOnly,
                                      onChanged: (v) => settingsProvider.bgUpdatesWhileChargingOnly = v),
                                ],
                              ),
                            ],
                          ),
                      ],
                    )
                  : const SizedBox.shrink();
            },
          ),
          height16,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: Text(tr('checkOnStart'))),
              Switch(
                  value: settingsProvider.checkOnStart,
                  onChanged: (v) => settingsProvider.checkOnStart = v),
            ],
          ),
          height16,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: Text(tr('checkUpdateOnDetailPage'))),
              Switch(
                  value: settingsProvider.checkUpdateOnDetailPage,
                  onChanged: (v) => settingsProvider.checkUpdateOnDetailPage = v),
            ],
          ),
          height16,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: Text(tr('onlyCheckInstalledOrTrackOnlyApps'))),
              Switch(
                  value: settingsProvider.onlyCheckInstalledOrTrackOnlyApps,
                  onChanged: (v) => settingsProvider.onlyCheckInstalledOrTrackOnlyApps = v),
            ],
          ),
          height16,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: Text(tr('removeOnExternalUninstall'))),
              Switch(
                  value: settingsProvider.removeOnExternalUninstall,
                  onChanged: (v) => settingsProvider.removeOnExternalUninstall = v),
            ],
          ),
          height16,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: Text(tr('parallelDownloads'))),
              Switch(
                  value: settingsProvider.parallelDownloads,
                  onChanged: (v) => settingsProvider.parallelDownloads = v),
            ],
          ),
        ],
      ),
    );
  }
}