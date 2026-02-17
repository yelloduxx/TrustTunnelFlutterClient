import 'package:drift/drift.dart';
import 'package:trusttunnel/common/utils/routing_profile_utils.dart';
import 'connection.dart' as impl;

part 'app_database.g.dart';

@DriftDatabase(
  include: {'tables/index.drift'},
)
class AppDatabase extends _$AppDatabase {
  static const _defaultExcludedRoutes = [
    '10.0.0.0/8',
    '100.64.0.0/10',
    '169.254.0.0/16',
    '172.16.0.0/12',
    '192.0.0.0/24',
    '192.168.0.0/16',
    '255.255.255.255/32',
  ];

  AppDatabase() : super(impl.connect());
  AppDatabase.inMemory(super.e);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      final now = DateTime.now().toIso8601String();
      if (await routingModes.count().getSingle() == 0) {
        await into(routingModes).insert(
          RoutingModesCompanion.insert(
            id: const Value(1),
          ),
        );

        await into(routingModes).insert(
          RoutingModesCompanion.insert(
            id: const Value(2),
          ),
        );
      }

      if (await protocols.count().getSingle() == 0) {
        await into(protocols).insert(
          ProtocolsCompanion.insert(
            id: const Value(1),
          ),
        );
        await into(protocols).insert(
          ProtocolsCompanion.insert(
            id: const Value(2),
          ),
        );
      }

      if (await vpnRequests.count().getSingle() == 0) {
        await into(vpnRequests).insert(
          VpnRequestsCompanion.insert(
            decision: 1,
            destinationIpAddress: '192.168.0.1',
            protocolName: 'UDP',
            sourceIpAddress: '192.168.0.1',
            zonedDateTime: DateTime.now().add(const Duration(seconds: 1)).toIso8601String(),
          ),
        );
        await into(vpnRequests).insert(
          VpnRequestsCompanion.insert(
            decision: 2,
            destinationIpAddress: '192.168.0.2',
            protocolName: 'UDP',
            sourceIpAddress: '192.168.0.1',
            zonedDateTime: DateTime.now().add(const Duration(seconds: 2)).toIso8601String(),
          ),
        );
        await into(vpnRequests).insert(
          VpnRequestsCompanion.insert(
            decision: 1,
            destinationIpAddress: '192.168.0.3',
            protocolName: 'TCP',
            sourceIpAddress: '192.168.0.1',
            zonedDateTime: DateTime.now().add(const Duration(seconds: 3)).toIso8601String(),
          ),
        );
        await into(vpnRequests).insert(
          VpnRequestsCompanion.insert(
            decision: 2,
            destinationIpAddress: '192.168.0.1',
            protocolName: 'TCP',
            sourceIpAddress: '192.168.0.4',
            zonedDateTime: DateTime.now().add(const Duration(seconds: 4)).toIso8601String(),
          ),
        );
      }

      if (await routingProfiles.count().getSingle() == 0) {
        await into(routingProfiles).insert(
          RoutingProfilesCompanion.insert(
            name: 'Default profile',
            defaultMode: 2,
            id: const Value(RoutingProfileUtils.defaultRoutingProfileId),
          ),
        );

        await excludedRoutes.insertAll(
          _defaultExcludedRoutes.map(
            (e) => ExcludedRoutesCompanion.insert(
              value: e,
            ),
          ),
        );
      }

      if (await routingSyncSettings.count().getSingle() == 0) {
        await into(routingSyncSettings).insert(
          RoutingSyncSettingsCompanion.insert(
            id: const Value(0),
            enabled: const Value(true),
            intervalMinutes: const Value(30),
            updatedAt: now,
          ),
        );
      }
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(managedRoutingSources);
        await m.createTable(routingSyncSettings);

        final count = await routingSyncSettings.count().getSingle();
        if (count == 0) {
          await into(routingSyncSettings).insert(
            RoutingSyncSettingsCompanion.insert(
              id: const Value(0),
              enabled: const Value(true),
              intervalMinutes: const Value(30),
              updatedAt: DateTime.now().toIso8601String(),
            ),
          );
        }
      }
      if (from < 3) {
        await customStatement('ALTER TABLE servers ADD COLUMN subscription_url TEXT');
        await customStatement('ALTER TABLE servers ADD COLUMN subscription_updated_at INTEGER');
      }
    },
  );
}
