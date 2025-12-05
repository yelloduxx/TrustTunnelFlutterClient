// You have generated a new plugin project without specifying the `--platforms`
// flag. A plugin project with no platform support was generated. To add a
// platform, run `flutter create -t plugin --platforms <platforms> .` under the
// same directory. You can also find a detailed instruction on how to add
// platforms in the `pubspec.yaml` at
// https://flutter.dev/docs/development/packages-and-plugins/developing-packages#plugin-platforms.

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:vpn_plugin/domain/configuration_encoder.dart';
import 'package:vpn_plugin/domain/query_log_encoder.dart';
import 'package:vpn_plugin/models/configuration.dart';
import 'package:vpn_plugin/models/query_log_row.dart';
import 'package:vpn_plugin/platform_api.g.dart';

abstract class VpnPlugin {
  Future<void> start({required Configuration configuration});

  Future<void> stop();

  abstract final Stream<VpnManagerState> states;

  abstract final Stream<QueryLogRow> queryLog;
}

class VpnPluginImpl implements VpnPlugin {
  VpnPluginImpl({
    EventChannel? channel,
    EventChannel? logChannel,
  }) : _api = IVpnManager(),
       _vpnChannel = channel ?? const EventChannel('vpn_plugin_event_channel'),
       _queryLogChannel = logChannel ?? const EventChannel('vpn_plugin_event_channel_query_log');

  final IVpnManager _api;
  final EventChannel _vpnChannel;
  final EventChannel _queryLogChannel;

  Future<VpnManagerState> getCurrentState() => _api.getCurrentState();

  final _logEncoder = QueryLogEncoder();

  @override
  Future<void> start({required Configuration configuration}) {
    final config = ConfigurationEncoder().convert(configuration);

    return _api.start(config: config);
  }

  @override
  Future<void> stop() => _api.stop();

  @override
  Stream<VpnManagerState> get states => _vpnChannel.receiveBroadcastStream().map(_mapNativeToState).distinct();

  @override
  Stream<QueryLogRow> get queryLog => _queryLogChannel.receiveBroadcastStream().map(
    (e) => _logEncoder.convert(jsonDecode(e.toString()) as Map<String, Object?>),
  );

  static VpnManagerState _mapNativeToState(dynamic raw) {
    if (raw is int) {
      switch (raw) {
        case 0:
          return VpnManagerState.disconnected;
        case 1:
          return VpnManagerState.connecting;
        case 2:
          return VpnManagerState.connected;
        case 3:
          return VpnManagerState.waitingForRecovery;
        case 4:
          return VpnManagerState.recovering;
        case 5:
          return VpnManagerState.waitingForNetwork;
      }
    }

    return VpnManagerState.disconnected;
  }
}
