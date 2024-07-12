import 'package:flutter/material.dart' hide Router;
import 'package:flutter/material.dart';
import 'package:vpn/di/common/initialization_helper.dart';
import 'package:vpn/di/dependency_scope.dart';
import 'package:vpn/feature/app/app.dart';
import 'package:vpn/feature/initialization/initialization_bloc.dart';

void main() {
  final initializationBloc = InitializationBloc(initializationHelper: InitializationHelperIo())
    ..add(const InitializationEvent.init());

  initializationBloc.stream.listen(
    (state) {
      final result = state.initializationResult;

      if (result != null) {
        runApp(
          DependencyScope(
            dependenciesFactory: result.dependenciesFactory,
            blocFactory: result.blocFactory,
            repositoryFactory: result.repositoryFactory,
            child: const App(),
          ),
        );
      }
    },
  );
}
