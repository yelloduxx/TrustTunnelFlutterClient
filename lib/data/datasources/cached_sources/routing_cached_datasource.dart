import 'package:vpn/data/datasources/cached_sources/cached_datasource.dart';
import 'package:vpn/data/model/routing_profile.dart';

class RoutingCachedDatasourceImpl implements CachedDataSource<RoutingProfile> {
  final Map<int, RoutingProfile> _cache = {};

  @override
  Future<List<RoutingProfile>> getAll() async => _cache.values.toList();

  @override
  Future<RoutingProfile?> getById({required int id}) async => _cache[id];

  @override
  Future<void> save({required RoutingProfile entity}) async => _cache[entity.id] = entity;

  @override
  Future<void> update({required RoutingProfile entity}) async => _cache[entity.id] = entity;

  @override
  Future<void> delete({required int id}) async => _cache.remove(id);

  @override
  Future<void> clear() async => _cache.clear();
}
