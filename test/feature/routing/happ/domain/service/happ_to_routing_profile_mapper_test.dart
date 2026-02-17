import 'package:flutter_test/flutter_test.dart';
import 'package:trusttunnel/data/model/routing_mode.dart';
import 'package:trusttunnel/feature/routing/happ/domain/service/happ_to_routing_profile_mapper.dart';
import 'package:trusttunnel/feature/routing/happ/model/happ_route_order.dart';
import 'package:trusttunnel/feature/routing/happ/model/happ_routing_config.dart';

void main() {
  const mapper = HappToRoutingProfileMapper();

  group('HappToRoutingProfileMapper', () {
    test('maps proxy/direct rules and applies first-win route priority', () {
      final config = _config(
        globalProxy: true,
        routeOrder: HappRouteOrder.parse('proxy,direct,block'),
        directSites: <String>['geosite:directlist', 'manual.direct.com'],
        directIp: <String>['geoip:directip'],
        proxySites: <String>['geosite:proxylist', 'manual.proxy.com'],
        proxyIp: <String>['geoip:proxyip'],
        blockSites: <String>['geosite:blocklist', 'manual.block.com'],
        blockIp: <String>['geoip:blockip'],
      );

      final result = mapper.map(
        config: config,
        geosite: <String, Set<String>>{
          'directlist': <String>{'onlydirect.com', 'shared.domain'},
          'proxylist': <String>{'onlyproxy.com', 'shared.domain'},
          'blocklist': <String>{'onlyblock.com', 'shared.domain'},
        },
        geoip: <String, Set<String>>{
          'directip': <String>{'10.0.0.0/8'},
          'proxyip': <String>{'1.1.1.0/24'},
          'blockip': <String>{'203.0.113.0/24'},
        },
      );

      expect(result.defaultMode, RoutingMode.vpn);
      expect(
        result.bypassRules.toSet(),
        <String>{
          'onlydirect.com',
          'manual.direct.com',
          '10.0.0.0/8',
        },
      );
      expect(
        result.vpnRules.toSet(),
        <String>{
          'shared.domain',
          'onlyproxy.com',
          'manual.proxy.com',
          '1.1.1.0/24',
        },
      );
      expect(result.unsupportedBlockRules, 3);
    });

    test('uses default fallback order when conflict order is absent', () {
      final config = _config(
        globalProxy: false,
        routeOrder: HappRouteOrder.parse(null),
        directSites: <String>['overlap.com'],
        proxySites: <String>['overlap.com'],
        blockSites: <String>['overlap.com', 'blocked-only.com'],
      );

      final result = mapper.map(
        config: config,
        geosite: const <String, Set<String>>{},
        geoip: const <String, Set<String>>{},
      );

      expect(result.defaultMode, RoutingMode.bypass);
      expect(result.bypassRules, isEmpty);
      expect(result.vpnRules, isEmpty);
      expect(result.unsupportedBlockRules, 2);
    });

    test('keeps unmatched traffic on profile default mode', () {
      final proxyDefault = mapper.map(
        config: _config(
          globalProxy: true,
          routeOrder: HappRouteOrder.parse('proxy,direct,block'),
        ),
        geosite: const <String, Set<String>>{},
        geoip: const <String, Set<String>>{},
      );
      final directDefault = mapper.map(
        config: _config(
          globalProxy: false,
          routeOrder: HappRouteOrder.parse('proxy,direct,block'),
        ),
        geosite: const <String, Set<String>>{},
        geoip: const <String, Set<String>>{},
      );

      expect(proxyDefault.defaultMode, RoutingMode.vpn);
      expect(directDefault.defaultMode, RoutingMode.bypass);
      expect(proxyDefault.bypassRules, isEmpty);
      expect(proxyDefault.vpnRules, isEmpty);
      expect(directDefault.bypassRules, isEmpty);
      expect(directDefault.vpnRules, isEmpty);
    });
  });
}

HappRoutingConfig _config({
  required bool globalProxy,
  required HappRouteOrder routeOrder,
  List<String> directSites = const <String>[],
  List<String> directIp = const <String>[],
  List<String> proxySites = const <String>[],
  List<String> proxyIp = const <String>[],
  List<String> blockSites = const <String>[],
  List<String> blockIp = const <String>[],
}) => HappRoutingConfig(
  name: 'test',
  globalProxy: globalProxy,
  geositeUrl: 'https://example.com/geosite.dat',
  geoipUrl: 'https://example.com/geoip.dat',
  directSites: directSites,
  directIp: directIp,
  proxySites: proxySites,
  proxyIp: proxyIp,
  blockSites: blockSites,
  blockIp: blockIp,
  routeOrder: routeOrder,
  sourceUrl: 'https://example.com/routing.json',
);
