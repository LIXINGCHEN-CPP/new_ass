import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../core/components/app_back_button.dart';
import '../../../core/components/app_settings_tile.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/constants.dart';
import '../../../core/themes/app_themes.dart';

class LanguageSettingsPage extends StatefulWidget {
  const LanguageSettingsPage({super.key});

  @override
  State<LanguageSettingsPage> createState() => _LanguageSettingsPageState();
}

class _LanguageSettingsPageState extends State<LanguageSettingsPage> {
  // All countries/regions and recommended languages
  final List<String> _allCountries = [
     'Chinese', 'English', 'Malay'
  ];
  final List<String> _suggested = [
    'English'
  ];

  // Current search keyword and selected language
  String _searchText = '';
  String _selected = 'English';

  @override
  Widget build(BuildContext context) {
    // Filter list based on search keyword
    final filteredSuggested = _suggested
        .where((lang) => lang.toLowerCase().contains(_searchText.toLowerCase()))
        .toList();
    final filteredAll = _allCountries
        .where((c) => c.toLowerCase().contains(_searchText.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Language Settings'),
      ),
      backgroundColor: AppColors.cardColor,
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(AppDefaults.padding),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDefaults.padding,
            vertical: AppDefaults.padding * 2,
          ),
          decoration: BoxDecoration(
            color: AppColors.scaffoldBackground,
            borderRadius: AppDefaults.borderRadius,
          ),
          child: Column(
            children: [
              // Search box
              Theme(
                data: Theme.of(context).copyWith(
                  inputDecorationTheme: AppTheme.secondaryInputDecorationTheme,
                ),
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Search',
                    hintText: 'Type a word',
                    suffixIcon: Padding(
                      padding: const EdgeInsets.all(AppDefaults.padding),
                      child: SvgPicture.asset(AppIcons.search),
                    ),
                    suffixIconConstraints: const BoxConstraints(),
                  ),
                  onChanged: (v) {
                    setState(() {
                      _searchText = v;
                    });
                  },
                ),
              ),

              // Recommended languages
              if (filteredSuggested.isNotEmpty) ...[
                const SizedBox(height: AppDefaults.padding),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Suggested'),
                ),
                const SizedBox(height: AppDefaults.padding),
                ...filteredSuggested.map((lang) {
                  return AppSettingsListTile(
                    label: lang,
                    trailing: _selected == lang
                        ? const Icon(Icons.check, color: Colors.green)
                        : null,
                    onTap: () {
                      setState(() {
                        _selected = lang;
                      });
                    },
                  );
                }),
              ],

              // All countries/regions
              const SizedBox(height: AppDefaults.padding),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('All languages'),
              ),
              const SizedBox(height: AppDefaults.padding),
              ...filteredAll.map((country) {
                return AppSettingsListTile(
                  label: country,
                  trailing: _selected == country
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                  onTap: () {
                    setState(() {
                      _selected = country;
                    });
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
