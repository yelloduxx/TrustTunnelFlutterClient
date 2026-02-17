import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

enum ManagedRoutingGlobalMode {
  proxy('proxy'),
  direct('direct');

  final String value;

  const ManagedRoutingGlobalMode(this.value);

  static ManagedRoutingGlobalMode parse(String value) => ManagedRoutingGlobalMode.values.firstWhere(
    (element) => element.value == value,
    orElse: () => ManagedRoutingGlobalMode.proxy,
  );
}

@immutable
class ManagedRoutingSource {
  final int profileId;
  final String sourceUrl;
  final String geositeUrl;
  final String geoipUrl;
  final List<String> routeOrder;
  final ManagedRoutingGlobalMode globalMode;
  final bool syncEnabled;
  final bool localOverride;
  final String? contentHash;
  final String? eTag;
  final int unsupportedBlockRules;
  final DateTime? lastSuccessAt;
  final DateTime? lastErrorAt;
  final String? lastErrorMessage;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ManagedRoutingSource({
    required this.profileId,
    required this.sourceUrl,
    required this.geositeUrl,
    required this.geoipUrl,
    required this.routeOrder,
    required this.globalMode,
    required this.syncEnabled,
    required this.localOverride,
    required this.contentHash,
    required this.eTag,
    required this.unsupportedBlockRules,
    required this.lastSuccessAt,
    required this.lastErrorAt,
    required this.lastErrorMessage,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  int get hashCode => Object.hash(
    profileId,
    sourceUrl,
    geositeUrl,
    geoipUrl,
    Object.hashAll(routeOrder),
    globalMode,
    syncEnabled,
    localOverride,
    contentHash,
    eTag,
    unsupportedBlockRules,
    lastSuccessAt,
    lastErrorAt,
    lastErrorMessage,
    createdAt,
    updatedAt,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ManagedRoutingSource &&
          profileId == other.profileId &&
          sourceUrl == other.sourceUrl &&
          geositeUrl == other.geositeUrl &&
          geoipUrl == other.geoipUrl &&
          listEquals(routeOrder, other.routeOrder) &&
          globalMode == other.globalMode &&
          syncEnabled == other.syncEnabled &&
          localOverride == other.localOverride &&
          contentHash == other.contentHash &&
          eTag == other.eTag &&
          unsupportedBlockRules == other.unsupportedBlockRules &&
          lastSuccessAt == other.lastSuccessAt &&
          lastErrorAt == other.lastErrorAt &&
          lastErrorMessage == other.lastErrorMessage &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  ManagedRoutingSource copyWith({
    int? profileId,
    String? sourceUrl,
    String? geositeUrl,
    String? geoipUrl,
    List<String>? routeOrder,
    ManagedRoutingGlobalMode? globalMode,
    bool? syncEnabled,
    bool? localOverride,
    String? contentHash,
    String? eTag,
    int? unsupportedBlockRules,
    DateTime? lastSuccessAt,
    DateTime? lastErrorAt,
    String? lastErrorMessage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => ManagedRoutingSource(
    profileId: profileId ?? this.profileId,
    sourceUrl: sourceUrl ?? this.sourceUrl,
    geositeUrl: geositeUrl ?? this.geositeUrl,
    geoipUrl: geoipUrl ?? this.geoipUrl,
    routeOrder: routeOrder ?? this.routeOrder,
    globalMode: globalMode ?? this.globalMode,
    syncEnabled: syncEnabled ?? this.syncEnabled,
    localOverride: localOverride ?? this.localOverride,
    contentHash: contentHash ?? this.contentHash,
    eTag: eTag ?? this.eTag,
    unsupportedBlockRules: unsupportedBlockRules ?? this.unsupportedBlockRules,
    lastSuccessAt: lastSuccessAt ?? this.lastSuccessAt,
    lastErrorAt: lastErrorAt ?? this.lastErrorAt,
    lastErrorMessage: lastErrorMessage ?? this.lastErrorMessage,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
