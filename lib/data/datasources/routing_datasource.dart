import 'package:vpn/data/model/raw/add_routing_profile_request.dart';
import 'package:vpn/data/model/routing_mode.dart';
import 'package:vpn/data/model/routing_profile.dart';

abstract class RoutingDatasource {
  Future<RoutingProfile> addNewProfile(AddRoutingProfileRequest request);

  Future<RoutingProfile> getProfileById({required int id});

  Future<List<RoutingProfile>> getAllProfiles();

  Future<void> setDefaultRoutingMode({required int id, required RoutingMode mode});

  Future<void> setProfileName({required int id, required String name});

  Future<void> setRules({required int id, required RoutingMode mode, required String rules});

  Future<void> removeAllRules({required int id});

  Future<void> deleteProfile({required int id});
}
