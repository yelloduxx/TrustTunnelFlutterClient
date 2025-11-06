import 'package:vpn/data/model/raw/add_server_request.dart';
import 'package:vpn/data/model/raw/raw_server.dart';

abstract class ServerDatasource {
  Future<RawServer> addNewServer({required AddServerRequest request});

  Future<RawServer> getServerById({required int id});

  Future<List<RawServer>> getAllServers();

  Future<void> setSelectedServerId({required int id});

  Future<void> removeServer({required int serverId});

  Future<void> setNewServer({required int id, required AddServerRequest request});
}
