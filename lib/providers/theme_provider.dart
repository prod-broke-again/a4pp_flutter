import 'package:flutter/material.dart';
import '../services/theme_service.dart';

class ThemeProvider extends ChangeNotifier {
  final ThemeService _themeService;
  AppThemeMode _currentThemeMode = AppThemeMode.system;
  bool _isInitialized = false;

  ThemeProvider(this._themeService) {
    _loadThemeMode();
  }

  AppThemeMode get currentThemeMode => _currentThemeMode;
  bool get isInitialized => _isInitialized;

  Future<void> _loadThemeMode() async {
    _currentThemeMode = await _themeService.getThemeMode();
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> setThemeMode(AppThemeMode themeMode) async {
    if (_currentThemeMode == themeMode) return;

    _currentThemeMode = themeMode;
    await _themeService.setThemeMode(themeMode);
    notifyListeners();
  }

  Future<bool> isDarkMode(BuildContext context) async {
    return await _themeService.isDarkMode(context);
  }

  ThemeMode get materialThemeMode => _currentThemeMode.materialThemeMode;
}
