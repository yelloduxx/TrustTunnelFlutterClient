import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:vpn/data/repository/server_repository.dart';
import 'package:vpn_plugin/platform_api.g.dart';
import 'package:vpn_plugin/vpn_plugin.dart';

abstract class VpnService {
  ValueStream<VpnManagerState?> get vpnManagerStateStream;

  Future<void> start({required int serverId});

  Future<void> stop();

  Future<void> dispose();
}

class VpnServiceImpl implements VpnService {
  final PlatformApi _platformApi;
  final ServerRepository _serverRepository;

  late final StreamSubscription<dynamic> _vpnManagerStateSub;

  VpnServiceImpl({
    required PlatformApi platformApi,
    required ServerRepository serverRepository,
  })  : _platformApi = platformApi,
        _serverRepository = serverRepository {
    _init();
  }

  final BehaviorSubject<VpnManagerState?> _vpnManagerStateController = BehaviorSubject.seeded(null);

  void _init() async => _vpnManagerStateSub = VpnPlugin.eventChannel.receiveBroadcastStream().listen((event) {
        final state = VpnManagerState.values[event as int];
        _vpnManagerStateController.add(state);
      });

  @override
  ValueStream<VpnManagerState?> get vpnManagerStateStream => _vpnManagerStateController.stream;

  @override
  Future<void> start({required int serverId}) async {
    await _serverRepository.setSelectedServerId(id: serverId);
    await _platformApi.start();
  }

  @override
  Future<void> stop() => _platformApi.stop();

  @override
  Future<void> dispose() async {
    await _vpnManagerStateSub.cancel();
    await _vpnManagerStateController.close();
  }
}
