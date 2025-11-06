import 'dart:async';

import 'package:vpn/common/extensions/model_extensions.dart';
import 'package:vpn/data/datasources/vpn_datasource.dart';
import 'package:vpn/data/model/routing_mode.dart';
import 'package:vpn/data/model/routing_profile.dart';
import 'package:vpn/data/model/server.dart';
import 'package:vpn/data/model/vpn_protocol.dart';
import 'package:vpn/data/model/vpn_state.dart';
import 'package:vpn_plugin/platform_api.g.dart' as p;
import 'package:vpn_plugin/vpn_plugin.dart';

class VpnDatasourceImpl implements VpnDatasource {
  final VpnPlugin _platformApi;

  VpnDatasourceImpl({
    required VpnPlugin vpnPlugin,
  }) : _platformApi = vpnPlugin;

  @override
  Stream<VpnState> get vpnState => _platformApi.states.transform(
    StreamTransformer<p.VpnManagerState, VpnState>.fromHandlers(
      handleData: (data, sink) => sink.add(
        VpnStateFromApi.parse(data),
      ),
      handleDone: (sink) async {
        await _platformApi.stop();
        sink.add(VpnState.disconnected);
        sink.close();
      },
    ),
  );

  @override
  Future<void> start({
    required Server server,
    required RoutingProfile routingProfile,
  }) {
    final parsedServer = p.Server(
      id: server.id,
      ipAddress: server.ipAddress,
      domain: server.domain,
      login: server.username,
      password: server.password,
      vpnProtocol: _parseVpnProtocol(server.vpnProtocol),
      routingProfileId: server.routingProfile.id,
      dnsServers: server.dnsServers,
      tlsClientRandomPrefix: '',
      hasIpv6: false,
      certificatePem: '',
    );

    final parsedRoutingProfile = p.RoutingProfile(
      id: routingProfile.id,
      name: routingProfile.name,
      defaultMode: _parseRoutingMode(routingProfile.defaultMode),
      bypassRules: routingProfile.bypassRules,
      vpnRules: routingProfile.vpnRules,
    );

    return _platformApi.start(
      server: parsedServer,
      routingProfile: parsedRoutingProfile,
    );
  }

  @override
  Future<void> stop() async {
    print("FDATA: Stopping {${DateTime.now()}}");
    await _platformApi.stop();
    print("FDATA: Stopped {${DateTime.now()}}");
  }
}


p.RoutingMode _parseRoutingMode(RoutingMode mode) {
  switch (mode) {
    case RoutingMode.bypass:
      return p.RoutingMode.bypass;
    case RoutingMode.vpn:
      return p.RoutingMode.vpn;
  }
}

p.VpnProtocol _parseVpnProtocol(VpnProtocol protocol) {
  switch (protocol) {
    case VpnProtocol.quic:
      return p.VpnProtocol.quic;
    case VpnProtocol.http2:
      return p.VpnProtocol.http2;
  }
}
