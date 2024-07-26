import 'package:vpn/data/repository/routing_repository.dart';
import 'package:vpn/data/repository/server_repository.dart';
import 'package:vpn/data/repository/settings_repository.dart';
import 'package:vpn/di/factory/dependency_factory.dart';

abstract class RepositoryFactory {
  ServerRepository get serverRepository;

  SettingsRepository get settingsRepository;

  RoutingRepository get routingRepository;
}

class RepositoryFactoryImpl implements RepositoryFactory {
  final DependencyFactory _dependencyFactory;

  RepositoryFactoryImpl({
    required DependencyFactory dependencyFactory,
  }) : _dependencyFactory = dependencyFactory;

  ServerRepository? _serverRepository;

  SettingsRepository? _settingsRepository;

  RoutingRepository? _routingRepository;

  @override
  ServerRepository get serverRepository => _serverRepository ??= ServerRepositoryImpl(
        platformApi: _dependencyFactory.platformApi,
      );

  @override
  SettingsRepository get settingsRepository => _settingsRepository ??= SettingsRepositoryImpl(
        platformApi: _dependencyFactory.platformApi,
      );

  @override
  RoutingRepository get routingRepository => _routingRepository ??= RoutingManagerImpl(
        platformApi: _dependencyFactory.platformApi,
      );
}
