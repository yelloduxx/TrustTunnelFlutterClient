import 'package:vpn/data/datasources/cached_sources/cached_datasource.dart';
import 'package:vpn/data/model/server.dart';

class ServerCachedDatasourceImpl implements CachedDataSource<Server> {
  final Map<int, Server> _cache = {};

  @override
  Future<Server?> getById({required int id}) async => _cache[id];

  @override
  Future<List<Server>> getAll() async => _cache.values.toList();

  @override
  Future<void> save({required Server entity}) async => _cache[entity.id] = entity;

  @override
  Future<void> update({required Server entity}) async => _cache[entity.id] = entity;

  @override
  Future<void> delete({required int id}) async => _cache.remove(id);

  @override
  Future<void> clear() async => _cache.clear();
}
