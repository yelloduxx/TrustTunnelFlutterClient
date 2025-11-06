import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vpn/data/model/vpn_protocol.dart';

part 'raw_server.freezed.dart';

@freezed
abstract class RawServer with _$RawServer {
  const factory RawServer({
    required int id,
    required String name,
    required String ipAddress,
    required String domain,
    required String username,
    required String password,
    required VpnProtocol vpnProtocol,
    required List<String> dnsServers,
    required int routingProfileId,
    @Default(false) bool selected,
  }) = _RawServer;
}
