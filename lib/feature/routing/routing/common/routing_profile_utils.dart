import 'package:vpn_plugin/platform_api.g.dart';

abstract class RoutingProfileUtils {
  static const defaultRoutingProfileId = 0;

  static bool isDefaultRoutingProfile({required RoutingProfile profile}) => profile.id == defaultRoutingProfileId;
}
