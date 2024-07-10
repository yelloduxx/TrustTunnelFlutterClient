import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vpn/di/factory/bloc_factory.dart';
import 'package:vpn/di/factory/dependency_factory.dart';
import 'package:vpn/di/factory/repository_factory.dart';

part 'initialization_result.freezed.dart';

@freezed
class InitializationResult with _$InitializationResult {
  const InitializationResult._();

  const factory InitializationResult({
    required DependencyFactory dependenciesFactory,
    required BlocFactory blocFactory,
    required RepositoryFactory repositoryFactory,
  }) = _InitializationResult;
}
