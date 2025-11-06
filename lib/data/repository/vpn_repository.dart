import 'dart:async';

import 'package:vpn/data/datasources/vpn_datasource.dart';
import 'package:vpn/data/model/routing_profile.dart';
import 'package:vpn/data/model/server.dart';
import 'package:vpn/data/model/vpn_state.dart';

abstract class VpnRepository {
  Future<Stream<VpnState>> startListenToStates({required Server server, required RoutingProfile routingProfile});
  Future<void> stop();
}

class VpnRepositoryImpl implements VpnRepository {
  final VpnDatasource _vpnDatasource;

  VpnRepositoryImpl({
    required VpnDatasource vpnDatasource,
  }) : _vpnDatasource = vpnDatasource;

  @override
  Future<Stream<VpnState>> startListenToStates({
    required Server server,
    required RoutingProfile routingProfile,
  }) async {
    await _vpnDatasource.start(
      server: server,
      routingProfile: routingProfile,
    );

    return _vpnDatasource.vpnState;
  }

  @override
  Future<void> stop() => _vpnDatasource.stop();
}
