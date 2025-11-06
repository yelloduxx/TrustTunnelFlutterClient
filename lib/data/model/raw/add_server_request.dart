import 'package:vpn/data/model/vpn_protocol.dart';

typedef AddServerRequest = ({
  String name,
  String ipAddress,
  String domain,
  String username,
  String password,
  VpnProtocol vpnProtocol,
  int routingProfileId,
  List<String> dnsServers,
});
