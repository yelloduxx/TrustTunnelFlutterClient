import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:protobuf/protobuf.dart' as $pb;
import 'package:trusttunnel/feature/routing/happ/domain/service/v2ray_geodata_parser.dart';

void main() {
  final parser = V2RayGeodataParser();

  group('V2RayGeodataParser', () {
    test('parses geosite payload and skips regex domains', () {
      final payload = _FixtureGeoSiteList()
        ..entry.add(
          _FixtureGeoSite()
            ..code = 'ads'
            ..domain.addAll(<_FixtureDomain>[
              _FixtureDomain()
                ..type = _FixtureDomainType.plain
                ..value = 'plain.example',
              _FixtureDomain()
                ..type = _FixtureDomainType.rootDomain
                ..value = 'root.example',
              _FixtureDomain()
                ..type = _FixtureDomainType.full
                ..value = 'full.example',
              _FixtureDomain()
                ..type = _FixtureDomainType.regex
                ..value = '.*ignored.*',
            ]),
        )
        ..entry.add(
          _FixtureGeoSite()
            ..countryCode = 'RU'
            ..domain.add(
              _FixtureDomain()
                ..type = _FixtureDomainType.plain
                ..value = 'ru.example',
            ),
        );

      final parsed = parser.parseGeosite(payload.writeToBuffer());

      expect(parsed['ads'], <String>{'plain.example', 'root.example', 'full.example'});
      expect(parsed['ru'], <String>{'ru.example'});
    });

    test('parses geoip payload for ipv4 and ipv6 CIDR values', () {
      final payload = _FixtureGeoIpList()
        ..entry.add(
          _FixtureGeoIp()
            ..code = 'US'
            ..cidr.addAll(<_FixtureCidr>[
              _FixtureCidr()
                ..ip = Uint8List.fromList(<int>[8, 8, 8, 0])
                ..prefix = 24,
              _FixtureCidr()
                ..ip = Uint8List.fromList(<int>[
                  0x20,
                  0x01,
                  0x0d,
                  0xb8,
                  0x00,
                  0x00,
                  0x00,
                  0x00,
                  0x00,
                  0x00,
                  0x00,
                  0x00,
                  0x00,
                  0x00,
                  0x00,
                  0x00,
                ])
                ..prefix = 32,
              _FixtureCidr()
                ..ip = Uint8List.fromList(<int>[1, 2, 3])
                ..prefix = 8,
            ]),
        )
        ..entry.add(
          _FixtureGeoIp()
            ..countryCode = 'RU'
            ..cidr.add(
              _FixtureCidr()
                ..ip = Uint8List.fromList(<int>[5, 0, 0, 0])
                ..prefix = 8,
            ),
        );

      final parsed = parser.parseGeoip(payload.writeToBuffer());

      expect(parsed['us'], containsAll(<String>['8.8.8.0/24', '2001:db8::/32']));
      expect(parsed['us'], isNot(contains('1.2.3/8')));
      expect(parsed['ru'], <String>{'5.0.0.0/8'});
    });
  });
}

class _FixtureGeoSiteList extends $pb.GeneratedMessage {
  factory _FixtureGeoSiteList() => create();
  _FixtureGeoSiteList._() : super();

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
    '_FixtureGeoSiteList',
    package: const $pb.PackageName('v2ray.core.app.router.routercommon'),
    createEmptyInstance: create,
  )..pc<_FixtureGeoSite>(1, 'entry', $pb.PbFieldType.PM, subBuilder: _FixtureGeoSite.create);

  @override
  $pb.BuilderInfo get info_ => _i;

  @override
  _FixtureGeoSiteList createEmptyInstance() => create();

  @override
  _FixtureGeoSiteList clone() => _FixtureGeoSiteList()..mergeFromMessage(this);

  static _FixtureGeoSiteList create() => _FixtureGeoSiteList._();

  List<_FixtureGeoSite> get entry => $_getList(0);
}

class _FixtureGeoSite extends $pb.GeneratedMessage {
  factory _FixtureGeoSite() => create();
  _FixtureGeoSite._() : super();

  static final $pb.BuilderInfo _i =
      $pb.BuilderInfo(
          '_FixtureGeoSite',
          package: const $pb.PackageName('v2ray.core.app.router.routercommon'),
          createEmptyInstance: create,
        )
        ..aOS(1, 'countryCode')
        ..pc<_FixtureDomain>(2, 'domain', $pb.PbFieldType.PM, subBuilder: _FixtureDomain.create)
        ..aOS(4, 'code');

  @override
  $pb.BuilderInfo get info_ => _i;

  @override
  _FixtureGeoSite createEmptyInstance() => create();

  @override
  _FixtureGeoSite clone() => _FixtureGeoSite()..mergeFromMessage(this);

  static _FixtureGeoSite create() => _FixtureGeoSite._();

  set countryCode(String value) => setField(1, value);
  set code(String value) => setField(4, value);
  List<_FixtureDomain> get domain => $_getList(1);
}

class _FixtureGeoIpList extends $pb.GeneratedMessage {
  factory _FixtureGeoIpList() => create();
  _FixtureGeoIpList._() : super();

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
    '_FixtureGeoIpList',
    package: const $pb.PackageName('v2ray.core.app.router.routercommon'),
    createEmptyInstance: create,
  )..pc<_FixtureGeoIp>(1, 'entry', $pb.PbFieldType.PM, subBuilder: _FixtureGeoIp.create);

  @override
  $pb.BuilderInfo get info_ => _i;

  @override
  _FixtureGeoIpList createEmptyInstance() => create();

  @override
  _FixtureGeoIpList clone() => _FixtureGeoIpList()..mergeFromMessage(this);

  static _FixtureGeoIpList create() => _FixtureGeoIpList._();

  List<_FixtureGeoIp> get entry => $_getList(0);
}

class _FixtureGeoIp extends $pb.GeneratedMessage {
  factory _FixtureGeoIp() => create();
  _FixtureGeoIp._() : super();

  static final $pb.BuilderInfo _i =
      $pb.BuilderInfo(
          '_FixtureGeoIp',
          package: const $pb.PackageName('v2ray.core.app.router.routercommon'),
          createEmptyInstance: create,
        )
        ..aOS(1, 'countryCode')
        ..pc<_FixtureCidr>(2, 'cidr', $pb.PbFieldType.PM, subBuilder: _FixtureCidr.create)
        ..aOS(5, 'code');

  @override
  $pb.BuilderInfo get info_ => _i;

  @override
  _FixtureGeoIp createEmptyInstance() => create();

  @override
  _FixtureGeoIp clone() => _FixtureGeoIp()..mergeFromMessage(this);

  static _FixtureGeoIp create() => _FixtureGeoIp._();

  set countryCode(String value) => setField(1, value);
  set code(String value) => setField(5, value);
  List<_FixtureCidr> get cidr => $_getList(1);
}

class _FixtureCidr extends $pb.GeneratedMessage {
  factory _FixtureCidr() => create();
  _FixtureCidr._() : super();

  static final $pb.BuilderInfo _i =
      $pb.BuilderInfo(
          '_FixtureCidr',
          package: const $pb.PackageName('v2ray.core.app.router.routercommon'),
          createEmptyInstance: create,
        )
        ..a<List<int>>(1, 'ip', $pb.PbFieldType.OY)
        ..a<int>(2, 'prefix', $pb.PbFieldType.OU3);

  @override
  $pb.BuilderInfo get info_ => _i;

  @override
  _FixtureCidr createEmptyInstance() => create();

  @override
  _FixtureCidr clone() => _FixtureCidr()..mergeFromMessage(this);

  static _FixtureCidr create() => _FixtureCidr._();

  set ip(Uint8List value) => setField(1, value);
  set prefix(int value) => setField(2, value);
}

class _FixtureDomain extends $pb.GeneratedMessage {
  factory _FixtureDomain() => create();
  _FixtureDomain._() : super();

  static final $pb.BuilderInfo _i =
      $pb.BuilderInfo(
          '_FixtureDomain',
          package: const $pb.PackageName('v2ray.core.app.router.routercommon'),
          createEmptyInstance: create,
        )
        ..e<_FixtureDomainType>(
          1,
          'type',
          $pb.PbFieldType.OE,
          defaultOrMaker: _FixtureDomainType.plain,
          valueOf: _FixtureDomainType.valueOf,
          enumValues: _FixtureDomainType.values,
        )
        ..aOS(2, 'value');

  @override
  $pb.BuilderInfo get info_ => _i;

  @override
  _FixtureDomain createEmptyInstance() => create();

  @override
  _FixtureDomain clone() => _FixtureDomain()..mergeFromMessage(this);

  static _FixtureDomain create() => _FixtureDomain._();

  set type(_FixtureDomainType value) => setField(1, value);
  set value(String text) => setField(2, text);
}

class _FixtureDomainType extends $pb.ProtobufEnum {
  static const _FixtureDomainType plain = _FixtureDomainType._(0, 'Plain');
  static const _FixtureDomainType regex = _FixtureDomainType._(1, 'Regex');
  static const _FixtureDomainType rootDomain = _FixtureDomainType._(2, 'RootDomain');
  static const _FixtureDomainType full = _FixtureDomainType._(3, 'Full');

  static const List<_FixtureDomainType> values = <_FixtureDomainType>[
    plain,
    regex,
    rootDomain,
    full,
  ];

  static final Map<int, _FixtureDomainType> _byValue = $pb.ProtobufEnum.initByValue(values);

  static _FixtureDomainType? valueOf(int value) => _byValue[value];

  const _FixtureDomainType._(super.value, super.name);
}
