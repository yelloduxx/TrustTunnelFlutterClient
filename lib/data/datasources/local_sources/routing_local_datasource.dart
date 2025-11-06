import 'package:drift/drift.dart';
import 'package:vpn/data/datasources/routing_datasource.dart';
import 'package:vpn/data/model/raw/add_routing_profile_request.dart';
import 'package:vpn/data/model/routing_mode.dart';
import 'package:vpn/data/model/routing_profile.dart';
import 'package:vpn/data/database/app_database.dart' as db;

class RoutingLocalDatasource implements RoutingDatasource {
  final db.AppDatabase database;

  RoutingLocalDatasource(this.database);

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

  @override
  Future<List<RoutingProfile>> getAllProfiles() async {
    final profiles = await database.select(database.routingProfiles).get();
    if (profiles.isEmpty) return [];

    final profileIds = profiles.map((p) => p.id).toList();
    final rules = await (database.select(database.profileRules)..where((r) => r.profileId.isIn(profileIds))).get();

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

  @override
  Future<void> setDefaultRoutingMode({required int id, required RoutingMode mode}) async {
    final updateStatement = database.update(
      database.routingProfiles,
    );
    updateStatement.where((p) => p.id.equals(id));
    await updateStatement.write(db.RoutingProfilesCompanion(defaultMode: Value(mode.value)));
  }

  @override
  Future<void> setProfileName({required int id, required String name}) async {
    final updateStatement = database.update(
      database.routingProfiles,
    );
    updateStatement.where((p) => p.id.equals(id));
    await updateStatement.write(db.RoutingProfilesCompanion(name: Value(name)));
  }

  @override
  Future<void> setRules({required int id, required RoutingMode mode, required String rules}) async {
    final updateStatement = database.update(
      database.profileRules,
    );
    updateStatement.where((p) => p.profileId.equals(id) & p.mode.equals(mode.value));
    await updateStatement.write(db.ProfileRulesCompanion(data: Value(rules)));
  }

  @override
  Future<void> removeAllRules({required int id}) async {
    final deleteStatement = database.delete(
      database.profileRules,
    );
    deleteStatement.where((p) => p.profileId.equals(id));
    await deleteStatement.go();
  }

  @override
  Future<RoutingProfile> getProfileById({required int id}) async {
    final profile = await (database.routingProfiles.select()..where((p) => p.id.equals(id))).getSingleOrNull();
    if (profile == null) throw Exception('Profile not found');

    final rules = await (database.select(database.profileRules)..where((r) => r.profileId.equals(id))).get();
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
            selected: Value(false),
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
}
