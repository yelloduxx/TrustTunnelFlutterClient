import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:vpn/data/repository/server_repository.dart';
import 'package:vpn/domain/vpn_service.dart';
import 'package:vpn_plugin/platform_api.g.dart';

part 'servers_bloc.freezed.dart';
part 'servers_event.dart';
part 'servers_state.dart';

class ServersBloc extends Bloc<ServersEvent, ServersState> {
  final ServerRepository _serverRepository;
  final VpnService _vpnService;

  ServersBloc({
    required ServerRepository serverRepository,
    required VpnService vpnService,
  })  : _serverRepository = serverRepository,
        _vpnService = vpnService,
        super(const ServersState()) {
    on<_Init>(_init);
    on<_ConnectServer>(_connectServer);
    on<_DisconnectServer>(_disconnectServer);
    on<_DataChanged>(_dataChanged);

    _initSubs();
  }

  late final StreamSubscription<List<dynamic>> _serversSub;

  void _initSubs() {
    _serversSub = CombineLatestStream<dynamic, List<dynamic>>(
      [
        _serverRepository.serverStream.whereNotNull(),
        _serverRepository.selectedServerIdStream,
        _vpnService.vpnManagerStateStream.whereNotNull(),
      ],
      (values) => values,
    ).listen(
      (values) => add(
        ServersEvent.dataChanged(
          servers: List.of(values[0] as List<Server>),
          selectedServerId: values[1] as int?,
          vpnManagerState: values[2] as VpnManagerState,
        ),
      ),
    );
  }

  void _dataChanged(
    _DataChanged event,
    Emitter<ServersState> emit,
  ) =>
      emit(
        state.copyWith(
          serverList: event.servers,
          selectedServerId: event.selectedServerId,
          vpnManagerState: event.vpnManagerState,
          loadingState: ServerLoadingState.idle,
        ),
      );

  Future<void> _init(
    _Init event,
    Emitter<ServersState> emit,
  ) =>
      _serverRepository.loadServers();

  Future<void> _connectServer(
    _ConnectServer event,
    Emitter<ServersState> emit,
  ) =>
      _vpnService.start(serverId: event.serverId);

  void _disconnectServer(
    _DisconnectServer event,
    Emitter<ServersState> emit,
  ) =>
      _vpnService.stop();

  @override
  Future<void> close() {
    _serversSub.cancel();
    return super.close();
  }
}
