import 'package:vpn/data/model/routing_profile.dart';
import 'package:vpn/data/model/server.dart';
import 'package:vpn/data/model/vpn_state.dart';

abstract class VpnDatasource {
  Stream<VpnState> get vpnState;

  Future<void> start({
    required Server server,
    required RoutingProfile routingProfile,
  });

  Future<void> stop();
}
