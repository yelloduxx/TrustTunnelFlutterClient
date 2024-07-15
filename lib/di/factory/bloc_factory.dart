import 'package:vpn/di/factory/repository_factory.dart';
import 'package:vpn/feature/routing/routing/bloc/routing_bloc.dart';

abstract class BlocFactory {
  RoutingBloc routingBloc();
}

class BlocFactoryImpl implements BlocFactory {
  final RepositoryFactory _repositoryFactory;

  BlocFactoryImpl({
    required RepositoryFactory repositoryFactory,
  }) : _repositoryFactory = repositoryFactory;

  @override
  RoutingBloc routingBloc() => RoutingBloc();
}
