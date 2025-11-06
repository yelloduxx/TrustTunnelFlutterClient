import 'package:vpn/feature/routing/routing_details/domain/routing_details_service.dart';
import 'package:vpn/feature/server/server_details/domain/server_details_service.dart';

abstract class ServiceFactory {
  ServerDetailsService get serverDetailsService;

  RoutingDetailsService get routingDetailsService;
}

class ServiceFactoryImpl implements ServiceFactory {
  ServerDetailsService? _serverDetailsService;

  RoutingDetailsService? _routingDetailsService;

  @override
  ServerDetailsService get serverDetailsService => _serverDetailsService ??= ServerDetailsServiceImpl();

  @override
  RoutingDetailsService get routingDetailsService => _routingDetailsService ??= RoutingDetailsServiceImpl();
}
