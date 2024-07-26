import 'package:vpn/di/factory/dependency_factory.dart';
import 'package:vpn/di/factory/repository_factory.dart';
import 'package:vpn/domain/vpn_service.dart';
import 'package:vpn/feature/routing/routing_details/domain/routing_details_service.dart';
import 'package:vpn/feature/server/server_details/domain/server_details_service.dart';

abstract class ServiceFactory {
  ServerDetailsService get serverDetailsService;
  RoutingDetailsService get routingDetailsService;
  VpnService get vpnService;
}

class ServiceFactoryImpl implements ServiceFactory {
  final DependencyFactory _dependencyFactory;
  final RepositoryFactory _repositoryFactory;

  ServiceFactoryImpl({
    required DependencyFactory dependencyFactory,
    required RepositoryFactory repositoryFactory,
  })  : _dependencyFactory = dependencyFactory,
        _repositoryFactory = repositoryFactory;

  ServerDetailsService? _serverDetailsService;
  RoutingDetailsService? _routingDetailsService;
  VpnService? _vpnService;

  @override
  VpnService get vpnService => _vpnService ??= VpnServiceImpl(
        platformApi: _dependencyFactory.platformApi,
        serverRepository: _repositoryFactory.serverRepository,
      );

  @override
  ServerDetailsService get serverDetailsService => _serverDetailsService ??= ServerDetailsServiceImpl(
        serverRepository: _repositoryFactory.serverRepository,
        vpnService: vpnService,
      );

  @override
  RoutingDetailsService get routingDetailsService => _routingDetailsService ??= RoutingDetailsServiceImpl();
}
