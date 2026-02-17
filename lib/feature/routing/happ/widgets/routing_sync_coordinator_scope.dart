import 'package:flutter/widgets.dart';
import 'package:trusttunnel/feature/routing/happ/domain/service/routing_sync_coordinator.dart';

class RoutingSyncCoordinatorScope extends InheritedWidget {
  final RoutingSyncCoordinator coordinator;

  const RoutingSyncCoordinatorScope({
    required this.coordinator,
    required super.child,
    super.key,
  });

  static RoutingSyncCoordinator? maybeOf(BuildContext context, {bool listen = true}) {
    if (listen) {
      return context.dependOnInheritedWidgetOfExactType<RoutingSyncCoordinatorScope>()?.coordinator;
    }

    final widget = context.getElementForInheritedWidgetOfExactType<RoutingSyncCoordinatorScope>()?.widget;
    if (widget is! RoutingSyncCoordinatorScope) {
      return null;
    }

    return widget.coordinator;
  }

  static RoutingSyncCoordinator of(BuildContext context, {bool listen = true}) {
    final value = maybeOf(context, listen: listen);
    if (value == null) {
      throw ArgumentError('RoutingSyncCoordinatorScope not found', 'context');
    }

    return value;
  }

  @override
  bool updateShouldNotify(covariant RoutingSyncCoordinatorScope oldWidget) => coordinator != oldWidget.coordinator;
}
