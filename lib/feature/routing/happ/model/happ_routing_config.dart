import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:trusttunnel/feature/routing/happ/model/happ_route_order.dart';

@immutable
class HappRoutingConfig {
  final String name;
  final bool globalProxy;
  final String geositeUrl;
  final String geoipUrl;
  final List<String> directSites;
  final List<String> directIp;
  final List<String> proxySites;
  final List<String> proxyIp;
  final List<String> blockSites;
  final List<String> blockIp;
  final HappRouteOrder routeOrder;
  final String sourceUrl;

  const HappRoutingConfig({
    required this.name,
    required this.globalProxy,
    required this.geositeUrl,
    required this.geoipUrl,
    required this.directSites,
    required this.directIp,
    required this.proxySites,
    required this.proxyIp,
    required this.blockSites,
    required this.blockIp,
    required this.routeOrder,
    required this.sourceUrl,
  });

  factory HappRoutingConfig.fromSource({
    required String sourceUrl,
    required String jsonPayload,
  }) {
    final root = jsonDecode(jsonPayload);
    if (root is! Map<String, dynamic>) {
      throw const FormatException('Invalid HAPP routing config payload');
    }

    final name = (root['Name'] ?? root['name'] ?? 'HAPP profile').toString().trim();
    final globalProxy = _parseBool(root['GlobalProxy'] ?? root['globalProxy'], fallback: true);
    final geositeUrl = (root['Geositeurl'] ?? root['geositeUrl'] ?? '').toString().trim();
    final geoipUrl = (root['Geoipurl'] ?? root['geoipUrl'] ?? '').toString().trim();

    if (geositeUrl.isEmpty || geoipUrl.isEmpty) {
      throw const FormatException('HAPP routing config must include Geoipurl and Geositeurl');
    }

    return HappRoutingConfig(
      name: name.isEmpty ? 'HAPP profile' : name,
      globalProxy: globalProxy,
      geositeUrl: geositeUrl,
      geoipUrl: geoipUrl,
      directSites: _toStringList(root['DirectSites'] ?? root['directSites']),
      directIp: _toStringList(root['DirectIp'] ?? root['directIp']),
      proxySites: _toStringList(root['ProxySites'] ?? root['proxySites']),
      proxyIp: _toStringList(root['ProxyIp'] ?? root['proxyIp']),
      blockSites: _toStringList(root['BlockSites'] ?? root['blockSites']),
      blockIp: _toStringList(root['BlockIp'] ?? root['blockIp']),
      routeOrder: HappRouteOrder.parse((root['OrderRouting'] ?? root['RouteOrder'] ?? root['routeOrder'])?.toString()),
      sourceUrl: sourceUrl,
    );
  }

  String stableHashPayload() => jsonEncode({
    'name': name,
    'globalProxy': globalProxy,
    'geositeUrl': geositeUrl,
    'geoipUrl': geoipUrl,
    'directSites': directSites,
    'directIp': directIp,
    'proxySites': proxySites,
    'proxyIp': proxyIp,
    'blockSites': blockSites,
    'blockIp': blockIp,
    'routeOrder': routeOrder.serialize(),
    'sourceUrl': sourceUrl,
  });

  static List<String> _toStringList(Object? raw) {
    if (raw is! List) {
      return const [];
    }

    return raw.map((item) => item.toString().trim()).where((item) => item.isNotEmpty).toList();
  }

  static bool _parseBool(Object? raw, {required bool fallback}) {
    if (raw == null) {
      return fallback;
    }

    final value = raw.toString().trim().toLowerCase();

    return switch (value) {
      'true' || '1' || 'yes' => true,
      'false' || '0' || 'no' => false,
      _ => fallback,
    };
  }

  @override
  int get hashCode => Object.hash(
    name,
    globalProxy,
    geositeUrl,
    geoipUrl,
    Object.hashAll(directSites),
    Object.hashAll(directIp),
    Object.hashAll(proxySites),
    Object.hashAll(proxyIp),
    Object.hashAll(blockSites),
    Object.hashAll(blockIp),
    routeOrder,
    sourceUrl,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HappRoutingConfig &&
          name == other.name &&
          globalProxy == other.globalProxy &&
          geositeUrl == other.geositeUrl &&
          geoipUrl == other.geoipUrl &&
          listEquals(directSites, other.directSites) &&
          listEquals(directIp, other.directIp) &&
          listEquals(proxySites, other.proxySites) &&
          listEquals(proxyIp, other.proxyIp) &&
          listEquals(blockSites, other.blockSites) &&
          listEquals(blockIp, other.blockIp) &&
          routeOrder == other.routeOrder &&
          sourceUrl == other.sourceUrl;
}
