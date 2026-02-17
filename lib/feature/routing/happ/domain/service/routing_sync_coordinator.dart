import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:trusttunnel/data/repository/settings_repository.dart';
import 'package:trusttunnel/feature/routing/happ/domain/service/happ_routing_import_service.dart';
import 'package:trusttunnel/feature/routing/happ/model/managed_routing_sync_result.dart';

typedef ManagedProfileUpdatedCallback = Future<void> Function(int profileId);

final class RoutingSyncCoordinator with WidgetsBindingObserver {
  final SettingsRepository _settingsRepository;
  final HappRoutingImportService _importService;
  final ManagedProfileUpdatedCallback _onProfileUpdated;

  Timer? _timer;
  bool _started = false;
  bool _syncInProgress = false;
  DateTime? _lastSyncAt;

  RoutingSyncCoordinator({
    required SettingsRepository settingsRepository,
    required HappRoutingImportService importService,
    required ManagedProfileUpdatedCallback onProfileUpdated,
  }) : _settingsRepository = settingsRepository,
       _importService = importService,
       _onProfileUpdated = onProfileUpdated;

  Future<void> start() async {
    if (_started) {
      return;
    }

    _started = true;
    WidgetsBinding.instance.addObserver(this);
    await _sync(force: false);
    await _reschedule();
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

  Future<List<ManagedRoutingSyncResult>> syncNow() => _sync(force: true);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_sync(force: false));
    }
  }

  Future<void> _reschedule() async {
    _timer?.cancel();
    _timer = null;

    final settings = await _settingsRepository.getRoutingSyncSettings();
    if (!settings.enabled) {
      return;
    }

    final duration = Duration(minutes: settings.intervalMinutes);
    _timer = Timer.periodic(duration, (_) => unawaited(_sync(force: false)));
  }

  Future<List<ManagedRoutingSyncResult>> _sync({required bool force}) async {
    if (_syncInProgress) {
      return const [];
    }

    final settings = await _settingsRepository.getRoutingSyncSettings();
    if (!settings.enabled && !force) {
      return const [];
    }

    final now = DateTime.now();
    if (!force && _lastSyncAt != null && now.difference(_lastSyncAt!) < Duration(minutes: settings.intervalMinutes)) {
      return const [];
    }

    _syncInProgress = true;
    _lastSyncAt = now;
    try {
      final result = await _importService.syncAllManagedSources();
      for (final item in result.where((element) => element.updated && element.error == null)) {
        await _onProfileUpdated(item.profileId);
      }

      return result;
    } finally {
      _syncInProgress = false;
      await _reschedule();
    }
  }
}
