import 'dart:async';

import 'package:trusttunnel/data/datasources/settings_datasource.dart';
import 'package:trusttunnel/data/model/routing_sync_settings.dart';

abstract class SettingsRepository {
  Future<void> setExcludedRoutes(List<String> routes);

  Future<List<String>> getExcludedRoutes();

  Future<RoutingSyncSettings> getRoutingSyncSettings();

  Future<void> setRoutingSyncSettings({
    required bool enabled,
    required int intervalMinutes,
  });
}

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsDataSource _settingsDataSource;

  SettingsRepositoryImpl({
    required SettingsDataSource settingsDataSource,
  }) : _settingsDataSource = settingsDataSource;

  @override
  Future<List<String>> getExcludedRoutes() => _settingsDataSource.getExcludedRoutes();

  @override
  Future<void> setExcludedRoutes(List<String> routes) => _settingsDataSource.setExcludedRoutes(routes);

  @override
  Future<RoutingSyncSettings> getRoutingSyncSettings() => _settingsDataSource.getRoutingSyncSettings();

  @override
  Future<void> setRoutingSyncSettings({
    required bool enabled,
    required int intervalMinutes,
  }) => _settingsDataSource.setRoutingSyncSettings(
    enabled: enabled,
    intervalMinutes: intervalMinutes,
  );
}
