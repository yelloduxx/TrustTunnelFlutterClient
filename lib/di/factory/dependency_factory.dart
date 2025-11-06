import 'package:flutter/material.dart';
import 'package:vpn/common/theme/light_theme.dart';
import 'package:vpn/data/database/app_database.dart' as db;
import 'package:vpn/data/datasources/cached_sources/cached_datasource.dart';
import 'package:vpn/data/datasources/cached_sources/routing_cached_datasource.dart';
import 'package:vpn/data/datasources/cached_sources/server_cached_datasource.dart' show ServerCachedDatasourceImpl;
import 'package:vpn/data/datasources/cached_sources/settings_cached_datasource.dart';
import 'package:vpn/data/datasources/local_sources/routing_local_datasource.dart';
import 'package:vpn/data/datasources/local_sources/server_local_datasource.dart';
import 'package:vpn/data/datasources/local_sources/settings_local_datasource.dart';
import 'package:vpn/data/datasources/native_sources/vpn_datasource.dart';
import 'package:vpn/data/datasources/routing_datasource.dart';
import 'package:vpn/data/datasources/server_datasource.dart';
import 'package:vpn/data/datasources/settings_datasource.dart';
import 'package:vpn/data/datasources/vpn_datasource.dart';
import 'package:vpn/data/model/routing_profile.dart';
import 'package:vpn/data/model/server.dart';
import 'package:vpn_plugin/platform_api.g.dart' as api;
import 'package:vpn_plugin/vpn_plugin.dart';

abstract class DependencyFactory {
  ThemeData get lightThemeData;

  api.IStorageManager get storageManager;

  api.ServersManager get serversManager;

  api.RoutingProfilesManager get routingProfilesManager;

  VpnPlugin get vpnPlugin;

  SettingsDatasource get settingsDatasource;

  ServerDatasource get serverDatasource;

  RoutingDatasource get routingDatasource;

  VpnDatasource get vpnDatasource;

  CachedDataSource<Server> get serverCachedDatasource;

  CachedDataSource<RoutingProfile> get routingProfileCachedDatasource;

  SettingsCachedDatasource get settingsCachedDatasource;

  db.AppDatabase get database;
}

class DependencyFactoryImpl implements DependencyFactory {
  DependencyFactoryImpl();

  ThemeData? _lightThemeData;

  api.IStorageManager? _storageManager;

  api.ServersManager? _serversManager;

  VpnPlugin? _vpnPlugin;

  api.RoutingProfilesManager? _routingProfilesManager;

  SettingsDatasource? _settingsDatasource;

  ServerDatasource? _serverDatasource;

  RoutingDatasource? _routingDatasource;

  VpnDatasource? _vpnDatasource;

  CachedDataSource<Server>? _serverCachedDatasource;

  SettingsCachedDatasource? _settingsCachedDatasource;

  CachedDataSource<RoutingProfile>? _routingProfileCachedDatasource;

  db.AppDatabase? _database;

  @override
  ThemeData get lightThemeData => _lightThemeData ??= LightTheme().data;

  @override
  api.IStorageManager get storageManager => _storageManager ??= api.IStorageManager();

  @override
  api.ServersManager get serversManager => _serversManager ??= api.ServersManager();

  @override
  VpnPlugin get vpnPlugin => _vpnPlugin ??= VpnPlugin();

  @override
  api.RoutingProfilesManager get routingProfilesManager => _routingProfilesManager ??= api.RoutingProfilesManager();

  @override
  SettingsDatasource get settingsDatasource =>
      _settingsDatasource ??= SettingsLocalDatasource(database: database);

  @override
  ServerDatasource get serverDatasource => _serverDatasource ??= ServerLocalDatasource(database: database);

  @override
  RoutingDatasource get routingDatasource =>
      _routingDatasource ??= RoutingLocalDatasource(database);

  @override
  VpnDatasource get vpnDatasource => _vpnDatasource ??= VpnDatasourceImpl(vpnPlugin: vpnPlugin);

  @override
  CachedDataSource<RoutingProfile> get routingProfileCachedDatasource =>
      _routingProfileCachedDatasource ??= RoutingCachedDatasourceImpl();

  @override
  CachedDataSource<Server> get serverCachedDatasource => _serverCachedDatasource ??= ServerCachedDatasourceImpl();

  @override
  SettingsCachedDatasource get settingsCachedDatasource => _settingsCachedDatasource ??= SettingsCachedDatasourceImpl();
  
  @override
  db.AppDatabase get database => _database ??= db.AppDatabase();
}
