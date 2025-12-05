import 'dart:async';

import 'package:vpn/data/datasources/vpn_datasource.dart';
import 'package:vpn/data/model/routing_profile.dart';
import 'package:vpn/data/model/server.dart';
import 'package:vpn/data/model/vpn_log.dart';
import 'package:vpn/data/model/vpn_state.dart';

abstract class VpnRepository {
  Future<Stream<VpnState>> startListenToStates({required Server server, required RoutingProfile routingProfile});

  Future<Stream<VpnLog>> listenToLogs();

  Future<void> stop();
}

class VpnRepositoryImpl implements VpnRepository {
  final VpnDataSource _vpnDataSource;

  VpnRepositoryImpl({
    required VpnDataSource vpnDataSource,
  }) : _vpnDataSource = vpnDataSource;

  @override
  Future<Stream<VpnState>> startListenToStates({
    required Server server,
    required RoutingProfile routingProfile,
  }) async {
    await _vpnDataSource.start(
      server: server,
      routingProfile: routingProfile,
    );

    return _vpnDataSource.vpnState;
  }

  @override
  Future<void> stop() => _vpnDataSource.stop();

  @override
  Future<Stream<VpnLog>> listenToLogs() async => _vpnDataSource.vpnLogs;
}
