import 'package:vpn/data/model/routing_mode.dart';
import 'package:vpn/data/model/vpn_protocol.dart';

extension VpnProtocolX on VpnProtocol {
  String get stringValue => switch (this) {
    VpnProtocol.quic => 'QUIC',
    VpnProtocol.http2 => 'HTTP/2',
  };
}

extension RoutingModeX on RoutingMode {
  String get stringValue => switch (this) {
    RoutingMode.bypass => 'Bypass',
    RoutingMode.vpn => 'VPN',
  };
}
