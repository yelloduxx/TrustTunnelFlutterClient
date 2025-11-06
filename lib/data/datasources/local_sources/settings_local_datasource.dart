import 'package:drift/drift.dart';
import 'package:vpn/data/database/app_database.dart' as db;
import 'package:vpn/data/datasources/settings_datasource.dart';
import 'package:vpn/data/model/routing_mode.dart';
import 'package:vpn/data/model/vpn_request.dart';

class SettingsLocalDatasource implements SettingsDatasource {
  final db.AppDatabase database;

  SettingsLocalDatasource({required this.database});
  @override
  Future<List<VpnRequest>> getAllRequests() async {
    final unparsedResult = await database.vpnRequests.select().get();
    return unparsedResult
        .map(
          (e) => VpnRequest(
            id: e.id,
            zonedDateTime: DateTime.parse(e.zonedDateTime),
            protocolName: e.protocolName,
            decision: RoutingMode.values.firstWhere((element) => element.value == e.decision),
            sourceIpAddress: e.sourceIpAddress,
            destinationIpAddress: e.destinationIpAddress,
          ),
        )
        .toList();
  }

  @override
  Future<String> getExcludedRoutes() async {
    final unparsedResult = await database.excludedRoutes.select().get();
    return unparsedResult.map((e) => e.value).join('\n');
  }

  @override
  Future<void> setExcludedRoutes(String routes) async {
    await database.excludedRoutes.deleteAll();
    await database.excludedRoutes.insertOne(
      db.ExcludedRoutesCompanion.insert(
        value: routes,
      ),
    );
  }
}
