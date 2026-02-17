import 'package:meta/meta.dart';

@immutable
class RoutingSyncSettings {
  final bool enabled;
  final int intervalMinutes;
  final DateTime updatedAt;

  const RoutingSyncSettings({
    required this.enabled,
    required this.intervalMinutes,
    required this.updatedAt,
  });

  @override
  int get hashCode => Object.hash(enabled, intervalMinutes, updatedAt);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoutingSyncSettings &&
          enabled == other.enabled &&
          intervalMinutes == other.intervalMinutes &&
          updatedAt == other.updatedAt;

  RoutingSyncSettings copyWith({
    bool? enabled,
    int? intervalMinutes,
    DateTime? updatedAt,
  }) => RoutingSyncSettings(
    enabled: enabled ?? this.enabled,
    intervalMinutes: intervalMinutes ?? this.intervalMinutes,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
