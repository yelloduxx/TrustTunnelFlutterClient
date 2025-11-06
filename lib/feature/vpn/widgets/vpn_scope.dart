import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:vpn/data/model/routing_profile.dart';
import 'package:vpn/data/model/server.dart';
import 'package:vpn/data/model/vpn_state.dart';
import 'package:vpn/data/repository/vpn_repository.dart';
import 'package:vpn/feature/vpn/domain/entity/vpn_controller.dart';

typedef OnStartVpnCallback = Future<void> Function({required Server server, required RoutingProfile routingProfile});

class VpnScope extends StatefulWidget {
  final VpnRepository vpnRepository;
  final Widget child;

  const VpnScope({
    required this.child,
    required this.vpnRepository,
    super.key,
  });

  @override
  State<VpnScope> createState() => _VpnScopeState();

  static VpnController? maybeOf(BuildContext context, {bool listen = true}) => listen
      ? context.dependOnInheritedWidgetOfExactType<_InheritedVpnScope>()
      : context.getElementForInheritedWidgetOfExactType<_InheritedVpnScope>()?.widget as _InheritedVpnScope?;

  static Never _notFoundInheritedWidgetOfExactType() => throw ArgumentError(
    'Out of scope, not found inherited widget '
        'a _InheritedVpnScope of the exact type',
    'out_of_scope',
  );

  static VpnController of(BuildContext context, {bool listen = true}) =>
      maybeOf(context, listen: listen) ?? _notFoundInheritedWidgetOfExactType();
}

class _VpnScopeState extends State<VpnScope> {
  Stream<VpnState>? _vpnStream;
  bool _running = false;

  Future<void> _start({
    required Server server,
    required RoutingProfile routingProfile,
  }) async {
    if (_running) {
      await _stop();
    }

    _vpnStream = await widget.vpnRepository.startListenToStates(
      server: server,
      routingProfile: routingProfile,
    );

    _running = true;
  }

  Future<void> _stop() async {
    await widget.vpnRepository.stop();
    await Future.delayed(Duration(seconds: 5));
    _running = false;
  }

  @override
  Widget build(BuildContext context) => StreamBuilder<VpnState>(
    stream: _vpnStream,
    builder: (context, snapshot) => _InheritedVpnScope(
      state: snapshot.data ?? VpnState.disconnected,
      onStart: _start,
      onStop: _stop,
      child: widget.child,
    ),
  );

  @override
  void dispose() {
    _stop().ignore();
    super.dispose();
  }
}

class _InheritedVpnScope extends InheritedWidget implements VpnController {
  final AsyncCallback _onStop;
  final OnStartVpnCallback _onStart;

  const _InheritedVpnScope({
    required OnStartVpnCallback onStart,
    required AsyncCallback onStop,
    required this.state,
    required super.child,
  }) : _onStart = onStart,
       _onStop = onStop;

  @override
  final VpnState state;

  @override
  Future<void> start({
    required Server server,
    required RoutingProfile routingProfile,
  }) => _onStart(
    server: server,
    routingProfile: routingProfile,
  );

  @override
  Future<void> stop() => _onStop();

  @override
  bool updateShouldNotify(covariant _InheritedVpnScope oldWidget) => oldWidget.state != state;
}
