import 'dart:async';

import 'package:vpn/data/datasources/settings_datasource.dart';

abstract class SettingsRepository {
  Future<void> setExcludedRoutes(String routes);

  Future<String> getExcludedRoutes();
}

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsDataSource _settingsDataSource;

  SettingsRepositoryImpl({
    required SettingsDataSource settingsDataSource,
  }) : _settingsDataSource = settingsDataSource;


  @override
  Future<String> getExcludedRoutes() => _settingsDataSource.getExcludedRoutes();

  @override
  Future<void> setExcludedRoutes(String routes) => _settingsDataSource.setExcludedRoutes(routes);
}
