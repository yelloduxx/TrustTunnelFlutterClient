import 'package:vpn/data/datasources/cached_sources/cached_datasource.dart';
import 'package:vpn/data/model/vpn_request.dart';

abstract class SettingsCachedDatasource extends BaseCachedDatasource {
  Future<List<VpnRequest>> getAllRequests();

  Future<void> addRequests(List<VpnRequest> requests);

  Future<void> setExcludedRoutes(String routes);

  Future<String> getExcludedRoutes();
}

class SettingsCachedDatasourceImpl implements SettingsCachedDatasource {
  Set<VpnRequest> _requestsCache = {};
  String _excludedRoutes = '';

  @override
  Future<void> addRequests(List<VpnRequest> requests) async => _requestsCache = requests.toSet();

  @override
  Future<List<VpnRequest>> getAllRequests() async => _requestsCache.toList();

  @override
  Future<String> getExcludedRoutes() async => _excludedRoutes;

  @override
  Future<void> setExcludedRoutes(String routes) async {
    _excludedRoutes = routes;
  }

  @override
  Future<void> clear() async {
    _requestsCache.clear();
    _excludedRoutes = '';
  }
}
