import 'package:vpn/di/factory/bloc_factory.dart';
import 'package:vpn/di/factory/dependency_factory.dart';
import 'package:vpn/di/factory/repository_factory.dart';
import 'package:flutter/widgets.dart';

class DependencyScope extends StatefulWidget {
  final DependencyFactory dependenciesFactory;
  final BlocFactory blocFactory;
  final RepositoryFactory repositoryFactory;
  final Widget child;

  const DependencyScope({
    super.key,
    required this.dependenciesFactory,
    required this.repositoryFactory,
    required this.blocFactory,
    required this.child,
  });

  @override
  State<DependencyScope> createState() => _DependencyScopeState();

  static DependencyFactory getDependenciesFactory(BuildContext context) => _scopeOf(context).dependenciesFactory;

  static BlocFactory getBlocFactory(BuildContext context) => _scopeOf(context).blocFactory;

  static RepositoryFactory getRepositoryFactory(BuildContext context) => _scopeOf(context).repositoryFactory;

  static DependencyScope _scopeOf(BuildContext context) =>
      (context.getElementForInheritedWidgetOfExactType<_InheritedDependencyScope>()!.widget
              as _InheritedDependencyScope)
          .state
          .widget;
}

class _DependencyScopeState extends State<DependencyScope> {
  @override
  Widget build(BuildContext context) => _InheritedDependencyScope(
        state: this,
        child: widget.child,
      );

  @override
  void dispose() {
    widget.dependenciesFactory.close();
    super.dispose();
  }
}

class _InheritedDependencyScope extends InheritedWidget {
  final _DependencyScopeState state;

  const _InheritedDependencyScope({
    required super.child,
    required this.state,
  });

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;
}
