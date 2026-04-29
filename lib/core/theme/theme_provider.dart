import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { system, light, dark }

class ThemeState {
  final AppThemeMode mode;
  const ThemeState(this.mode);

  ThemeMode get flutterThemeMode {
    switch (mode) {
      case AppThemeMode.system:
        return ThemeMode.system;
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
    }
  }
}

class ThemeNotifier extends StateNotifier<ThemeState> {
  static const _key = 'theme_mode';

  ThemeNotifier() : super(const ThemeState(AppThemeMode.system)) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_key);
    if (stored != null) {
      final mode = AppThemeMode.values.firstWhere(
        (e) => e.name == stored,
        orElse: () => AppThemeMode.system,
      );
      state = ThemeState(mode);
    }
  }

  Future<void> setMode(AppThemeMode mode) async {
    state = ThemeState(mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode.name);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});
