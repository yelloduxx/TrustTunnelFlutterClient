import 'package:drift/drift.dart';
import 'package:vpn/feature/routing/routing/common/routing_profile_utils.dart';
import 'connection.dart' as impl;

part 'app_database.g.dart';

@DriftDatabase(
  include: {'tables/index.drift'},
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(impl.connect());
  AppDatabase.inMemory(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
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
            defaultMode: 1,
            id: const Value(RoutingProfileUtils.defaultRoutingProfileId)
          ),
        );
      }
    },
  );
}
