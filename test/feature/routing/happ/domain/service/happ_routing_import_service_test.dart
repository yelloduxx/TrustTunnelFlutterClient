import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:trusttunnel/data/model/managed_routing_source.dart';
import 'package:trusttunnel/data/model/raw/add_routing_profile_request.dart';
import 'package:trusttunnel/data/model/routing_mode.dart';
import 'package:trusttunnel/data/model/routing_profile.dart';
import 'package:trusttunnel/data/repository/routing_repository.dart';
import 'package:trusttunnel/feature/routing/happ/domain/service/happ_routing_import_service.dart';

void main() {
  group('HappRoutingImportService', () {
    late HttpServer server;
    late _InMemoryRoutingRepository repository;
    late HappRoutingImportService service;
    late Uri routingUri;

    setUp(() async {
      repository = _InMemoryRoutingRepository();
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);

      final baseUri = Uri.parse('http://${server.address.host}:${server.port}');
      routingUri = baseUri.resolve('/routing');
      final configPayload = jsonEncode(<String, Object>{
        'Name': 'RoutingHelp',
        'GlobalProxy': 'true',
        'Geositeurl': baseUri.resolve('/geosite.dat').toString(),
        'Geoipurl': baseUri.resolve('/geoip.dat').toString(),
        'DirectSites': <String>['direct.example'],
        'ProxySites': <String>['proxy.example'],
        'RouteOrder': 'proxy-direct-block',
      });
      final encodedPayload = base64Encode(utf8.encode(configPayload)).replaceAll('=', '');

      server.listen((request) async {
        if (request.uri.path == '/routing') {
          request.response
            ..statusCode = HttpStatus.found
            ..headers.set(HttpHeaders.locationHeader, 'happ://routing/onadd/$encodedPayload');
          await request.response.close();
          return;
        }

        if (request.uri.path == '/geosite.dat' || request.uri.path == '/geoip.dat') {
          request.response
            ..statusCode = HttpStatus.ok
            ..add(const <int>[]);
          await request.response.close();
          return;
        }

        request.response.statusCode = HttpStatus.notFound;
        await request.response.close();
      });

      service = HappRoutingImportService(
        routingRepository: repository,
        httpClient: HttpClient(),
      );
    });

    tearDown(() async {
      await server.close(force: true);
    });

    test('imports routing config from http redirect to happ link', () async {
      final result = await service.importFromUri(uri: routingUri);

      expect(result.profileName, 'RoutingHelp');
      expect(result.reusedExistingProfile, isFalse);
      expect(repository.profiles, hasLength(1));

      final profile = repository.profiles.single;
      expect(profile.defaultMode, RoutingMode.vpn);
      expect(profile.bypassRules, <String>['direct.example']);
      expect(profile.vpnRules, <String>['proxy.example']);

      final managed = repository.managedSources.single;
      expect(managed.profileId, profile.id);
      expect(managed.sourceUrl, routingUri.toString());
      expect(managed.routeOrder, <String>['proxy', 'direct', 'block']);
      expect(managed.syncEnabled, isTrue);
      expect(managed.localOverride, isFalse);
    });
  });
}

final class _InMemoryRoutingRepository implements RoutingRepository {
  final List<RoutingProfile> profiles = <RoutingProfile>[];
  final List<ManagedRoutingSource> managedSources = <ManagedRoutingSource>[];
  int _nextId = 1;

  @override
  Future<RoutingProfile> addNewProfile(AddRoutingProfileRequest request) async {
    final profile = RoutingProfile(
      id: _nextId++,
      name: request.name,
      defaultMode: request.defaultMode,
      bypassRules: List<String>.from(request.bypassRules),
      vpnRules: List<String>.from(request.vpnRules),
    );
    profiles.add(profile);
    return profile;
  }

  @override
  Future<void> deleteManagedSource({required int profileId}) async {
    managedSources.removeWhere((item) => item.profileId == profileId);
  }

  @override
  Future<void> deleteProfile({required int id}) async {
    profiles.removeWhere((profile) => profile.id == id);
  }

  @override
  Future<List<RoutingProfile>> getAllProfiles() async => List<RoutingProfile>.unmodifiable(profiles);

  @override
  Future<ManagedRoutingSource?> getManagedSourceByProfileId({required int profileId}) async {
    for (final source in managedSources) {
      if (source.profileId == profileId) {
        return source;
      }
    }
    return null;
  }

  @override
  Future<List<ManagedRoutingSource>> getManagedSources() async =>
      List<ManagedRoutingSource>.unmodifiable(managedSources);

  @override
  Future<RoutingProfile?> getProfileById({required int id}) async {
    for (final profile in profiles) {
      if (profile.id == id) {
        return profile;
      }
    }
    return null;
  }

  @override
  Future<void> removeAllRules({required int id}) async {
    await setRules(id: id, mode: RoutingMode.bypass, rules: const <String>[]);
    await setRules(id: id, mode: RoutingMode.vpn, rules: const <String>[]);
  }

  @override
  Future<void> setDefaultRoutingMode({required int id, required RoutingMode mode}) async {
    final index = profiles.indexWhere((profile) => profile.id == id);
    if (index == -1) return;
    profiles[index] = profiles[index].copyWith(defaultMode: mode);
  }

  @override
  Future<void> setProfileName({required int id, required String name}) async {
    final index = profiles.indexWhere((profile) => profile.id == id);
    if (index == -1) return;
    profiles[index] = profiles[index].copyWith(name: name);
  }

  @override
  Future<void> setRules({required int id, required RoutingMode mode, required List<String> rules}) async {
    final index = profiles.indexWhere((profile) => profile.id == id);
    if (index == -1) return;

    final profile = profiles[index];
    profiles[index] = switch (mode) {
      RoutingMode.bypass => profile.copyWith(bypassRules: List<String>.from(rules)),
      RoutingMode.vpn => profile.copyWith(vpnRules: List<String>.from(rules)),
    };
  }

  @override
  Future<void> upsertManagedSource({required ManagedRoutingSource source}) async {
    final index = managedSources.indexWhere((item) => item.profileId == source.profileId);
    if (index == -1) {
      managedSources.add(source);
      return;
    }

    managedSources[index] = source;
  }
}
