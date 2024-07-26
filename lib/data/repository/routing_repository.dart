import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:vpn_plugin/platform_api.g.dart';

abstract class RoutingRepository {
  ValueStream<List<RoutingProfile>?> get routingProfileStream;

  Future<void> loadRoutingProfiles();

  Future<void> addRoutingProfile({required AddRoutingProfileRequest request});

  Future<void> updateRoutingProfile({required UpdateRoutingProfileRequest request});

  Future<void> updateRoutingProfileName({required int id, required String name});

  Future<RoutingProfile> getRoutingProfileById({required int id});

  Future<void> deleteRoutingProfileById({required int id});

  Future<void> dispose();
}

class RoutingManagerImpl implements RoutingRepository {
  final PlatformApi _platformApi;

  RoutingManagerImpl({
    required PlatformApi platformApi,
  }) : _platformApi = platformApi;

  final BehaviorSubject<List<RoutingProfile>?> _routingProfileController = BehaviorSubject.seeded(null);

  @override
  ValueStream<List<RoutingProfile>?> get routingProfileStream => _routingProfileController.stream;

  @override
  Future<void> loadRoutingProfiles() async {
    final List<RoutingProfile?> routingProfiles = await _platformApi.getAllRoutingProfiles();

    _routingProfileController.add(routingProfiles.cast<RoutingProfile>());
  }

  @override
  Future<void> addRoutingProfile({required AddRoutingProfileRequest request}) async {
    final routingProfile = await _platformApi.addRoutingProfile(request: request);

    _routingProfileController.add(List.of(_routingProfileController.value ?? [])..add(routingProfile));
  }

  @override
  Future<RoutingProfile> getRoutingProfileById({required int id}) => _platformApi.getRoutingProfileById(id: id);

  @override
  Future<void> updateRoutingProfile({
    required UpdateRoutingProfileRequest request,
  }) async {
    final RoutingProfile routingProfile = await _platformApi.updateRoutingProfile(request: request);

    final List<RoutingProfile> routingProfiles = List.of(_routingProfileController.value!);
    final int index = routingProfiles.indexWhere((element) => element.id == routingProfile.id);
    if (index == -1) throw Exception('RoutingProfile not found');
    routingProfiles[index] = routingProfile;

    _routingProfileController.add(routingProfiles);
  }

  @override
  Future<void> updateRoutingProfileName({required int id, required String name}) async {
    final RoutingProfile routingProfile = await _platformApi.setRoutingProfileName(id: id, name: name);

    final List<RoutingProfile> routingProfiles = List.of(_routingProfileController.value!);
    final int index = routingProfiles.indexWhere((element) => element.id == routingProfile.id);
    if (index == -1) throw Exception('RoutingProfile not found');
    routingProfiles[index] = routingProfile;

    _routingProfileController.add(routingProfiles);
  }

  @override
  Future<void> deleteRoutingProfileById({required int id}) async {
    final List<RoutingProfile> routingProfiles = List.of(_routingProfileController.value!);
    final int index = routingProfiles.indexWhere(
      (element) => element.id == id,
    );
    if (index == -1) throw Exception('RoutingProfile not found');

    await _platformApi.removeRoutingProfile(id: id);
    routingProfiles.removeAt(index);
    _routingProfileController.add(routingProfiles);
  }

  @override
  Future<void> dispose() async {
    _routingProfileController.close();
  }
}
