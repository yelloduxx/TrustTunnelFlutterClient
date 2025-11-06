import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vpn/di/factory/bloc_factory.dart';
import 'package:vpn/di/factory/dependency_factory.dart';
import 'package:vpn/di/factory/repository_factory.dart';
import 'package:vpn/di/factory/service_factory.dart';

part 'initialization_result.freezed.dart';

@freezed
abstract class InitializationResult with _$InitializationResult {
  const factory InitializationResult({
    required DependencyFactory dependenciesFactory,
    required BlocFactory blocFactory,
    required RepositoryFactory repositoryFactory,
    required ServiceFactory serviceFactory,
  }) = _InitializationResult;
}
