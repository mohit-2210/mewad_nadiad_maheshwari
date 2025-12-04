import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mmsn/app/globals/themes.dart';
import 'package:mmsn/app/globals/app_localizations.dart';

class AppState extends ChangeNotifier {
  AppState();

  factory AppState.of(BuildContext context, {bool listen = true}) {
    return Provider.of<AppState>(context, listen: listen);
  }

  ThemeData _theme = lightTheme;
  ThemeData get theme => _theme;

  AppLanguage _language = AppLanguage.en;
  AppLanguage get language => _language;

  void changeTheme(ThemeData theme) {
    _theme = theme;
    notifyListeners();
  }

  void changeLanguage(AppLanguage language) {
    if (_language == language) return;
    _language = language;
    notifyListeners();
  }
}
