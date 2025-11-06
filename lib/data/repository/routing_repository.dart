import 'dart:async';

import 'package:vpn/data/datasources/routing_datasource.dart';
import 'package:vpn/data/model/raw/add_routing_profile_request.dart';
import 'package:vpn/data/model/routing_mode.dart';
import 'package:vpn/data/model/routing_profile.dart';

abstract class RoutingRepository {
  Future<RoutingProfile> addNewProfile(AddRoutingProfileRequest request);

  Future<List<RoutingProfile>> getAllProfiles();

  Future<void> setDefaultRoutingMode({required int id, required RoutingMode mode});

  Future<void> setProfileName({required int id, required String name});

  Future<void> setRules({required int id, required RoutingMode mode, required String rules});

  Future<void> removeAllRules({required int id});

  Future<RoutingProfile?> getProfileById({required int id});

  Future<void> deleteProfile({required int id});
}

class RoutingRepositoryImpl implements RoutingRepository {
  final RoutingDatasource _routingDatasource;

  RoutingRepositoryImpl({
    required RoutingDatasource routingDatasource,
  }) : _routingDatasource = routingDatasource;

  @override
  Future<List<RoutingProfile>> getAllProfiles() async {
    final profiles = await _routingDatasource.getAllProfiles();
    return profiles;
  }

  @override
  Future<RoutingProfile> addNewProfile(AddRoutingProfileRequest request) async {
    final profile = await _routingDatasource.addNewProfile(request);
    return profile;
  }

  @override
  Future<void> setDefaultRoutingMode({required int id, required RoutingMode mode}) =>
      _routingDatasource.setDefaultRoutingMode(id: id, mode: mode);

  @override
  Future<void> setProfileName({required int id, required String name}) =>
      _routingDatasource.setProfileName(id: id, name: name);

  @override
  Future<void> setRules({required int id, required RoutingMode mode, required String rules}) async {
    await _routingDatasource.setRules(id: id, mode: mode, rules: rules);
  }

  @override
  Future<void> removeAllRules({required int id}) async {
    await _routingDatasource.removeAllRules(id: id);
  }

  @override
  Future<RoutingProfile?> getProfileById({required int id}) => _routingDatasource.getProfileById(id: id);

  @override
  Future<void> deleteProfile({required int id}) => _routingDatasource.deleteProfile(id: id);
}
