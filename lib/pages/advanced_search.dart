import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:obtainium/app_sources/fdroidrepo.dart';
import 'package:obtainium/components/custom_app_bar.dart';
import 'package:obtainium/components/generated_form.dart';
import 'package:obtainium/components/generated_form_modal.dart';
import 'package:obtainium/custom_errors.dart';
import 'package:obtainium/pages/import_export.dart';
import 'package:obtainium/providers/apps_provider.dart';
import 'package:obtainium/providers/settings_provider.dart';
import 'package:obtainium/providers/source_provider.dart';
import 'package:provider/provider.dart';

class AdvancedSearchPage extends StatefulWidget {
  const AdvancedSearchPage({super.key});

  @override
  State<AdvancedSearchPage> createState() => _AdvancedSearchPageState();
}

class _AdvancedSearchPageState extends State<AdvancedSearchPage> {
  bool multiSourceSearching = false;
  bool singleSourceSearching = false;
  String multiSourceSearchQuery = '';
  SourceProvider sourceProvider = SourceProvider();

  @override
  Widget build(BuildContext context) {
    var appsProvider = context.watch<AppsProvider>();
    var settingsProvider = context.watch<SettingsProvider>();

    bool doingSomething = multiSourceSearching || singleSourceSearching;

    // Multi-source search (from add_app.dart)
    runMultiSourceSearch() async {
      setState(() {
        multiSourceSearching = true;
      });
      var sourceStrings = <String, List<String>>{};
      sourceProvider.sources.where((e) => e.canSearch).forEach((s) {
        sourceStrings[s.name] = [s.name];
      });
      try {
        var searchSources = await showDialog<List<String>?>(
                context: context,
                builder: (BuildContext ctx) {
                  return SelectionModal(
                    title: tr('selectX', args: [plural('source', 2)]),
                    entries: sourceStrings,
                    selectedByDefault: true,
                    onlyOneSelectionAllowed: false,
                    titlesAreLinks: false,
                    deselectThese: settingsProvider.searchDeselected,
                  );
                }) ??
            [];
        if (searchSources.isNotEmpty) {
          settingsProvider.searchDeselected = sourceStrings.keys
              .where((s) => !searchSources.contains(s))
              .toList();
          List<MapEntry<String, Map<String, List<String>>>?> results =
              (await Future.wait(sourceProvider.sources
                      .where((e) => searchSources.contains(e.name))
                      .map((e) async {
            try {
              Map<String, dynamic>? querySettings = {};
              if (e.includeAdditionalOptsInMainSearch) {
                querySettings = await showDialog<Map<String, dynamic>?>(
                    context: context,
                    builder: (BuildContext ctx) {
                      return GeneratedFormModal(
                        title: tr('searchX', args: [e.name]),
                        items: [
                          ...e.searchQuerySettingFormItems.map((e) => [e]),
                          [
                            GeneratedFormTextField('url',
                                label: e.hosts.isNotEmpty
                                    ? tr('overrideSource')
                                    : plural('url', 1).substring(2),
                                autoCompleteOptions: [
                                  ...(e.hosts.isNotEmpty ? [e.hosts[0]] : []),
                                  ...appsProvider.apps.values
                                      .where((a) =>
                                          sourceProvider
                                              .getSource(a.app.url,
                                                  overrideSource:
                                                      a.app.overrideSource)
                                              .runtimeType ==
                                          e.runtimeType)
                                      .map((a) {
                                    var uri = Uri.parse(a.app.url);
                                    return '${uri.origin}${uri.path}';
                                  })
                                ],
                                defaultValue:
                                    e.hosts.isNotEmpty ? e.hosts[0] : '',
                                required: true)
                          ],
                        ],
                      );
                    });
                if (querySettings == null) {
                  return null;
                }
              }
              return MapEntry(e.runtimeType.toString(),
                  await e.search(multiSourceSearchQuery, querySettings: querySettings));
            } catch (err) {
              if (err is! CredsNeededError) {
                rethrow;
              } else {
                err.unexpected = true;
                showError(err, context);
                return null;
              }
            }
          })))
                  .where((a) => a != null)
                  .toList();

          // Interleave results instead of simple reduce
          Map<String, MapEntry<String, List<String>>> res = {};
          var si = 0;
          var done = false;
          while (!done) {
            done = true;
            for (var r in results) {
              var sourceName = r!.key;
              if (r.value.length > si) {
                done = false;
                var singleRes = r.value.entries.elementAt(si);
                res[singleRes.key] = MapEntry(sourceName, singleRes.value);
              }
            }
            si++;
          }
          if (res.isEmpty) {
            throw ObtainiumError(tr('noResults'));
          }
          List<String>? selectedUrls = res.isEmpty
              ? []
              // ignore: use_build_context_synchronously
              : await showDialog<List<String>?>(
                  context: context,
                  builder: (BuildContext ctx) {
                    return SelectionModal(
                      entries: res.map((k, v) => MapEntry(k, v.value)),
                      selectedByDefault: false,
                      onlyOneSelectionAllowed: false,
                    );
                  });
          if (selectedUrls != null && selectedUrls.isNotEmpty) {
            var errors = await appsProvider.addAppsByURL(selectedUrls);
            if (errors.isEmpty) {
              // ignore: use_build_context_synchronously
              showMessage(
                  tr('importedX', args: [plural('apps', selectedUrls.length)]),
                  context);
            } else {
              // ignore: use_build_context_synchronously
              showDialog(
                  context: context,
                  builder: (BuildContext ctx) {
                    return ImportErrorDialog(
                        urlsLength: selectedUrls.length, errors: errors);
                  });
            }
          }
        }
      } catch (e) {
        showError(e, context);
      } finally {
        setState(() {
          multiSourceSearching = false;
        });
      }
    }

    // Single source search (from import_export.dart)
    runSingleSourceSearch(AppSource source) {
      () async {
        var values = await showDialog<Map<String, dynamic>?>(
            context: context,
            builder: (BuildContext ctx) {
              return GeneratedFormModal(
                title: tr('searchX', args: [source.name]),
                items: [
                  [
                    GeneratedFormTextField('searchQuery',
                        label: tr('searchQuery'),
                        required: source.name != FDroidRepo().name)
                  ],
                  ...source.searchQuerySettingFormItems.map((e) => [e]),
                  [
                    GeneratedFormTextField('url',
                        label: source.hosts.isNotEmpty
                            ? tr('overrideSource')
                            : plural('url', 1).substring(2),
                        defaultValue:
                            source.hosts.isNotEmpty ? source.hosts[0] : '',
                        required: true)
                  ],
                ],
              );
            });
        if (values != null) {
          setState(() {
            singleSourceSearching = true;
          });
          if (source.hosts.isEmpty || values['url'] != source.hosts[0]) {
            source = sourceProvider.getSource(values['url'],
                overrideSource: source.runtimeType.toString());
          }
          var urlsWithDescriptions = await source
              .search(values['searchQuery'] as String, querySettings: values);
          if (urlsWithDescriptions.isNotEmpty) {
            var selectedUrls =
                // ignore: use_build_context_synchronously
                await showDialog<List<String>?>(
                    context: context,
                    builder: (BuildContext ctx) {
                      return SelectionModal(
                        entries: urlsWithDescriptions,
                        selectedByDefault: false,
                      );
                    });
            if (selectedUrls != null && selectedUrls.isNotEmpty) {
              var errors = await appsProvider.addAppsByURL(selectedUrls,
                  sourceOverride: source);
              if (errors.isEmpty) {
                // ignore: use_build_context_synchronously
                showMessage(
                    tr('importedX',
                        args: [plural('apps', selectedUrls.length)]),
                    context);
              } else {
                // ignore: use_build_context_synchronously
                showDialog(
                    context: context,
                    builder: (BuildContext ctx) {
                      return ImportErrorDialog(
                          urlsLength: selectedUrls.length, errors: errors);
                    });
              }
            }
          } else {
            throw ObtainiumError(tr('noResults'));
          }
        }
      }()
          .catchError((e) {
        showError(e, context);
      }).whenComplete(() {
        setState(() {
          singleSourceSearching = false;
        });
      });
    }

    var sourceStrings = <String, List<String>>{};
    sourceProvider.sources.where((e) => e.canSearch).forEach((s) {
      sourceStrings[s.name] = [s.name];
    });

    Widget getMultiSourceSearchRow() => Row(
          children: [
            Expanded(
              child: GeneratedForm(
                  items: [
                    [
                      GeneratedFormTextField('searchSomeSources',
                          label: tr('searchSomeSourcesLabel'), required: false),
                    ]
                  ],
                  onValueChanges: (values, valid, isBuilding) {
                    if (values.isNotEmpty && valid && !isBuilding) {
                      setState(() {
                        multiSourceSearchQuery = values['searchSomeSources']!.trim();
                      });
                    }
                  }),
            ),
            const SizedBox(
              width: 16,
            ),
            multiSourceSearching
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: multiSourceSearchQuery.isEmpty || doingSomething
                        ? null
                        : () {
                            runMultiSourceSearch();
                          },
                    child: Text(tr('search')))
          ],
        );

    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: Text('Advanced Search'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: CustomScrollView(slivers: <Widget>[
          SliverFillRemaining(
              child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Single source search section
                      if (sourceStrings.isNotEmpty) ...[
                        Text(
                          'Single Source',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                            onPressed: doingSomething
                                ? null
                                : () async {
                                    var searchSourceName =
                                        await showDialog<List<String>?>(
                                                context: context,
                                                builder: (BuildContext ctx) {
                                                  return SelectionModal(
                                                    title: tr('selectX', args: [
                                                      tr('source')
                                                    ]),
                                                    entries: sourceStrings,
                                                    selectedByDefault: false,
                                                    onlyOneSelectionAllowed: true,
                                                    titlesAreLinks: false,
                                                  );
                                                }) ??
                                            [];
                                    var searchSource = sourceProvider.sources
                                        .where((e) => searchSourceName
                                            .contains(e.name))
                                        .toList();
                                    if (searchSource.isNotEmpty) {
                                      runSingleSourceSearch(searchSource[0]);
                                    }
                                  },
                            child: Text(tr('searchX', args: [
                              tr('source').toLowerCase()
                            ]))),
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 24),
                      ],

                      // Multi-source search section
                      if (sourceProvider.sources.where((e) => e.canSearch).isNotEmpty) ...[
                        Text(
                          'Multiple Sources',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                        const SizedBox(height: 16),
                        getMultiSourceSearchRow(),
                      ],

                      // Progress indicator
                      if (doingSomething) ...[
                        const SizedBox(height: 24),
                        const LinearProgressIndicator(),
                        const SizedBox(height: 8),
                        Text(
                          tr('searchingPleaseWait'),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],

                      const Spacer(),
                      if (sourceStrings.isEmpty && sourceProvider.sources.where((e) => e.canSearch).isEmpty)
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                tr('noSearchableSources'),
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                tr('noSearchableSourcesDescription'),
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                    ],
                  )))
        ]));
  }
}