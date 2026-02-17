import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:trusttunnel/data/model/managed_routing_source.dart';
import 'package:trusttunnel/data/model/routing_mode.dart';
import 'package:trusttunnel/data/repository/routing_repository.dart';
import 'package:trusttunnel/feature/routing/happ/domain/service/happ_to_routing_profile_mapper.dart';
import 'package:trusttunnel/feature/routing/happ/domain/service/v2ray_geodata_parser.dart';
import 'package:trusttunnel/feature/routing/happ/model/happ_routing_config.dart';
import 'package:trusttunnel/feature/routing/happ/model/happ_routing_import_result.dart';
import 'package:trusttunnel/feature/routing/happ/model/managed_routing_sync_result.dart';

final class HappRoutingImportService {
  final RoutingRepository _routingRepository;
  final V2RayGeodataParser _geodataParser;
  final HappToRoutingProfileMapper _mapper;
  final HttpClient _httpClient;

  HappRoutingImportService({
    required RoutingRepository routingRepository,
    V2RayGeodataParser? geodataParser,
    HappToRoutingProfileMapper? mapper,
    HttpClient? httpClient,
  }) : _routingRepository = routingRepository,
       _geodataParser = geodataParser ?? V2RayGeodataParser(),
       _mapper = mapper ?? const HappToRoutingProfileMapper(),
       _httpClient = httpClient ?? HttpClient();

  Future<HappRoutingImportResult> importFromUri({required Uri uri}) async {
    final resolved = await _resolveConfig(uri);
    final materialized = await _materialize(resolved);

    final managedSources = await _routingRepository.getManagedSources();
    final profiles = await _routingRepository.getAllProfiles();
    final profilesById = Map.fromEntries(profiles.map((profile) => MapEntry(profile.id, profile)));

    final dedupManaged = managedSources.firstWhereOrNull((source) {
      if (source.contentHash != materialized.contentHash) return false;
      if (source.sourceUrl != materialized.config.sourceUrl) return false;
      if (source.geositeUrl != materialized.config.geositeUrl) return false;
      if (source.geoipUrl != materialized.config.geoipUrl) return false;
      if (source.globalMode != materialized.globalMode) return false;
      return source.routeOrder.join(',') == materialized.config.routeOrder.serialize();
    });

    if (dedupManaged != null) {
      final existing = profilesById[dedupManaged.profileId];
      if (existing != null) {
        return HappRoutingImportResult(
          profileId: existing.id,
          profileName: existing.name,
          reusedExistingProfile: true,
          unsupportedBlockRules: materialized.mapping.unsupportedBlockRules,
        );
      }
    }

    final sameSourceManaged = managedSources.firstWhereOrNull((source) {
      final profile = profilesById[source.profileId];
      if (profile == null) return false;
      return source.sourceUrl == materialized.config.sourceUrl &&
          profile.name.trim().toLowerCase() == materialized.config.name.trim().toLowerCase();
    });

    final now = DateTime.now();
    final profileId = switch (sameSourceManaged) {
      null => await _createNewProfile(
        name: _buildUniqueName(
          desiredName: materialized.config.name,
          existingNames: profiles.map((profile) => profile.name).toSet(),
        ),
        mapping: materialized.mapping,
      ),
      final source => await _updateProfile(
        id: source.profileId,
        mapping: materialized.mapping,
      ),
    };

    final previousManaged = await _routingRepository.getManagedSourceByProfileId(profileId: profileId);
    await _routingRepository.upsertManagedSource(
      source: ManagedRoutingSource(
        profileId: profileId,
        sourceUrl: materialized.config.sourceUrl,
        geositeUrl: materialized.config.geositeUrl,
        geoipUrl: materialized.config.geoipUrl,
        routeOrder: materialized.config.routeOrder.values.map((item) => item.value).toList(),
        globalMode: materialized.globalMode,
        syncEnabled: previousManaged?.syncEnabled ?? true,
        localOverride: false,
        contentHash: materialized.contentHash,
        eTag: materialized.eTag,
        unsupportedBlockRules: materialized.mapping.unsupportedBlockRules,
        lastSuccessAt: now,
        lastErrorAt: null,
        lastErrorMessage: null,
        createdAt: previousManaged?.createdAt ?? now,
        updatedAt: now,
      ),
    );

    final profile = (await _routingRepository.getProfileById(id: profileId))!;

    return HappRoutingImportResult(
      profileId: profile.id,
      profileName: profile.name,
      reusedExistingProfile: sameSourceManaged != null,
      unsupportedBlockRules: materialized.mapping.unsupportedBlockRules,
    );
  }

  Future<ManagedRoutingSyncResult> syncManagedSource({
    required ManagedRoutingSource source,
  }) async {
    if (!source.syncEnabled || source.localOverride) {
      return ManagedRoutingSyncResult.noChanges(profileId: source.profileId);
    }

    try {
      final resolved = await _resolveConfig(Uri.parse(source.sourceUrl));
      final materialized = await _materialize(resolved);

      if (materialized.contentHash == source.contentHash) {
        await _routingRepository.upsertManagedSource(
          source: source.copyWith(
            lastSuccessAt: DateTime.now(),
            lastErrorAt: null,
            lastErrorMessage: null,
            updatedAt: DateTime.now(),
          ),
        );
        return ManagedRoutingSyncResult.noChanges(profileId: source.profileId);
      }

      await _updateProfile(
        id: source.profileId,
        mapping: materialized.mapping,
      );

      await _routingRepository.upsertManagedSource(
        source: source.copyWith(
          sourceUrl: materialized.config.sourceUrl,
          geositeUrl: materialized.config.geositeUrl,
          geoipUrl: materialized.config.geoipUrl,
          routeOrder: materialized.config.routeOrder.values.map((item) => item.value).toList(),
          globalMode: materialized.globalMode,
          contentHash: materialized.contentHash,
          eTag: materialized.eTag,
          unsupportedBlockRules: materialized.mapping.unsupportedBlockRules,
          lastSuccessAt: DateTime.now(),
          lastErrorAt: null,
          lastErrorMessage: null,
          updatedAt: DateTime.now(),
        ),
      );

      return ManagedRoutingSyncResult.updated(profileId: source.profileId);
    } catch (e) {
      await _routingRepository.upsertManagedSource(
        source: source.copyWith(
          lastErrorAt: DateTime.now(),
          lastErrorMessage: e.toString(),
          updatedAt: DateTime.now(),
        ),
      );

      return ManagedRoutingSyncResult.failed(
        profileId: source.profileId,
        error: e.toString(),
      );
    }
  }

  Future<List<ManagedRoutingSyncResult>> syncAllManagedSources() async {
    final sources = await _routingRepository.getManagedSources();
    final result = <ManagedRoutingSyncResult>[];

    for (final source in sources) {
      result.add(await syncManagedSource(source: source));
    }

    return result;
  }

  Future<int> _createNewProfile({
    required String name,
    required HappRoutingMappingResult mapping,
  }) async => (await _routingRepository.addNewProfile(
    (
      name: name,
      defaultMode: mapping.defaultMode,
      bypassRules: mapping.bypassRules,
      vpnRules: mapping.vpnRules,
    ),
  )).id;

  Future<int> _updateProfile({
    required int id,
    required HappRoutingMappingResult mapping,
  }) async {
    await Future.wait([
      _routingRepository.setDefaultRoutingMode(id: id, mode: mapping.defaultMode),
      _routingRepository.setRules(id: id, mode: RoutingMode.bypass, rules: mapping.bypassRules),
      _routingRepository.setRules(id: id, mode: RoutingMode.vpn, rules: mapping.vpnRules),
    ]);

    return id;
  }

  String _buildUniqueName({
    required String desiredName,
    required Set<String> existingNames,
  }) {
    final baseName = desiredName.trim().isEmpty ? 'HAPP profile' : desiredName.trim();
    final normalizedNames = existingNames.map((name) => name.trim().toLowerCase()).toSet();

    if (!normalizedNames.contains(baseName.toLowerCase())) {
      return baseName;
    }

    for (var i = 2; i < 10000; i++) {
      final candidate = '$baseName ($i)';
      if (!normalizedNames.contains(candidate.toLowerCase())) {
        return candidate;
      }
    }

    return '$baseName ${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<_ResolvedConfig> _resolveConfig(Uri uri) async {
    if (uri.scheme.toLowerCase() == 'happ') {
      return _ResolvedConfig(config: _parseHappUri(uri), sourceUrl: uri.toString());
    }

    if (uri.scheme.toLowerCase() == 'http' || uri.scheme.toLowerCase() == 'https') {
      final response = await _fetchHttpRoutingPayload(uri);
      if (response.redirectUri != null) {
        final redirectUri = response.redirectUri!;
        if (redirectUri.scheme.toLowerCase() == 'happ') {
          return _ResolvedConfig(
            config: _parseHappUri(
              redirectUri,
              sourceUrlOverride: uri.toString(),
            ),
            sourceUrl: uri.toString(),
          );
        }

        if (redirectUri.scheme.toLowerCase() == 'http' || redirectUri.scheme.toLowerCase() == 'https') {
          return _resolveConfig(redirectUri);
        }

        throw FormatException('Unsupported HAPP redirect target: ${redirectUri.scheme}');
      }

      final content = response.text!.trim();

      if (content.startsWith('{')) {
        return _ResolvedConfig(
          config: HappRoutingConfig.fromSource(
            sourceUrl: uri.toString(),
            jsonPayload: content,
          ),
          sourceUrl: uri.toString(),
        );
      }

      final matchedLink = RegExp(r'happ://routing/(?:add|onadd)/[A-Za-z0-9\-_+=/]+').firstMatch(content)?.group(0);
      if (matchedLink != null) {
        final parsed = Uri.parse(matchedLink);
        return _ResolvedConfig(
          config: _parseHappUri(
            parsed,
            sourceUrlOverride: uri.toString(),
          ),
          sourceUrl: uri.toString(),
        );
      }

      throw const FormatException('Unsupported HAPP routing payload');
    }

    throw const FormatException('Unsupported HAPP routing link');
  }

  HappRoutingConfig _parseHappUri(
    Uri uri, {
    String? sourceUrlOverride,
  }) {
    final segments = uri.pathSegments;
    if (uri.host.toLowerCase() != 'routing' || segments.length < 2) {
      throw const FormatException('Invalid HAPP routing link');
    }

    final action = segments[0].toLowerCase();
    if (action != 'add' && action != 'onadd') {
      throw const FormatException('Unsupported HAPP routing action');
    }

    final encodedPayload = segments.skip(1).join('/');
    if (encodedPayload.isEmpty) {
      throw const FormatException('Invalid HAPP routing link');
    }

    final payload = _decodeBase64Any(encodedPayload);
    return HappRoutingConfig.fromSource(
      sourceUrl: sourceUrlOverride ?? uri.toString(),
      jsonPayload: payload,
    );
  }

  Future<_MaterializedConfig> _materialize(_ResolvedConfig resolved) async {
    final geositeResponse = await _fetchBinary(Uri.parse(resolved.config.geositeUrl));
    final geoipResponse = await _fetchBinary(Uri.parse(resolved.config.geoipUrl));

    final geosite = _geodataParser.parseGeosite(geositeResponse.bytes);
    final geoip = _geodataParser.parseGeoip(geoipResponse.bytes);
    final mapping = _mapper.map(
      config: resolved.config,
      geosite: geosite,
      geoip: geoip,
    );

    final contentHash = _sha256(
      jsonEncode({
        'source': resolved.config.sourceUrl,
        'geositeUrl': resolved.config.geositeUrl,
        'geoipUrl': resolved.config.geoipUrl,
        'globalProxy': resolved.config.globalProxy,
        'routeOrder': resolved.config.routeOrder.serialize(),
        'bypassRules': mapping.bypassRules,
        'vpnRules': mapping.vpnRules,
        'defaultMode': mapping.defaultMode.value,
      }),
    );

    final eTag = '${geositeResponse.eTag ?? ''}|${geoipResponse.eTag ?? ''}';

    return _MaterializedConfig(
      config: resolved.config,
      mapping: mapping,
      contentHash: contentHash,
      eTag: eTag.isEmpty ? null : eTag,
      globalMode: resolved.config.globalProxy ? ManagedRoutingGlobalMode.proxy : ManagedRoutingGlobalMode.direct,
    );
  }

  Future<_HttpRoutingPayloadResponse> _fetchHttpRoutingPayload(Uri uri) async {
    final request = await _httpClient.getUrl(uri);
    request.followRedirects = false;
    final response = await request.close();
    if (response.statusCode >= 300 && response.statusCode < 400) {
      final redirectValue = response.headers.value(HttpHeaders.locationHeader);
      if (redirectValue == null || redirectValue.trim().isEmpty) {
        throw HttpException('Failed to fetch HAPP config from $uri, redirect location is missing');
      }

      final parsedUri = Uri.tryParse(redirectValue.trim());
      if (parsedUri == null) {
        throw const FormatException('Invalid redirect URL in HAPP config response');
      }

      final resolvedUri = parsedUri.hasScheme ? parsedUri : uri.resolveUri(parsedUri);

      return _HttpRoutingPayloadResponse.redirect(redirectUri: resolvedUri);
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException('Failed to fetch HAPP config from $uri, status: ${response.statusCode}');
    }

    final bytes = await consolidateHttpClientResponseBytes(response);

    return _HttpRoutingPayloadResponse.text(
      text: utf8.decode(bytes, allowMalformed: true),
    );
  }

  Future<_BinaryResponse> _fetchBinary(Uri uri) async {
    final request = await _httpClient.getUrl(uri);
    final response = await request.close();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException('Failed to fetch geodata from $uri, status: ${response.statusCode}');
    }

    final bytes = await consolidateHttpClientResponseBytes(response);

    return _BinaryResponse(
      bytes: bytes,
      eTag: response.headers.value(HttpHeaders.etagHeader),
    );
  }

  String _decodeBase64Any(String value) {
    final normalized = value.trim().replaceAll('-', '+').replaceAll('_', '/');
    final padding = (4 - normalized.length % 4) % 4;
    final padded = '$normalized${'=' * padding}';

    try {
      final bytes = base64Decode(padded);
      return utf8.decode(bytes);
    } on FormatException {
      throw const FormatException('Invalid base64 payload in HAPP link');
    }
  }

  String _sha256(String content) => sha256.convert(utf8.encode(content)).toString();
}

final class _ResolvedConfig {
  final HappRoutingConfig config;
  final String sourceUrl;

  const _ResolvedConfig({
    required this.config,
    required this.sourceUrl,
  });
}

final class _MaterializedConfig {
  final HappRoutingConfig config;
  final HappRoutingMappingResult mapping;
  final String contentHash;
  final String? eTag;
  final ManagedRoutingGlobalMode globalMode;

  const _MaterializedConfig({
    required this.config,
    required this.mapping,
    required this.contentHash,
    required this.eTag,
    required this.globalMode,
  });
}

final class _BinaryResponse {
  final List<int> bytes;
  final String? eTag;

  const _BinaryResponse({
    required this.bytes,
    required this.eTag,
  });
}

final class _HttpRoutingPayloadResponse {
  final String? text;
  final Uri? redirectUri;

  const _HttpRoutingPayloadResponse._({
    required this.text,
    required this.redirectUri,
  });

  const _HttpRoutingPayloadResponse.text({required String text}) : this._(text: text, redirectUri: null);

  const _HttpRoutingPayloadResponse.redirect({required Uri redirectUri}) : this._(text: null, redirectUri: redirectUri);
}
