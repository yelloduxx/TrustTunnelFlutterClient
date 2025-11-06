import 'dart:async';

import 'package:vpn/data/datasources/settings_datasource.dart';
import 'package:vpn/data/model/vpn_request.dart';

abstract class SettingsRepository {
  Future<List<VpnRequest>> getAllRequests();

  Future<void> setExcludedRoutes(String routes);

  Future<String> getExcludedRoutes();
}

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsDatasource _settingsDatasource;

  SettingsRepositoryImpl({
    required SettingsDatasource settingsDatasource,
  }) : _settingsDatasource = settingsDatasource;

  @override
  Future<List<VpnRequest>> getAllRequests() async {
    final requests = await _settingsDatasource.getAllRequests();

    return requests;
  }

  @override
  Future<String> getExcludedRoutes() => _settingsDatasource.getExcludedRoutes();

  @override
  Future<void> setExcludedRoutes(String routes) => _settingsDatasource.setExcludedRoutes(routes);
}
