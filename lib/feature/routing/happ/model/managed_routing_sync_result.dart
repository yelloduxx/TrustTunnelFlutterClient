import 'package:meta/meta.dart';

@immutable
class ManagedRoutingSyncResult {
  final int profileId;
  final bool updated;
  final String? error;

  const ManagedRoutingSyncResult({
    required this.profileId,
    required this.updated,
    required this.error,
  });

  const ManagedRoutingSyncResult.updated({
    required int profileId,
  }) : this(
         profileId: profileId,
         updated: true,
         error: null,
       );

  const ManagedRoutingSyncResult.noChanges({
    required int profileId,
  }) : this(
         profileId: profileId,
         updated: false,
         error: null,
       );

  const ManagedRoutingSyncResult.failed({
    required int profileId,
    required String error,
  }) : this(
         profileId: profileId,
         updated: false,
         error: error,
       );
}
