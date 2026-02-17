import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:trusttunnel/data/model/managed_routing_source.dart';
import 'package:trusttunnel/data/model/raw/add_routing_profile_request.dart';
import 'package:trusttunnel/data/model/raw/add_server_request.dart';
import 'package:trusttunnel/data/model/routing_mode.dart';
import 'package:trusttunnel/data/model/routing_profile.dart';
import 'package:trusttunnel/data/model/server.dart';
import 'package:trusttunnel/data/model/vpn_protocol.dart';
import 'package:trusttunnel/data/repository/routing_repository.dart';
import 'package:trusttunnel/data/repository/server_repository.dart';
import 'package:trusttunnel/feature/server/import/domain/service/server_config_import_service.dart';

void main() {
  group('ServerConfigImportService', () {
    late RoutingProfile defaultProfile;
    late _FakeRoutingRepository routingRepository;
    late _FakeServerRepository serverRepository;
    late ServerConfigImportService service;

    setUp(() {
      defaultProfile = const RoutingProfile(
        id: 1,
        name: 'Default',
        defaultMode: RoutingMode.vpn,
        bypassRules: <String>[],
        vpnRules: <String>[],
      );

      routingRepository = _FakeRoutingRepository(
        profiles: <RoutingProfile>[defaultProfile],
      );
      serverRepository = _FakeServerRepository(defaultProfile: defaultProfile);

      service = ServerConfigImportService(
        serverRepository: serverRepository,
        routingRepository: routingRepository,
      );
    });

    test('imports admin deep link with explicit fields', () async {
      final uri = Uri.parse(
        'tt://import?hostname=vpn.example.com&address=203.0.113.10:443&username=alice&password=secret&protocol=quic&name=alice@vpn.example.com&dns=1.1.1.1&dns=8.8.8.8',
      );

      final importedName = await service.importFromUri(uri: uri);

      expect(importedName, 'alice@vpn.example.com');
      expect(serverRepository.servers, hasLength(1));

      final server = serverRepository.servers.single;
      expect(server.name, 'alice@vpn.example.com');
      expect(server.domain, 'vpn.example.com');
      expect(server.ipAddress, '203.0.113.10:443');
      expect(server.username, 'alice');
      expect(server.password, 'secret');
      expect(server.vpnProtocol, VpnProtocol.quic);
      expect(server.dnsServers, <String>['1.1.1.1', '8.8.8.8']);
      expect(server.routingProfile.id, 1);
    });

    test('imports provided real-world deep link', () async {
      final uri = Uri.parse(
        'tt://import?hostname=vds.bronos.ru&address=77.238.253.107%3A443&username=admin&password=hHfkc4d9Fort3tzDfVgjBleM&protocol=http2&name=admin%40vds.bronos.ru',
      );

      final importedName = await service.importFromUri(uri: uri);

      expect(importedName, 'admin@vds.bronos.ru');
      expect(serverRepository.servers, hasLength(1));

      final server = serverRepository.servers.single;
      expect(server.name, 'admin@vds.bronos.ru');
      expect(server.domain, 'vds.bronos.ru');
      expect(server.ipAddress, '77.238.253.107:443');
      expect(server.username, 'admin');
      expect(server.password, 'hHfkc4d9Fort3tzDfVgjBleM');
      expect(server.vpnProtocol, VpnProtocol.http2);
      expect(server.dnsServers, <String>['1.1.1.1', '8.8.8.8']);
    });

    test('imports base64 TOML payload from config parameter', () async {
      const toml = '''
hostname = "vpn.example.com"
addresses = ["203.0.113.11:443"]
username = "bob"
password = "pwd"
upstream_protocol = "http2"
dns_upstreams = ["9.9.9.9", "1.1.1.1"]
''';

      final encoded = base64UrlEncode(utf8.encode(toml)).replaceAll('=', '');
      final uri = Uri.parse('tt://import?config=$encoded&name=Bob%20Config');

      final importedName = await service.importFromUri(uri: uri);

      expect(importedName, 'Bob Config');
      expect(serverRepository.servers, hasLength(1));

      final server = serverRepository.servers.single;
      expect(server.name, 'Bob Config');
      expect(server.domain, 'vpn.example.com');
      expect(server.ipAddress, '203.0.113.11:443');
      expect(server.username, 'bob');
      expect(server.password, 'pwd');
      expect(server.vpnProtocol, VpnProtocol.http2);
      expect(server.dnsServers, <String>['9.9.9.9', '1.1.1.1']);
    });

    test('creates unique name when imported name already exists', () async {
      final uri = Uri.parse(
        'tt://import?hostname=vpn.example.com&address=203.0.113.12:443&username=alice&password=secret&name=My%20VPN',
      );

      final first = await service.importFromUri(uri: uri);
      final second = await service.importFromUri(uri: uri);

      expect(first, 'My VPN');
      expect(second, 'My VPN (2)');
      expect(serverRepository.servers.map((e) => e.name).toList(), <String>['My VPN', 'My VPN (2)']);
    });

    test('throws format exception when routing profiles are missing', () async {
      final emptyRoutingRepository = _FakeRoutingRepository(profiles: const <RoutingProfile>[]);
      final serviceWithNoProfiles = ServerConfigImportService(
        serverRepository: serverRepository,
        routingRepository: emptyRoutingRepository,
      );

      final uri = Uri.parse(
        'tt://import?hostname=vpn.example.com&address=203.0.113.13:443&username=alice&password=secret',
      );

      expect(
        () => serviceWithNoProfiles.importFromUri(uri: uri),
        throwsA(isA<FormatException>()),
      );
    });
  });
}

final class _FakeRoutingRepository implements RoutingRepository {
  final List<RoutingProfile> profiles;

  _FakeRoutingRepository({required this.profiles});

  @override
  Future<List<RoutingProfile>> getAllProfiles() async => List<RoutingProfile>.unmodifiable(profiles);

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
  Future<RoutingProfile> addNewProfile(AddRoutingProfileRequest request) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteProfile({required int id}) {
    throw UnimplementedError();
  }

  @override
  Future<void> removeAllRules({required int id}) {
    throw UnimplementedError();
  }

  @override
  Future<void> setDefaultRoutingMode({required int id, required RoutingMode mode}) {
    throw UnimplementedError();
  }

  @override
  Future<void> setProfileName({required int id, required String name}) {
    throw UnimplementedError();
  }

  @override
  Future<void> setRules({required int id, required RoutingMode mode, required List<String> rules}) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteManagedSource({required int profileId}) {
    throw UnimplementedError();
  }

  @override
  Future<ManagedRoutingSource?> getManagedSourceByProfileId({required int profileId}) {
    throw UnimplementedError();
  }

  @override
  Future<List<ManagedRoutingSource>> getManagedSources() {
    throw UnimplementedError();
  }

  @override
  Future<void> upsertManagedSource({required ManagedRoutingSource source}) {
    throw UnimplementedError();
  }
}

final class _FakeServerRepository implements ServerRepository {
  final RoutingProfile defaultProfile;
  final List<Server> servers = <Server>[];
  int _nextId = 1;

  _FakeServerRepository({required this.defaultProfile});

  @override
  Future<Server> addNewServer({required AddServerRequest request}) async {
    final server = Server(
      id: _nextId++,
      name: request.name,
      ipAddress: request.ipAddress,
      domain: request.domain,
      username: request.username,
      password: request.password,
      vpnProtocol: request.vpnProtocol,
      dnsServers: List<String>.from(request.dnsServers),
      routingProfile: defaultProfile,
    );

    servers.add(server);
    return server;
  }

  @override
  Future<List<Server>> getAllServers() async => List<Server>.unmodifiable(servers);

  @override
  Future<Server?> getServerById({required int id}) async {
    for (final server in servers) {
      if (server.id == id) {
        return server;
      }
    }
    return null;
  }

  @override
  Future<void> removeServer({required int serverId}) async {
    servers.removeWhere((server) => server.id == serverId);
  }

  @override
  Future<void> setNewServer({required int id, required AddServerRequest request}) {
    throw UnimplementedError();
  }

  @override
  Future<void> setSelectedServerId({required int id}) {
    throw UnimplementedError();
  }
}
