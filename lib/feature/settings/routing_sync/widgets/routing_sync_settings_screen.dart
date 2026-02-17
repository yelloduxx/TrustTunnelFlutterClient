import 'package:flutter/material.dart';
import 'package:trusttunnel/common/extensions/context_extensions.dart';
import 'package:trusttunnel/feature/routing/happ/widgets/routing_sync_coordinator_scope.dart';
import 'package:trusttunnel/widgets/custom_app_bar.dart';
import 'package:trusttunnel/widgets/scaffold_wrapper.dart';

class RoutingSyncSettingsScreen extends StatefulWidget {
  const RoutingSyncSettingsScreen({super.key});

  @override
  State<RoutingSyncSettingsScreen> createState() => _RoutingSyncSettingsScreenState();
}

class _RoutingSyncSettingsScreenState extends State<RoutingSyncSettingsScreen> {
  static const _allowedIntervals = <int>[
    15,
    30,
    60,
    180,
    720,
  ];

  bool _loading = true;
  bool _enabled = true;
  int _interval = 30;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) => ScaffoldWrapper(
    child: Scaffold(
      appBar: const CustomAppBar(
        title: 'Routing Sync',
        leadingIconType: AppBarLeadingIconType.back,
      ),
      body: _loading
          ? const SizedBox.shrink()
          : ListView(
              children: [
                SwitchListTile(
                  title: const Text('Enable auto-update'),
                  subtitle: const Text('Sync managed HAPP routing profiles while app is active'),
                  value: _enabled,
                  onChanged: (value) => _updateSettings(enabled: value),
                ),
                const Divider(),
                ListTile(
                  title: const Text('Update interval'),
                  subtitle: DropdownButton<int>(
                    value: _interval,
                    isExpanded: true,
                    items: _allowedIntervals
                        .map(
                          (value) => DropdownMenuItem<int>(
                            value: value,
                            child: Text(_formatInterval(value)),
                          ),
                        )
                        .toList(),
                    onChanged: _enabled ? (value) => _updateSettings(intervalMinutes: value) : null,
                  ),
                ),
                const Divider(),
                ListTile(
                  title: const Text('Sync now'),
                  subtitle: const Text('Run update check immediately for managed profiles'),
                  trailing: FilledButton(
                    onPressed: _enabled ? _syncNow : null,
                    child: const Text('Run'),
                  ),
                ),
              ],
            ),
    ),
  );

  Future<void> _load() async {
    final settings = await context.repositoryFactory.settingsRepository.getRoutingSyncSettings();
    if (!mounted) {
      return;
    }

    setState(() {
      _enabled = settings.enabled;
      _interval = _allowedIntervals.contains(settings.intervalMinutes) ? settings.intervalMinutes : 30;
      _loading = false;
    });
  }

  Future<void> _updateSettings({
    bool? enabled,
    int? intervalMinutes,
  }) async {
    final nextEnabled = enabled ?? _enabled;
    final nextInterval = intervalMinutes ?? _interval;

    setState(() {
      _enabled = nextEnabled;
      _interval = nextInterval;
    });

    await context.repositoryFactory.settingsRepository.setRoutingSyncSettings(
      enabled: nextEnabled,
      intervalMinutes: nextInterval,
    );
  }

  Future<void> _syncNow() async {
    final coordinator = RoutingSyncCoordinatorScope.of(context, listen: false);
    final result = await coordinator.syncNow();
    if (!mounted) return;

    final updatedCount = result.where((item) => item.updated && item.error == null).length;
    final failedCount = result.where((item) => item.error != null).length;
    context.showInfoSnackBar(
      message: 'Sync finished. Updated: $updatedCount, Failed: $failedCount',
    );
  }

  String _formatInterval(int minutes) => switch (minutes) {
    15 => '15 minutes',
    30 => '30 minutes',
    60 => '1 hour',
    180 => '3 hours',
    720 => '12 hours',
    _ => '$minutes minutes',
  };
}
