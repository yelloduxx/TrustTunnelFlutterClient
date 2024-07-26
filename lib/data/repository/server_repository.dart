import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:vpn_plugin/platform_api.g.dart';

abstract class ServerRepository {
  ValueStream<List<Server>?> get serverStream;

  ValueStream<int?> get selectedServerIdStream;

  Future<void> loadServers();

  Future<void> addServer({required AddServerRequest request});

  Future<void> updateServer({required UpdateServerRequest request});

  Future<Server> getServerById({required int id});

  Future<void> setSelectedServerId({required int id});

  Future<int?> getSelectedServerId();

  Future<void> deleteServer({required int serverId});

  Future<void> dispose();
}

class ServerRepositoryImpl implements ServerRepository {
  final PlatformApi _platformApi;

  ServerRepositoryImpl({
    required PlatformApi platformApi,
  }) : _platformApi = platformApi {
    _init();
  }

  final BehaviorSubject<List<Server>?> _serverController = BehaviorSubject.seeded(null);

  final BehaviorSubject<int?> _selectedServerIdController = BehaviorSubject.seeded(null);

  @override
  ValueStream<List<Server>?> get serverStream => _serverController.stream;

  @override
  ValueStream<int?> get selectedServerIdStream => _selectedServerIdController.stream;

  Future<void> _init() async => _selectedServerIdController.add(
        await _platformApi.getSelectedServerId(),
      );

  @override
  Future<void> loadServers() async {
    final List<Server?> servers = await _platformApi.getAllServers();

    _serverController.add(servers.cast<Server>());
  }

  @override
  Future<void> addServer({required AddServerRequest request}) async {
    final Server server = await _platformApi.addServer(request: request);

    _serverController.add(
      List.of(_serverController.value ?? [])..add(server),
    );
  }

  @override
  Future<void> updateServer({required UpdateServerRequest request}) async {
    final Server server = await _platformApi.updateServer(request: request);

    final List<Server> servers = List.of(_serverController.value!);
    final int index = servers.indexWhere((element) => element.id == server.id);
    if (index == -1) throw Exception('Server not found');
    servers[index] = server;

    _serverController.add(servers);
  }

  @override
  Future<Server> getServerById({required int id}) => _platformApi.getServerById(id: id);

  @override
  Future<void> setSelectedServerId({required int id}) async {
    await _platformApi.setSelectedServerId(id: id);
    _selectedServerIdController.add(id);
  }

  @override
  Future<int?> getSelectedServerId() => _platformApi.getSelectedServerId();

  @override
  Future<void> deleteServer({required int serverId}) async {
    await _platformApi.removeServer(id: serverId);

    final List<Server> servers = List.of(_serverController.value!);
    final int index = servers.indexWhere((element) => element.id == serverId);
    if (index == -1) throw Exception('Server not found');
    servers.removeAt(index);
    _serverController.add(servers);
  }

  @override
  Future<void> dispose() async {
    await _selectedServerIdController.close();
    await _serverController.close();
  }
}
