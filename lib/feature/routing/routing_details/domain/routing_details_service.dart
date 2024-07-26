import 'package:vpn/feature/routing/routing_details/data/routing_details_data.dart';
import 'package:vpn_plugin/platform_api.g.dart';

abstract class RoutingDetailsService {
  AddRoutingProfileRequest toAddRoutingProfileRequest({
    required String profileName,
    required RoutingDetailsData data,
  });

  UpdateRoutingProfileRequest toUpdateRoutingProfileRequest({
    required int id,
    required RoutingDetailsData data,
  });

  String getNewProfileName();

  RoutingDetailsData toRoutingDetailsData({required RoutingProfile routingProfile});
}

class RoutingDetailsServiceImpl implements RoutingDetailsService {
  @override
  AddRoutingProfileRequest toAddRoutingProfileRequest({
    required String profileName,
    required RoutingDetailsData data,
  }) =>
      AddRoutingProfileRequest(
        name: profileName,
        defaultMode: data.defaultMode,
        bypassRules: data.bypassRules,
        vpnRules: data.vpnRules,
      );

  @override
  UpdateRoutingProfileRequest toUpdateRoutingProfileRequest({
    required int id,
    required RoutingDetailsData data,
  }) =>
      UpdateRoutingProfileRequest(
        id: id,
        defaultMode: data.defaultMode,
        bypassRules: data.bypassRules,
        vpnRules: data.vpnRules,
      );

  @override
  RoutingDetailsData toRoutingDetailsData({required RoutingProfile routingProfile}) => RoutingDetailsData(
        defaultMode: routingProfile.defaultMode,
        bypassRules: routingProfile.bypassRules.cast<String>(),
        vpnRules: routingProfile.vpnRules.cast<String>(),
      );

  @override
  String getNewProfileName() => 'New Profile';
}
