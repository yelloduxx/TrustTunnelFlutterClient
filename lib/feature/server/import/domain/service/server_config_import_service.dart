import 'dart:convert';

import 'package:trusttunnel/common/utils/routing_profile_utils.dart';
import 'package:trusttunnel/data/model/vpn_protocol.dart';
import 'package:trusttunnel/data/repository/routing_repository.dart';
import 'package:trusttunnel/data/repository/server_repository.dart';

/// Imports TrustTunnel client configs from TOML text or `tt://` links.
final class ServerConfigImportService {
  final ServerRepository _serverRepository;
  final RoutingRepository _routingRepository;
  final _parser = const _ServerConfigParser();

  ServerConfigImportService({
    required ServerRepository serverRepository,
    required RoutingRepository routingRepository,
  }) : _serverRepository = serverRepository,
       _routingRepository = routingRepository;

  Future<String> importFromToml({
    required String content,
    String? fallbackName,
  }) async {
    final parsed = _parser.parseToml(content: content, fallbackName: fallbackName);
    return _importParsed(parsed);
  }

  Future<String> importFromUri({required Uri uri}) async {
    final parsed = _parser.parseUri(uri: uri);
    return _importParsed(parsed);
  }

  Future<String> _importParsed(_ParsedServerConfig parsed) async {
    final routingProfiles = await _routingRepository.getAllProfiles();

    if (routingProfiles.isEmpty) {
      throw const FormatException('No routing profiles available');
    }

    final profileId = routingProfiles.any((p) => p.id == RoutingProfileUtils.defaultRoutingProfileId)
        ? RoutingProfileUtils.defaultRoutingProfileId
        : routingProfiles.first.id;

    final allServers = await _serverRepository.getAllServers();
    final uniqueName = _buildUniqueName(
      desiredName: parsed.serverName,
      existingNames: allServers.map((e) => e.name).toSet(),
    );

    await _serverRepository.addNewServer(
      request: (
        name: uniqueName,
        ipAddress: parsed.ipAddress,
        domain: parsed.domain,
        username: parsed.username,
        password: parsed.password,
        vpnProtocol: parsed.protocol,
        routingProfileId: profileId,
        dnsServers: parsed.dnsServers,
        subscriptionUrl: parsed.subscriptionUrl,
      ),
    );

    return uniqueName;
  }

  String _buildUniqueName({
    required String desiredName,
    required Set<String> existingNames,
  }) {
    final baseName = desiredName.trim().isEmpty ? 'Imported server' : desiredName.trim();

    final normalizedNames = existingNames.map((e) => e.trim().toLowerCase()).toSet();

    if (!normalizedNames.contains(baseName.toLowerCase())) {
      return baseName;
    }

    for (var i = 2; i < 10000; i++) {
      final candidate = '$baseName ($i)';
      if (!normalizedNames.contains(candidate.toLowerCase())) {
        return candidate;
      }
    }

    final fallback = DateTime.now().millisecondsSinceEpoch;
    return '$baseName $fallback';
  }
}

class _ParsedServerConfig {
  final String serverName;
  final String ipAddress;
  final String domain;
  final String username;
  final String password;
  final VpnProtocol protocol;
  final List<String> dnsServers;
  final String? subscriptionUrl;

  const _ParsedServerConfig({
    required this.serverName,
    required this.ipAddress,
    required this.domain,
    required this.username,
    required this.password,
    required this.protocol,
    required this.dnsServers,
    this.subscriptionUrl,
  });
}

class _ServerConfigParser {
  const _ServerConfigParser();

  static const _defaultDns = <String>[
    '1.1.1.1',
    '8.8.8.8',
  ];

  _ParsedServerConfig parseToml({
    required String content,
    String? fallbackName,
  }) {
    final hostname = _extractTomlString(content: content, key: 'hostname');
    final addresses = _extractTomlArray(content: content, key: 'addresses');
    final username = _extractTomlString(content: content, key: 'username');
    final password = _extractTomlString(content: content, key: 'password');

    final primaryAddress = addresses.firstWhere(
      (e) => e.trim().isNotEmpty,
      orElse: () => '',
    );

    if (hostname.trim().isEmpty || primaryAddress.trim().isEmpty || username.trim().isEmpty || password.isEmpty) {
      throw const FormatException('Missing required fields in TOML config');
    }

    final upstreamProtocol = _extractTomlStringOrNull(content: content, key: 'upstream_protocol');
    final dnsUpstreams = _extractTomlArrayOrNull(content: content, key: 'dns_upstreams') ?? const <String>[];

    final protocol = _mapProtocol(upstreamProtocol);
    final dnsServers = _sanitizeDns(dnsUpstreams);

    final parsedName = _resolveName(
      fallbackName: fallbackName,
      domain: hostname,
      address: primaryAddress,
      username: username,
    );

    return _ParsedServerConfig(
      serverName: parsedName,
      ipAddress: primaryAddress,
      domain: hostname,
      username: username,
      password: password,
      protocol: protocol,
      dnsServers: dnsServers,
    );
  }

  _ParsedServerConfig parseUri({required Uri uri}) {
    if (uri.scheme.toLowerCase() != 'tt') {
      throw const FormatException('Unsupported link scheme');
    }

    final encodedConfig = _firstNonEmpty(uri, ['config', 'cfg', 'b64']);
    if (encodedConfig != null) {
      final toml = _decodeBase64Any(encodedConfig);
      return parseToml(content: toml, fallbackName: _firstNonEmpty(uri, ['name', 'server_name']));
    }

    final inlineToml = _firstNonEmpty(uri, ['toml']);
    if (inlineToml != null) {
      return parseToml(content: inlineToml, fallbackName: _firstNonEmpty(uri, ['name', 'server_name']));
    }

    final hostname = _firstNonEmpty(uri, ['hostname', 'domain']);
    final address = _firstNonEmpty(uri, ['address', 'ip', 'ip_address', 'server']);
    final username = _firstNonEmpty(uri, ['username', 'user']);
    final password = _firstNonEmpty(uri, ['password', 'pass']);

    if (hostname == null || address == null || username == null || password == null) {
      throw const FormatException('Missing required fields in link');
    }

    final protocolRaw = _firstNonEmpty(uri, ['protocol', 'upstream_protocol']);
    final protocol = _mapProtocol(protocolRaw);

    final dnsRawValues = <String>[
      ...uri.queryParametersAll['dns'] ?? const <String>[],
      ...uri.queryParametersAll['dns_servers'] ?? const <String>[],
      ...uri.queryParametersAll['dnsServers'] ?? const <String>[],
    ];

    final dnsServers = _sanitizeDns(dnsRawValues);
    final desiredName = _resolveName(
      fallbackName: _firstNonEmpty(uri, ['name', 'server_name']),
      domain: hostname,
      address: address,
      username: username,
    );

    final subscriptionUrl = _firstNonEmpty(uri, ['sub', 'subscription_url']);

    return _ParsedServerConfig(
      serverName: desiredName,
      ipAddress: address,
      domain: hostname,
      username: username,
      password: password,
      protocol: protocol,
      dnsServers: dnsServers,
      subscriptionUrl: subscriptionUrl,
    );
  }

  String? _firstNonEmpty(Uri uri, List<String> keys) {
    for (final key in keys) {
      final value = uri.queryParameters[key]?.trim();
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }

    return null;
  }

  String _resolveName({
    required String? fallbackName,
    required String domain,
    required String address,
    required String username,
  }) {
    if (fallbackName != null && fallbackName.trim().isNotEmpty) {
      return fallbackName.trim();
    }

    final cleanDomain = domain.trim();
    if (cleanDomain.isNotEmpty) {
      return cleanDomain;
    }

    final cleanAddress = address.trim();
    if (cleanAddress.isNotEmpty) {
      return cleanAddress;
    }

    return 'Imported ${username.trim()}';
  }

  VpnProtocol _mapProtocol(String? raw) {
    final normalized = raw?.trim().toLowerCase();

    return switch (normalized) {
      null || '' => VpnProtocol.http2,
      'http2' => VpnProtocol.http2,
      'h2' => VpnProtocol.http2,
      'http3' => VpnProtocol.quic,
      'quic' => VpnProtocol.quic,
      _ => throw FormatException('Unsupported protocol: $raw'),
    };
  }

  String _decodeBase64Any(String value) {
    final normalized = value.trim().replaceAll('-', '+').replaceAll('_', '/');
    final padding = (4 - normalized.length % 4) % 4;
    final padded = '$normalized${'=' * padding}';

    try {
      final bytes = base64Decode(padded);
      return utf8.decode(bytes);
    } on FormatException {
      throw const FormatException('Invalid base64 config payload');
    }
  }

  List<String> _sanitizeDns(List<String> rawValues) {
    if (rawValues.isEmpty) {
      return _defaultDns;
    }

    final values = <String>[];

    for (final raw in rawValues) {
      final parts = raw.split(RegExp(r'[\n,;\s]+'));
      for (final part in parts) {
        final dns = part.trim();
        if (dns.isEmpty) continue;
        values.add(dns);
      }
    }

    if (values.isEmpty) {
      return _defaultDns;
    }

    return values.toSet().toList();
  }

  String _extractTomlString({
    required String content,
    required String key,
  }) {
    final value = _extractTomlStringOrNull(content: content, key: key);
    if (value == null) {
      throw FormatException('Missing key `$key`');
    }
    return value;
  }

  String? _extractTomlStringOrNull({
    required String content,
    required String key,
  }) {
    final escapedKey = RegExp.escape(key);
    final regex = RegExp(
      '^\\s*$escapedKey\\s*=\\s*"((?:\\\\.|[^"\\\\])*)"',
      multiLine: true,
    );

    final match = regex.firstMatch(content);
    if (match == null) {
      return null;
    }

    final rawValue = match.group(1) ?? '';
    return _unescapeToml(rawValue);
  }

  List<String> _extractTomlArray({
    required String content,
    required String key,
  }) {
    final value = _extractTomlArrayOrNull(content: content, key: key);
    if (value == null) {
      throw FormatException('Missing key `$key`');
    }

    return value;
  }

  List<String>? _extractTomlArrayOrNull({
    required String content,
    required String key,
  }) {
    final escapedKey = RegExp.escape(key);
    final arrayRegex = RegExp(
      '^\\s*$escapedKey\\s*=\\s*\\[(.*?)\\]',
      multiLine: true,
      dotAll: true,
    );

    final arrayMatch = arrayRegex.firstMatch(content);
    if (arrayMatch == null) {
      return null;
    }

    final body = arrayMatch.group(1) ?? '';
    final itemRegex = RegExp('"((?:\\\\.|[^"\\\\])*)"');
    final values = itemRegex
        .allMatches(body)
        .map((match) => _unescapeToml(match.group(1) ?? ''))
        .where((value) => value.trim().isNotEmpty)
        .toList();

    return values;
  }

  String _unescapeToml(String input) {
    final buffer = StringBuffer();

    for (var i = 0; i < input.length; i++) {
      final current = input[i];

      if (current != '\\' || i + 1 >= input.length) {
        buffer.write(current);
        continue;
      }

      final next = input[++i];
      switch (next) {
        case 'n':
          buffer.write('\n');
          break;
        case 'r':
          buffer.write('\r');
          break;
        case 't':
          buffer.write('\t');
          break;
        case '"':
          buffer.write('"');
          break;
        case '\\':
          buffer.write('\\');
          break;
        default:
          buffer.write(next);
      }
    }

    return buffer.toString();
  }
}
