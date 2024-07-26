part of 'servers_bloc.dart';

@freezed
class ServersState with _$ServersState {
  const ServersState._();

  const factory ServersState({
    @Default([]) List<Server> serverList,
    int? selectedServerId,
    @Default(VpnManagerState.disconnected) VpnManagerState vpnManagerState,
    @Default(ServerLoadingState.initialLoading) ServerLoadingState loadingState,
  }) = _ServersState;
}

enum ServerLoadingState {
  initialLoading,
  loading,
  error,
  idle,
}
