import 'package:drift/drift.dart';
import 'package:trusttunnel/data/database/app_database.dart' as db;
import 'package:trusttunnel/data/datasources/routing_datasource.dart';
import 'package:trusttunnel/data/model/managed_routing_source.dart';
import 'package:trusttunnel/data/model/raw/add_routing_profile_request.dart';
import 'package:trusttunnel/data/model/routing_mode.dart';
import 'package:trusttunnel/data/model/routing_profile.dart';

/// {@template routing_data_source_impl}
/// Drift-backed implementation of [RoutingDataSource].
///
/// This implementation stores routing profiles and their rules in a relational
/// schema using Drift:
/// - profile metadata is stored in `routingProfiles`,
/// - individual rules are stored in `profileRules` with a `mode` discriminator.
///
/// ### Consistency notes
/// Some operations perform multiple SQL statements (insert profile, then insert
/// rules). If you require strict atomicity across these statements, consider
/// wrapping calls in a Drift transaction at a higher level.
/// {@endtemplate}
class RoutingDataSourceImpl implements RoutingDataSource {
  /// Drift database used for persistence.
  final db.AppDatabase database;

  /// {@macro routing_data_source_impl}
  RoutingDataSourceImpl(this.database);

  /// {@macro routing_data_source_add_new_profile}
  @override
  Future<RoutingProfile> addNewProfile(AddRoutingProfileRequest request) async {
    final resultId = await database.routingProfiles.insertOnConflictUpdate(
      db.RoutingProfilesCompanion.insert(
        name: request.name,
        defaultMode: request.defaultMode.value,
      ),
    );

    final bypassRules = request.bypassRules.map(
      (rule) => db.ProfileRulesCompanion.insert(
        profileId: resultId,
        mode: RoutingMode.bypass.value,
        data: rule,
      ),
    );

    final vpnRules = request.vpnRules.map(
      (rule) => db.ProfileRulesCompanion.insert(
        profileId: resultId,
        mode: RoutingMode.vpn.value,
        data: rule,
      ),
    );

    await database.profileRules.insertAll(
      [
        ...bypassRules,
        ...vpnRules,
      ],
    );

    return RoutingProfile(
      id: resultId,
      name: request.name,
      defaultMode: request.defaultMode,
      bypassRules: request.bypassRules,
      vpnRules: request.vpnRules,
    );
  }

  /// {@macro routing_data_source_get_all_profiles}
  ///
  /// This method loads profiles first, then loads all rules for the retrieved
  /// profile ids, and finally assembles [RoutingProfile] instances.
  @override
  Future<List<RoutingProfile>> getAllProfiles() async {
    final profiles = await database.select(database.routingProfiles).get();
    if (profiles.isEmpty) return [];

    final profileIds = profiles.map((p) => p.id).toSet();
    final rules = await _loadRulesOfProfiles(profileIds);

    final bypassByProfile = <int, List<String>>{};
    final vpnByProfile = <int, List<String>>{};

    for (final r in rules) {
      if (r.mode == RoutingMode.bypass.value) {
        (bypassByProfile[r.profileId] ??= <String>[]).add(r.data);
      } else if (r.mode == RoutingMode.vpn.value) {
        (vpnByProfile[r.profileId] ??= <String>[]).add(r.data);
      }
    }

    return profiles.map((p) {
      final defaultMode = RoutingMode.values.firstWhere((m) => m.value == p.defaultMode);

      return RoutingProfile(
        id: p.id,
        name: p.name,
        defaultMode: defaultMode,
        bypassRules: bypassByProfile[p.id] ?? const [],
        vpnRules: vpnByProfile[p.id] ?? const [],
      );
    }).toList();
  }

  /// {@macro routing_data_source_set_default_mode}
  @override
  Future<void> setDefaultRoutingMode({required int id, required RoutingMode mode}) async {
    final updateStatement = database.update(
      database.routingProfiles,
    );
    updateStatement.where((p) => p.id.equals(id));
    await updateStatement.write(db.RoutingProfilesCompanion(defaultMode: Value(mode.value)));
  }

  /// {@macro routing_data_source_set_profile_name}
  @override
  Future<void> setProfileName({required int id, required String name}) async {
    final updateStatement = database.update(
      database.routingProfiles,
    );
    updateStatement.where((p) => p.id.equals(id));
    await updateStatement.write(db.RoutingProfilesCompanion(name: Value(name)));
  }

  /// {@macro routing_data_source_set_rules}
  ///
  /// Existing rules for the `[profileId, mode]` pair are deleted first, then the
  /// new list is inserted in a batch.
  @override
  Future<void> setRules({required int id, required RoutingMode mode, required List<String> rules}) async {
    await database.profileRules.deleteWhere((p) => p.profileId.equals(id) & p.mode.equals(mode.value));

    return database.batch((batch) {
      batch.insertAllOnConflictUpdate(
        database.profileRules,
        rules.map(
          (data) => db.ProfileRulesCompanion.insert(
            profileId: id,
            mode: mode.value,
            data: data,
          ),
        ),
      );
    });
  }

  /// {@macro routing_data_source_remove_all_rules}
  @override
  Future<void> removeAllRules({required int id}) async {
    final deleteStatement = database.delete(
      database.profileRules,
    );
    deleteStatement.where((p) => p.profileId.equals(id));
    await deleteStatement.go();
  }

  /// {@macro routing_data_source_get_profile_by_id}
  ///
  /// Throws a generic [Exception] when the profile row does not exist.
  @override
  Future<RoutingProfile> getProfileById({required int id}) async {
    final profile = await (database.routingProfiles.select()..where((p) => p.id.equals(id))).getSingleOrNull();
    if (profile == null) throw Exception('Profile not found');

    final rules = await _loadRulesOfProfiles({id});

    final bypassRules = rules.where((r) => r.mode == RoutingMode.bypass.value).map((r) => r.data).toList();
    final vpnRules = rules.where((r) => r.mode == RoutingMode.vpn.value).map((r) => r.data).toList();

    return RoutingProfile(
      id: profile.id,
      name: profile.name,
      defaultMode: RoutingMode.values.firstWhere((m) => m.value == profile.defaultMode),
      bypassRules: bypassRules,
      vpnRules: vpnRules,
    );
  }

  /// {@macro routing_data_source_delete_profile}
  ///
  /// If there are servers referencing the profile being deleted, this
  /// implementation reassigns them to another existing profile (the first one
  /// returned by the database query) before removing the profile row.
  @override
  Future<void> deleteProfile({required int id}) async {
    final servers = await (database.select(database.servers)..where((s) => s.routingProfileId.equals(id))).get();
    if (servers.isNotEmpty) {
      final replacedConfig =
          await (database.select(database.routingProfiles)
                ..where((p) => p.id.isNotValue(id))
                ..limit(1))
              .getSingle();

      database.batch((batch) {
        batch.update(
          database.servers,
          db.ServersCompanion(
            routingProfileId: Value(replacedConfig.id),
          ),
          where: (s) => s.id.isIn(servers.map((s) => s.id)),
        );
      });
    }

    final deleteStatement = database.delete(
      database.routingProfiles,
    );
    deleteStatement.where((p) => p.id.equals(id));
    await deleteStatement.go();
  }

  @override
  Future<ManagedRoutingSource?> getManagedSourceByProfileId({required int profileId}) async {
    final row =
        await (database.select(database.managedRoutingSources)..where((tbl) => tbl.profileId.equals(profileId)))
            .getSingleOrNull();

    if (row == null) {
      return null;
    }

    return _toManagedSource(row);
  }

  @override
  Future<List<ManagedRoutingSource>> getManagedSources() async {
    final rows = await database.select(database.managedRoutingSources).get();

    return rows.map(_toManagedSource).toList();
  }

  @override
  Future<void> upsertManagedSource({required ManagedRoutingSource source}) => database
      .into(database.managedRoutingSources)
      .insertOnConflictUpdate(
        db.ManagedRoutingSourcesCompanion.insert(
          profileId: Value(source.profileId),
          sourceUrl: source.sourceUrl,
          geositeUrl: source.geositeUrl,
          geoipUrl: source.geoipUrl,
          routeOrder: source.routeOrder.join(','),
          globalMode: source.globalMode.value,
          syncEnabled: Value(source.syncEnabled),
          localOverride: Value(source.localOverride),
          contentHash: Value(source.contentHash),
          eTag: Value(source.eTag),
          unsupportedBlockRules: Value(source.unsupportedBlockRules),
          lastSuccessAt: Value(source.lastSuccessAt?.toIso8601String()),
          lastErrorAt: Value(source.lastErrorAt?.toIso8601String()),
          lastErrorMessage: Value(source.lastErrorMessage),
          createdAt: source.createdAt.toIso8601String(),
          updatedAt: source.updatedAt.toIso8601String(),
        ),
      );

  @override
  Future<void> deleteManagedSource({required int profileId}) =>
      database.managedRoutingSources.deleteWhere((tbl) => tbl.profileId.equals(profileId));

  /// Loads all rule rows for the given profile ids.
  ///
  /// Rules are returned in insertion order (ascending by row id).
  Future<List<db.ProfileRule>> _loadRulesOfProfiles(Set<int> profileIds) async {
    final select = database.select(database.profileRules)
      ..where((r) => r.profileId.isIn(profileIds))
      ..orderBy(
        [
          (r) => OrderingTerm.asc(
            r.rowId,
          ),
        ],
      );

    return select.get();
  }

  ManagedRoutingSource _toManagedSource(db.ManagedRoutingSource row) => ManagedRoutingSource(
    profileId: row.profileId,
    sourceUrl: row.sourceUrl,
    geositeUrl: row.geositeUrl,
    geoipUrl: row.geoipUrl,
    routeOrder: row.routeOrder
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(),
    globalMode: ManagedRoutingGlobalMode.parse(row.globalMode),
    syncEnabled: row.syncEnabled,
    localOverride: row.localOverride,
    contentHash: row.contentHash,
    eTag: row.eTag,
    unsupportedBlockRules: row.unsupportedBlockRules,
    lastSuccessAt: row.lastSuccessAt == null ? null : DateTime.tryParse(row.lastSuccessAt!),
    lastErrorAt: row.lastErrorAt == null ? null : DateTime.tryParse(row.lastErrorAt!),
    lastErrorMessage: row.lastErrorMessage,
    createdAt: DateTime.tryParse(row.createdAt) ?? DateTime.fromMillisecondsSinceEpoch(0),
    updatedAt: DateTime.tryParse(row.updatedAt) ?? DateTime.fromMillisecondsSinceEpoch(0),
  );
}
