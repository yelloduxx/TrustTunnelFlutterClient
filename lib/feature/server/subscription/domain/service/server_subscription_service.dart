import 'dart:convert';
import 'dart:io';

import 'package:trusttunnel/data/model/server.dart';
import 'package:trusttunnel/data/model/vpn_protocol.dart';
import 'package:trusttunnel/data/repository/server_repository.dart';

/// Fetches subscription URL, parses the tt:// link response, and updates
/// the server record with fresh connection parameters.
final class ServerSubscriptionService {
  final ServerRepository _serverRepository;

  ServerSubscriptionService({
    required ServerRepository serverRepository,
  }) : _serverRepository = serverRepository;

  /// Refreshes a single server from its subscription URL.
  ///
  /// Returns `true` if the server was updated, `false` if skipped or unchanged.
  /// Throws on network or parse errors.
  Future<bool> refreshServer(Server server) async {
    final subUrl = server.subscriptionUrl;
    if (subUrl == null || subUrl.isEmpty) {
      return false;
    }

    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 15)
      ..badCertificateCallback = (_, __, ___) => true;

    try {
      final request = await client.getUrl(Uri.parse(subUrl));
      final response = await request.close();

      if (response.statusCode != 200) {
        return false;
      }

      final body = await response.transform(utf8.decoder).join();
      if (body.isEmpty) {
        return false;
      }

      final ttLink = _extractTtLink(body);
      if (ttLink == null) {
        return false;
      }

      final parsed = _parseTtLink(ttLink);
      if (parsed == null) {
        return false;
      }

      final changed = parsed.ipAddress != server.ipAddress ||
          parsed.domain != server.domain ||
          parsed.username != server.username ||
          parsed.password != server.password ||
          parsed.protocol != server.vpnProtocol;

      if (!changed) {
        return false;
      }

      await _serverRepository.updateServerFromSubscription(
        id: server.id,
        ipAddress: parsed.ipAddress,
        domain: parsed.domain,
        username: parsed.username,
        password: parsed.password,
        vpnProtocolId: parsed.protocol.value,
        dnsServers: server.dnsServers,
      );

      return true;
    } finally {
      client.close();
    }
  }

  /// Extracts the first tt:// link from the subscription response.
  ///
  /// The response may be base64-encoded (standard 3x-ui behavior when
  /// "Sub Encrypt" is enabled) or plain text with one link per line.
  String? _extractTtLink(String body) {
    // Try base64 decode first.
    final trimmed = body.trim();
    try {
      final decoded = utf8.decode(base64Decode(trimmed));
      final lines = decoded.split('\n');
      for (final line in lines) {
        if (line.trimLeft().startsWith('tt://')) {
          return line.trim();
        }
      }
    } catch (_) {
      // Not base64 — try plain text.
    }

    // Plain text: find the first tt:// line.
    for (final line in trimmed.split('\n')) {
      if (line.trimLeft().startsWith('tt://')) {
        return line.trim();
      }
    }

    return null;
  }

  /// Parses a tt://import?... link into its component fields.
  _ParsedSubscription? _parseTtLink(String link) {
    final uri = Uri.tryParse(link);
    if (uri == null) {
      return null;
    }

    final hostname = uri.queryParameters['hostname'] ?? uri.queryParameters['domain'];
    final address = uri.queryParameters['address'] ?? uri.queryParameters['ip'];
    final username = uri.queryParameters['username'] ?? uri.queryParameters['user'];
    final password = uri.queryParameters['password'] ?? uri.queryParameters['pass'];

    if (hostname == null || address == null || username == null || password == null) {
      return null;
    }

    final protocolRaw = uri.queryParameters['protocol'] ?? uri.queryParameters['upstream_protocol'];
    final protocol = _mapProtocol(protocolRaw);

    return _ParsedSubscription(
      ipAddress: address,
      domain: hostname,
      username: username,
      password: password,
      protocol: protocol,
    );
  }

  VpnProtocol _mapProtocol(String? raw) {
    final normalized = raw?.trim().toLowerCase();
    return switch (normalized) {
      null || '' => VpnProtocol.http2,
      'http2' || 'h2' => VpnProtocol.http2,
      'http3' || 'quic' => VpnProtocol.quic,
      _ => VpnProtocol.http2,
    };
  }
}

class _ParsedSubscription {
  final String ipAddress;
  final String domain;
  final String username;
  final String password;
  final VpnProtocol protocol;

  const _ParsedSubscription({
    required this.ipAddress,
    required this.domain,
    required this.username,
    required this.password,
    required this.protocol,
  });
}
