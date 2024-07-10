import 'package:vpn/common/theme/light_theme.dart';
import 'package:flutter/material.dart';

abstract class DependencyFactory {
  ThemeData get lightThemeData;

  void close();
}

class DependencyFactoryImpl implements DependencyFactory {
  DependencyFactoryImpl();

  ThemeData? _lightThemeData;

  @override
  ThemeData get lightThemeData => _lightThemeData ??= LightTheme().data;

  @override
  void close() {
    // TODO implement close
  }
}
