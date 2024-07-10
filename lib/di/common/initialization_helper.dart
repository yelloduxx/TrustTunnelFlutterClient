import 'package:vpn/di/common/initialization_result.dart';
import 'package:vpn/di/factory/bloc_factory.dart';
import 'package:vpn/di/factory/dependency_factory.dart';
import 'package:vpn/di/factory/repository_factory.dart';

abstract class InitializationHelper {
  Future<InitializationResult> init();
}

class InitializationHelperIo extends InitializationHelper {
  @override
  Future<InitializationResult> init() async {
    final dependenciesFactory = DependencyFactoryImpl();

    final repositoryFactory = RepositoryFactoryImpl(
      dependencyFactory: dependenciesFactory,
    );

    final blocFactory = BlocFactoryImpl(
      repositoryFactory: repositoryFactory,
    );

    return InitializationResult(
      dependenciesFactory: dependenciesFactory,
      blocFactory: blocFactory,
      repositoryFactory: repositoryFactory,
    );
  }
}
