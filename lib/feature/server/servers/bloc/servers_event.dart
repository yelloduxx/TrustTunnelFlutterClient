part of 'servers_bloc.dart';

@freezed
sealed class ServersEvent with _$ServersEvent {
  const factory ServersEvent.fetch() = _Fetch;

  const factory ServersEvent.selectServer({
    required int? serverId,
  }) = _SelectServer;
}
