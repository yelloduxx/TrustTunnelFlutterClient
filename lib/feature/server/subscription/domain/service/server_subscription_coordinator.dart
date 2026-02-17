import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:trusttunnel/data/repository/server_repository.dart';
import 'package:trusttunnel/feature/server/subscription/domain/service/server_subscription_service.dart';

/// Callback invoked when a server's config has been updated from its
/// subscription. Receives the server id that was updated.
typedef ServerUpdatedCallback = Future<void> Function(int serverId);

/// Periodically refreshes server configs from their subscription URLs.
///
/// Follows the same pattern as [RoutingSyncCoordinator]: timer-based
/// periodic sync with app lifecycle awareness.
final class ServerSubscriptionCoordinator with WidgetsBindingObserver {
  final ServerRepository _serverRepository;
  final ServerSubscriptionService _subscriptionService;
  final ServerUpdatedCallback _onServerUpdated;

  static const _syncInterval = Duration(minutes: 30);

  Timer? _timer;
  bool _started = false;
  bool _syncInProgress = false;
  DateTime? _lastSyncAt;

  ServerSubscriptionCoordinator({
    required ServerRepository serverRepository,
    required ServerSubscriptionService subscriptionService,
    required ServerUpdatedCallback onServerUpdated,
  }) : _serverRepository = serverRepository,
       _subscriptionService = subscriptionService,
       _onServerUpdated = onServerUpdated;

  Future<void> start() async {
    if (_started) {
      return;
    }

    _started = true;
    WidgetsBinding.instance.addObserver(this);
    await _sync();
    _reschedule();
  }

  Future<void> dispose() async {
    if (!_started) {
      return;
    }

    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _timer = null;
    _started = false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_sync());
    }
  }

  void _reschedule() {
    _timer?.cancel();
    _timer = Timer.periodic(_syncInterval, (_) => unawaited(_sync()));
  }

  Future<void> _sync() async {
    if (_syncInProgress) {
      return;
    }

    final now = DateTime.now();
    if (_lastSyncAt != null && now.difference(_lastSyncAt!) < _syncInterval) {
      return;
    }

    _syncInProgress = true;
    _lastSyncAt = now;
    try {
      final servers = await _serverRepository.getAllServers();
      final subscribedServers = servers.where((s) => s.subscriptionUrl != null && s.subscriptionUrl!.isNotEmpty);

      for (final server in subscribedServers) {
        try {
          final updated = await _subscriptionService.refreshServer(server);
          if (updated) {
            await _onServerUpdated(server.id);
          }
        } catch (_) {
          // Skip individual server errors — retry next cycle.
        }
      }
    } finally {
      _syncInProgress = false;
    }
  }
}
