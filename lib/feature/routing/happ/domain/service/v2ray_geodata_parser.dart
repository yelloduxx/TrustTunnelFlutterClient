import 'dart:io';
import 'dart:typed_data';

import 'package:protobuf/protobuf.dart' as $pb;

final class V2RayGeodataParser {
  Map<String, Set<String>> parseGeosite(List<int> payload) {
    final parsed = _GeoSiteList()..mergeFromBuffer(payload);
    final result = <String, Set<String>>{};

    for (final entry in parsed.entry) {
      final key = _normalizeTag(entry.code.isNotEmpty ? entry.code : entry.countryCode);
      if (key.isEmpty) {
        continue;
      }

      final domains = <String>{};
      for (final domain in entry.domain) {
        final value = domain.value.trim().toLowerCase();
        if (value.isEmpty) {
          continue;
        }

        switch (domain.type) {
          case _DomainType.plain:
          case _DomainType.rootDomain:
          case _DomainType.full:
            domains.add(value);
          case _DomainType.regex:
            // Regex rules are currently unsupported by TrustTunnel routing model.
            continue;
        }
      }

      if (domains.isNotEmpty) {
        result[key] = domains;
      }
    }

    return result;
  }

  Map<String, Set<String>> parseGeoip(List<int> payload) {
    final parsed = _GeoIpList()..mergeFromBuffer(payload);
    final result = <String, Set<String>>{};

    for (final entry in parsed.entry) {
      final key = _normalizeTag(entry.code.isNotEmpty ? entry.code : entry.countryCode);
      if (key.isEmpty) {
        continue;
      }

      final cidrRanges = <String>{};
      for (final cidr in entry.cidr) {
        final address = _ipFromBytes(cidr.ip);
        if (address == null) {
          continue;
        }

        final totalBits = cidr.ip.length == 16 ? 128 : 32;
        final prefix = cidr.prefix.clamp(0, totalBits);
        cidrRanges.add('$address/$prefix');
      }

      if (cidrRanges.isNotEmpty) {
        result[key] = cidrRanges;
      }
    }

    return result;
  }

  String _normalizeTag(String raw) => raw.trim().toLowerCase();

  String? _ipFromBytes(List<int> ip) {
    if (ip.length != 4 && ip.length != 16) {
      return null;
    }

    try {
      return InternetAddress.fromRawAddress(Uint8List.fromList(ip)).address;
    } catch (_) {
      return null;
    }
  }
}

class _GeoSiteList extends $pb.GeneratedMessage {
  factory _GeoSiteList() => create();
  _GeoSiteList._() : super();

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
    '_GeoSiteList',
    package: const $pb.PackageName('v2ray.core.app.router.routercommon'),
    createEmptyInstance: create,
  )..pc<_GeoSite>(1, 'entry', $pb.PbFieldType.PM, subBuilder: _GeoSite.create);

  @override
  $pb.BuilderInfo get info_ => _i;

  @override
  _GeoSiteList createEmptyInstance() => create();

  @override
  _GeoSiteList clone() => _GeoSiteList()..mergeFromMessage(this);

  static _GeoSiteList create() => _GeoSiteList._();

  List<_GeoSite> get entry => $_getList(0);
}

class _GeoSite extends $pb.GeneratedMessage {
  factory _GeoSite() => create();
  _GeoSite._() : super();

  static final $pb.BuilderInfo _i =
      $pb.BuilderInfo(
          '_GeoSite',
          package: const $pb.PackageName('v2ray.core.app.router.routercommon'),
          createEmptyInstance: create,
        )
        ..aOS(1, 'countryCode')
        ..pc<_Domain>(2, 'domain', $pb.PbFieldType.PM, subBuilder: _Domain.create)
        ..aOS(4, 'code');

  @override
  $pb.BuilderInfo get info_ => _i;

  @override
  _GeoSite createEmptyInstance() => create();

  @override
  _GeoSite clone() => _GeoSite()..mergeFromMessage(this);

  static _GeoSite create() => _GeoSite._();

  String get countryCode => $_getSZ(0);
  String get code => $_getSZ(2);
  List<_Domain> get domain => $_getList(1);
}

class _GeoIpList extends $pb.GeneratedMessage {
  factory _GeoIpList() => create();
  _GeoIpList._() : super();

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
    '_GeoIpList',
    package: const $pb.PackageName('v2ray.core.app.router.routercommon'),
    createEmptyInstance: create,
  )..pc<_GeoIp>(1, 'entry', $pb.PbFieldType.PM, subBuilder: _GeoIp.create);

  @override
  $pb.BuilderInfo get info_ => _i;

  @override
  _GeoIpList createEmptyInstance() => create();

  @override
  _GeoIpList clone() => _GeoIpList()..mergeFromMessage(this);

  static _GeoIpList create() => _GeoIpList._();

  List<_GeoIp> get entry => $_getList(0);
}

class _GeoIp extends $pb.GeneratedMessage {
  factory _GeoIp() => create();
  _GeoIp._() : super();

  static final $pb.BuilderInfo _i =
      $pb.BuilderInfo(
          '_GeoIp',
          package: const $pb.PackageName('v2ray.core.app.router.routercommon'),
          createEmptyInstance: create,
        )
        ..aOS(1, 'countryCode')
        ..pc<_Cidr>(2, 'cidr', $pb.PbFieldType.PM, subBuilder: _Cidr.create)
        ..aOS(5, 'code');

  @override
  $pb.BuilderInfo get info_ => _i;

  @override
  _GeoIp createEmptyInstance() => create();

  @override
  _GeoIp clone() => _GeoIp()..mergeFromMessage(this);

  static _GeoIp create() => _GeoIp._();

  String get countryCode => $_getSZ(0);
  String get code => $_getSZ(2);
  List<_Cidr> get cidr => $_getList(1);
}

class _Cidr extends $pb.GeneratedMessage {
  factory _Cidr() => create();
  _Cidr._() : super();

  static final $pb.BuilderInfo _i =
      $pb.BuilderInfo(
          '_Cidr',
          package: const $pb.PackageName('v2ray.core.app.router.routercommon'),
          createEmptyInstance: create,
        )
        ..a<List<int>>(1, 'ip', $pb.PbFieldType.OY)
        ..a<int>(2, 'prefix', $pb.PbFieldType.OU3);

  @override
  $pb.BuilderInfo get info_ => _i;

  @override
  _Cidr createEmptyInstance() => create();

  @override
  _Cidr clone() => _Cidr()..mergeFromMessage(this);

  static _Cidr create() => _Cidr._();

  Uint8List get ip => $_getN(0);
  int get prefix => $_getIZ(1);
}

class _Domain extends $pb.GeneratedMessage {
  factory _Domain() => create();
  _Domain._() : super();

  static final $pb.BuilderInfo _i =
      $pb.BuilderInfo(
          '_Domain',
          package: const $pb.PackageName('v2ray.core.app.router.routercommon'),
          createEmptyInstance: create,
        )
        ..e<_DomainType>(
          1,
          'type',
          $pb.PbFieldType.OE,
          defaultOrMaker: _DomainType.plain,
          valueOf: _DomainType.valueOf,
          enumValues: _DomainType.values,
        )
        ..aOS(2, 'value');

  @override
  $pb.BuilderInfo get info_ => _i;

  @override
  _Domain createEmptyInstance() => create();

  @override
  _Domain clone() => _Domain()..mergeFromMessage(this);

  static _Domain create() => _Domain._();

  _DomainType get type => $_getN(0);
  String get value => $_getSZ(1);
}

class _DomainType extends $pb.ProtobufEnum {
  static const _DomainType plain = _DomainType._(0, 'Plain');
  static const _DomainType regex = _DomainType._(1, 'Regex');
  static const _DomainType rootDomain = _DomainType._(2, 'RootDomain');
  static const _DomainType full = _DomainType._(3, 'Full');

  static const List<_DomainType> values = <_DomainType>[
    plain,
    regex,
    rootDomain,
    full,
  ];

  static final Map<int, _DomainType> _byValue = $pb.ProtobufEnum.initByValue(values);

  static _DomainType? valueOf(int value) => _byValue[value];

  const _DomainType._(super.value, super.name);
}
