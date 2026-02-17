import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:trusttunnel/feature/routing/happ/model/happ_outbound.dart';
import 'package:trusttunnel/feature/routing/happ/model/happ_route_order.dart';
import 'package:trusttunnel/feature/routing/happ/model/happ_routing_config.dart';

void main() {
  group('HappRouteOrder.parse', () {
    test('uses fallback order when value is null or empty', () {
      expect(
        HappRouteOrder.parse(null).values,
        <HappOutbound>[
          HappOutbound.block,
          HappOutbound.proxy,
          HappOutbound.direct,
        ],
      );

      expect(
        HappRouteOrder.parse('   ').values,
        <HappOutbound>[
          HappOutbound.block,
          HappOutbound.proxy,
          HappOutbound.direct,
        ],
      );
    });

    test('keeps declared priority, removes duplicates, appends missing items', () {
      expect(
        HappRouteOrder.parse('proxy, direct, proxy').values,
        <HappOutbound>[
          HappOutbound.proxy,
          HappOutbound.direct,
          HappOutbound.block,
        ],
      );
    });

    test('supports dash-separated order', () {
      expect(
        HappRouteOrder.parse('proxy-direct-block').values,
        <HappOutbound>[
          HappOutbound.proxy,
          HappOutbound.direct,
          HappOutbound.block,
        ],
      );
    });
  });

  group('HappRoutingConfig.fromSource', () {
    test('parses config payload', () {
      final config = HappRoutingConfig.fromSource(
        sourceUrl: 'https://example.com/routing.json',
        jsonPayload: jsonEncode(<String, Object>{
          'Name': 'Main route',
          'GlobalProxy': false,
          'Geositeurl': 'https://example.com/geosite.dat',
          'Geoipurl': 'https://example.com/geoip.dat',
          'DirectSites': <String>['geosite:ru', 'local.test'],
          'ProxySites': <String>['geosite:google'],
          'OrderRouting': 'proxy,direct,block',
        }),
      );

      expect(config.name, 'Main route');
      expect(config.globalProxy, isFalse);
      expect(config.geositeUrl, 'https://example.com/geosite.dat');
      expect(config.geoipUrl, 'https://example.com/geoip.dat');
      expect(config.directSites, <String>['geosite:ru', 'local.test']);
      expect(config.proxySites, <String>['geosite:google']);
      expect(config.routeOrder.values, <HappOutbound>[
        HappOutbound.proxy,
        HappOutbound.direct,
        HappOutbound.block,
      ]);
    });

    test('throws when geodata urls are missing', () {
      expect(
        () => HappRoutingConfig.fromSource(
          sourceUrl: 'https://example.com/routing.json',
          jsonPayload: jsonEncode(<String, Object>{
            'Name': 'Bad route',
            'GlobalProxy': true,
          }),
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('parses RouteOrder alias', () {
      final config = HappRoutingConfig.fromSource(
        sourceUrl: 'https://example.com/routing.json',
        jsonPayload: jsonEncode(<String, Object>{
          'Name': 'Main route',
          'GlobalProxy': true,
          'Geositeurl': 'https://example.com/geosite.dat',
          'Geoipurl': 'https://example.com/geoip.dat',
          'RouteOrder': 'direct-proxy-block',
        }),
      );

      expect(config.routeOrder.values, <HappOutbound>[
        HappOutbound.direct,
        HappOutbound.proxy,
        HappOutbound.block,
      ]);
    });
  });
}
