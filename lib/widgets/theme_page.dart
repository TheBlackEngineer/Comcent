import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:comcent/imports.dart';
import 'package:comcent/providers/app_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ThemePage extends StatefulWidget {
  @override
  _ThemePageState createState() => _ThemePageState();
}

class _ThemePageState extends State<ThemePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBar(
            title: 'Choose theme',
            context: context,
            onPressed: () => Navigator.of(context).pop()),
        body: Consumer<AppThemeProvider>(
          builder: (context, value, child) {
            int groupValue = value.lastAppTheme;
            return Column(mainAxisSize: MainAxisSize.min, children: [
              RadioListTile(
                value: 0,
                title: Text('Light'),
                groupValue: groupValue,
                onChanged: (index) {
                  value.setLastAppTheme(index);
                  AdaptiveTheme.of(context).setLight();
                },
                activeColor: Theme.of(context).primaryColor,
              ),
              RadioListTile(
                value: 1,
                title: Text('Dark'),
                groupValue: groupValue,
                onChanged: (index) {
                  value.setLastAppTheme(index);
                  AdaptiveTheme.of(context).setDark();
                },
                activeColor: Theme.of(context).primaryColor,
              ),
              RadioListTile(
                value: 2,
                title: Text('Follow system'),
                groupValue: groupValue,
                onChanged: (index) {
                  value.setLastAppTheme(index);
                  AdaptiveTheme.of(context).setSystem();
                },
                activeColor: Theme.of(context).primaryColor,
              ),
            ]);
          },
        ));
  }
}
