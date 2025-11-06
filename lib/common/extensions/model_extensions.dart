import 'package:vpn/data/model/routing_mode.dart';
import 'package:vpn/data/model/routing_profile.dart';
import 'package:vpn/data/model/vpn_protocol.dart';
import 'package:vpn/data/model/vpn_request.dart';
import 'package:vpn/data/model/vpn_state.dart';
import 'package:vpn_plugin/platform_api.g.dart' as api;

extension VpnProtocolFromApi on VpnProtocol {
  static VpnProtocol parse(api.VpnProtocol protocol) => switch (protocol) {
    api.VpnProtocol.quic => VpnProtocol.quic,
    api.VpnProtocol.http2 => VpnProtocol.http2,
  };
}

extension RoutingModeFromApi on RoutingMode {
  static RoutingMode parse(api.RoutingMode mode) => switch (mode) {
    api.RoutingMode.bypass => RoutingMode.bypass,
    api.RoutingMode.vpn => RoutingMode.vpn,
  };
}

extension VpnRequestFromApi on VpnRequest {
  static VpnRequest parse(api.VpnRequest request) => VpnRequest(
    id: 0,
    zonedDateTime: DateTime.parse(request.zonedDateTime),
    protocolName: request.protocolName,
    decision: RoutingModeFromApi.parse(request.decision),
    sourceIpAddress: request.sourceIpAddress,
    destinationIpAddress: request.destinationIpAddress,
    sourcePort: request.sourcePort,
    destinationPort: request.destinationPort,
    domain: request.domain,
  );
}

extension RoutingProfileFromApi on RoutingProfile {
  static RoutingProfile parse(api.RoutingProfile profile) => RoutingProfile(
    id: profile.id,
    name: profile.name,
    defaultMode: RoutingModeFromApi.parse(
      profile.defaultMode,
    ),
    bypassRules: profile.bypassRules,
    vpnRules: profile.vpnRules,
  );
}

extension VpnStateFromApi on api.VpnManagerState {
  static VpnState parse(api.VpnManagerState state) => switch (state) {
    api.VpnManagerState.connected => VpnState.connected,
    api.VpnManagerState.connecting => VpnState.connecting,
    api.VpnManagerState.disconnected => VpnState.disconnected,
    api.VpnManagerState.waitingForRecovery => VpnState.waitingForRecovery,
    api.VpnManagerState.recovering => VpnState.recovering,
    api.VpnManagerState.waitingForNetwork => VpnState.waitingForNetwork,
  };
}
