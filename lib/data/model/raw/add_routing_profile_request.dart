import 'package:vpn/data/model/routing_mode.dart';

typedef AddRoutingProfileRequest = ({
  String name,
  RoutingMode defaultMode,
  List<String> bypassRules,
  List<String> vpnRules,
});
