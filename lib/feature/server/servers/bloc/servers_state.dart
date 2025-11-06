part of 'servers_bloc.dart';

@freezed
abstract class ServersState with _$ServersState {
  const factory ServersState({
    @Default([]) List<Server> serverList,
    int? selectedServerId,
    @Default(ServerLoadingState.initialLoading) ServerLoadingState loadingState,
    @Default(ServerAction.none()) ServerAction action,
  }) = _ServersState;
}

@freezed
sealed class ServerAction with _$ServerAction {
  const factory ServerAction.presentationError(PresentationError error) = ServerPresentationError;

  const factory ServerAction.none() = _ServerNone;
}

enum ServerLoadingState {
  initialLoading,
  loading,
  error,
  idle,
}
