import 'package:flutter/widgets.dart';

abstract class CustomPageRoute<T> extends ModalRoute<T> implements PageRoute<T> {
  CustomPageRoute({
    super.settings,
    this.fullscreenDialog = false,
    this.allowSnapshotting = true,
    bool barrierDismissible = false,
    super.traversalEdgeBehavior,
  }) : _barrierDismissible = barrierDismissible;

  @override
  final bool fullscreenDialog;

  @override
  final bool allowSnapshotting;

  @override
  bool get opaque => true;

  @override
  bool get barrierDismissible => _barrierDismissible;

  final bool _barrierDismissible;

  @override
  bool canTransitionTo(TransitionRoute<dynamic> nextRoute) => nextRoute is PageRoute;

  @override
  bool canTransitionFrom(TransitionRoute<dynamic> previousRoute) => previousRoute is PageRoute;
}
