import 'package:vpn/data/repository/routing_repository.dart';
import 'package:vpn/data/repository/server_repository.dart';
import 'package:vpn/data/repository/settings_repository.dart';
import 'package:vpn/data/repository/vpn_repository.dart';
import 'package:vpn/di/factory/dependency_factory.dart';

abstract class RepositoryFactory {
  ServerRepository get serverRepository;

  SettingsRepository get settingsRepository;

  RoutingRepository get routingRepository;

  VpnRepository get vpnRepository;
}

class RepositoryFactoryImpl implements RepositoryFactory {
  final DependencyFactory _dependencyFactory;

  RepositoryFactoryImpl({
    required DependencyFactory dependencyFactory,
  }) : _dependencyFactory = dependencyFactory;

  ServerRepository? _serverRepository;

  SettingsRepository? _settingsRepository;

  RoutingRepository? _routingRepository;

  VpnRepository? _vpnRepository;

  @override
  ServerRepository get serverRepository => _serverRepository ??= ServerRepositoryImpl(
    serverDatasource: _dependencyFactory.serverDatasource,
    routingDatasource: _dependencyFactory.routingDatasource,
  );

  @override
  SettingsRepository get settingsRepository => _settingsRepository ??= SettingsRepositoryImpl(
    settingsDatasource: _dependencyFactory.settingsDatasource,
  );

  @override
  RoutingRepository get routingRepository => _routingRepository ??= RoutingRepositoryImpl(
    routingDatasource: _dependencyFactory.routingDatasource,
  );

  @override
  VpnRepository get vpnRepository => _vpnRepository ??= VpnRepositoryImpl(
    vpnDatasource: _dependencyFactory.vpnDatasource,
  );
}
