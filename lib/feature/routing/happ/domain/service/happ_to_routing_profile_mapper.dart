import 'package:meta/meta.dart';
import 'package:trusttunnel/data/model/routing_mode.dart';
import 'package:trusttunnel/feature/routing/happ/model/happ_outbound.dart';
import 'package:trusttunnel/feature/routing/happ/model/happ_route_order.dart';
import 'package:trusttunnel/feature/routing/happ/model/happ_routing_config.dart';

@immutable
class HappRoutingMappingResult {
  final RoutingMode defaultMode;
  final List<String> bypassRules;
  final List<String> vpnRules;
  final int unsupportedBlockRules;

  const HappRoutingMappingResult({
    required this.defaultMode,
    required this.bypassRules,
    required this.vpnRules,
    required this.unsupportedBlockRules,
  });
}

final class HappToRoutingProfileMapper {
  const HappToRoutingProfileMapper();

  HappRoutingMappingResult map({
    required HappRoutingConfig config,
    required Map<String, Set<String>> geosite,
    required Map<String, Set<String>> geoip,
  }) {
    final directExpanded = _expandRules(
      rawRules: [
        ...config.directSites,
        ...config.directIp,
      ],
      geosite: geosite,
      geoip: geoip,
    );

    final proxyExpanded = _expandRules(
      rawRules: [
        ...config.proxySites,
        ...config.proxyIp,
      ],
      geosite: geosite,
      geoip: geoip,
    );

    final blockExpanded = _expandRules(
      rawRules: [
        ...config.blockSites,
        ...config.blockIp,
      ],
      geosite: geosite,
      geoip: geoip,
    );

    final pickedRules = _pickByRoutePriority(
      routeOrder: config.routeOrder,
      directRules: directExpanded,
      proxyRules: proxyExpanded,
      blockRules: blockExpanded,
    );

    return HappRoutingMappingResult(
      defaultMode: config.globalProxy ? RoutingMode.vpn : RoutingMode.bypass,
      bypassRules: pickedRules.$1.toList(),
      vpnRules: pickedRules.$2.toList(),
      unsupportedBlockRules: pickedRules.$3,
    );
  }

  Set<String> _expandRules({
    required List<String> rawRules,
    required Map<String, Set<String>> geosite,
    required Map<String, Set<String>> geoip,
  }) {
    final result = <String>{};

    for (final raw in rawRules) {
      final trimmed = raw.trim();
      if (trimmed.isEmpty) {
        continue;
      }

      final lower = trimmed.toLowerCase();
      if (lower.startsWith('geosite:')) {
        final tag = lower.substring('geosite:'.length).trim();
        if (tag.isEmpty) {
          continue;
        }

        result.addAll(geosite[tag] ?? const <String>{});
        continue;
      }

      if (lower.startsWith('geoip:')) {
        final tag = lower.substring('geoip:'.length).trim();
        if (tag.isEmpty) {
          continue;
        }

        result.addAll(geoip[tag] ?? const <String>{});
        continue;
      }

      result.add(lower);
    }

    return result;
  }

  (Set<String>, Set<String>, int) _pickByRoutePriority({
    required HappRouteOrder routeOrder,
    required Set<String> directRules,
    required Set<String> proxyRules,
    required Set<String> blockRules,
  }) {
    final map = <String, Set<HappOutbound>>{};

    for (final rule in directRules) {
      (map[rule] ??= <HappOutbound>{}).add(HappOutbound.direct);
    }
    for (final rule in proxyRules) {
      (map[rule] ??= <HappOutbound>{}).add(HappOutbound.proxy);
    }
    for (final rule in blockRules) {
      (map[rule] ??= <HappOutbound>{}).add(HappOutbound.block);
    }

    final pickedDirect = <String>{};
    final pickedProxy = <String>{};
    var unsupportedBlockRules = 0;

    for (final entry in map.entries) {
      final assigned = _pickFirstMatchingOrder(routeOrder.values, entry.value);
      if (assigned == null) {
        continue;
      }

      switch (assigned) {
        case HappOutbound.direct:
          pickedDirect.add(entry.key);
        case HappOutbound.proxy:
          pickedProxy.add(entry.key);
        case HappOutbound.block:
          unsupportedBlockRules += 1;
      }
    }

    return (pickedDirect, pickedProxy, unsupportedBlockRules);
  }

  HappOutbound? _pickFirstMatchingOrder(List<HappOutbound> order, Set<HappOutbound> values) {
    for (final item in order) {
      if (values.contains(item)) {
        return item;
      }
    }

    return null;
  }
}
