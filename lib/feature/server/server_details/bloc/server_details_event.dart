part of 'server_details_bloc.dart';

@freezed
sealed class ServerDetailsEvent with _$ServerDetailsEvent {
  const factory ServerDetailsEvent.fetch() = _Fetch;

  const factory ServerDetailsEvent.dataChanged({
    String? serverName,
    String? ipAddress,
    String? domain,
    String? username,
    String? password,
    VpnProtocol? protocol,
    int? routingProfileId,
    List<String>? dnsServers,
  }) = _DataChanged;

  const factory ServerDetailsEvent.submit() = _Submit;

  const factory ServerDetailsEvent.delete() = _Delete;
}
