import 'package:drift/drift.dart';
import 'package:trusttunnel/data/database/app_database.dart' as db;
import 'package:trusttunnel/data/datasources/settings_datasource.dart';
import 'package:trusttunnel/data/model/routing_sync_settings.dart';

/// {@template settings_data_source_impl}
/// Drift-backed implementation of [SettingsDataSource].
///
/// Excluded routes are stored as a plain list of string rows. Updates replace
/// the entire list (delete all + insert all).
/// {@endtemplate}
class SettingsDataSourceImpl implements SettingsDataSource {
  /// Drift database used for persistence.
  final db.AppDatabase database;

  /// {@macro settings_data_source_impl}
  SettingsDataSourceImpl({required this.database});

  /// {@macro settings_data_source_get_excluded_routes}
  @override
  Future<List<String>> getExcludedRoutes() async {
    final unparsedResult = await database.excludedRoutes.select().get();

    return unparsedResult.map((e) => e.value).toList();
  }

  /// {@macro settings_data_source_set_excluded_routes}
  ///
  /// The stored list is replaced atomically from the perspective of this method:
  /// all existing rows are removed, then the new set is inserted.
  @override
  Future<void> setExcludedRoutes(List<String> routes) async {
    await database.excludedRoutes.deleteAll();
    await database.excludedRoutes.insertAll(
      routes.map(
        (e) => db.ExcludedRoutesCompanion.insert(
          value: e,
        ),
      ),
    );
  }

  @override
  Future<RoutingSyncSettings> getRoutingSyncSettings() async {
    final row = await (database.select(database.routingSyncSettings)..where((tbl) => tbl.id.equals(0))).getSingleOrNull();
    if (row == null) {
      final now = DateTime.now().toIso8601String();
      await database.into(database.routingSyncSettings).insert(
        db.RoutingSyncSettingsCompanion.insert(
          id: const Value(0),
          enabled: const Value(true),
          intervalMinutes: const Value(30),
          updatedAt: now,
        ),
      );

      return RoutingSyncSettings(
        enabled: true,
        intervalMinutes: 30,
        updatedAt: DateTime.parse(now),
      );
    }

    return RoutingSyncSettings(
      enabled: row.enabled,
      intervalMinutes: row.intervalMinutes,
      updatedAt: DateTime.tryParse(row.updatedAt) ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  @override
  Future<void> setRoutingSyncSettings({
    required bool enabled,
    required int intervalMinutes,
  }) async {
    await database.into(database.routingSyncSettings).insertOnConflictUpdate(
      db.RoutingSyncSettingsCompanion.insert(
        id: const Value(0),
        enabled: Value(enabled),
        intervalMinutes: Value(intervalMinutes),
        updatedAt: DateTime.now().toIso8601String(),
      ),
    );
  }
}
