import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vpn/data/model/routing_profile.dart';
import 'package:vpn/data/model/vpn_protocol.dart';

part 'server.freezed.dart';

@freezed
abstract class Server with _$Server {
  const factory Server({
    required int id,
    required String name,
    required String ipAddress,
    required String domain,
    required String username,
    required String password,
    required VpnProtocol vpnProtocol,
    required List<String> dnsServers,
    required RoutingProfile routingProfile,
    @Default(false) bool selected,
  }) = _Server;
}
