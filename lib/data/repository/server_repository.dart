import 'dart:async';
import 'package:vpn/data/datasources/routing_datasource.dart';
import 'package:vpn/data/datasources/server_datasource.dart';
import 'package:vpn/data/model/raw/add_server_request.dart';
import 'package:vpn/data/model/server.dart';

abstract class ServerRepository {
  Future<Server> addNewServer({required AddServerRequest request});

  Future<List<Server>> getAllServers();

  Future<Server?> getServerById({required int id});

  Future<void> setSelectedServerId({required int id});

  Future<void> setNewServer({required int id, required AddServerRequest request});

  Future<void> removeServer({required int serverId});
}

class ServerRepositoryImpl implements ServerRepository {
  final ServerDatasource _serverDatasource;
  final RoutingDatasource _routingDatasource;

  ServerRepositoryImpl({
    required ServerDatasource serverDatasource,
    required RoutingDatasource routingDatasource,
  }) : _serverDatasource = serverDatasource,
       _routingDatasource = routingDatasource;

  @override
  Future<Server> addNewServer({required AddServerRequest request}) async {
    final server = await _serverDatasource.addNewServer(
      request: request,
    );

    final profile = await _routingDatasource.getProfileById(
      id: request.routingProfileId,
    );

    return Server(
      id: server.id,
      name: server.name,
      ipAddress: server.ipAddress,
      domain: server.domain,
      username: server.username,
      password: server.password,
      vpnProtocol: server.vpnProtocol,
      dnsServers: server.dnsServers,
      routingProfile: profile,
    );
  }

  @override
  Future<List<Server>> getAllServers() async {
    final profiles = await _routingDatasource.getAllProfiles();
    final servers = await _serverDatasource.getAllServers();
    final profilesMap = Map.fromEntries(profiles.map((e) => MapEntry(e.id, e)));
    return servers
        .map(
          (e) => Server(
            id: e.id,
            name: e.name,
            ipAddress: e.ipAddress,
            domain: e.domain,
            username: e.username,
            password: e.password,
            vpnProtocol: e.vpnProtocol,
            dnsServers: e.dnsServers,
            routingProfile: profilesMap[e.routingProfileId]!,
            selected: e.selected,
          ),
        )
        .toList();
  }

  @override
  Future<void> setNewServer({required int id, required AddServerRequest request}) =>
      _serverDatasource.setNewServer(id: id, request: request);

  @override
  Future<void> setSelectedServerId({required int id}) => _serverDatasource.setSelectedServerId(id: id);

  @override
  Future<void> removeServer({required int serverId}) => _serverDatasource.removeServer(serverId: serverId);

  @override
  Future<Server?> getServerById({required int id}) async {
    final server = await _serverDatasource.getServerById(id: id);
    final profile = await _routingDatasource.getProfileById(id: server.routingProfileId);
    return Server(
      id: server.id,
      name: server.name,
      ipAddress: server.ipAddress,
      domain: server.domain,
      username: server.username,
      password: server.password,
      vpnProtocol: server.vpnProtocol,
      dnsServers: server.dnsServers,
      routingProfile: profile,
      selected: server.selected,
    );
  }
}
