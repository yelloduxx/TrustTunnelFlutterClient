import 'package:vpn/common/error/model/enum/presentation_field_error_code.dart';
import 'package:vpn/common/error/model/enum/presentation_field_name.dart';
import 'package:vpn/common/error/model/presentation_field.dart';
import 'package:vpn/data/repository/server_repository.dart';
import 'package:vpn/domain/vpn_service.dart';
import 'package:vpn/feature/server/server_details/data/server_details_data.dart';
import 'package:vpn_plugin/platform_api.g.dart';

abstract class ServerDetailsService {
  List<PresentationField> validateData({required ServerDetailsData data});

  AddServerRequest toAddServerRequest({required ServerDetailsData data});

  UpdateServerRequest toUpdateServerRequest({
    required int id,
    required ServerDetailsData data,
  });

  Future<void> deleteServer({required int serverId});

  ServerDetailsData toServerDetailsData({required Server server});
}

class ServerDetailsServiceImpl implements ServerDetailsService {
  final ServerRepository _serverRepository;
  final VpnService _vpnService;

  ServerDetailsServiceImpl({
    required ServerRepository serverRepository,
    required VpnService vpnService,
  })  : _serverRepository = serverRepository,
        _vpnService = vpnService;

  @override
  List<PresentationField> validateData({required ServerDetailsData data}) {
    final List<PresentationField> fields = [];
    if (data.serverName.isEmpty) {
      fields.add(_getRequiredField(PresentationFieldName.serverName));
    }
    if (data.ipAddress.isEmpty) {
      fields.add(_getRequiredField(PresentationFieldName.ipAddress));
    }
    if (data.domain.isEmpty) {
      fields.add(_getRequiredField(PresentationFieldName.domain));
    }
    if (data.username.isEmpty) {
      fields.add(_getRequiredField(PresentationFieldName.userName));
    }
    if (data.password.isEmpty) {
      fields.add(_getRequiredField(PresentationFieldName.password));
    }
    if (data.dnsServers.isEmpty) {
      fields.add(_getRequiredField(PresentationFieldName.dnsServers));
    }

    return fields;
  }

  @override
  AddServerRequest toAddServerRequest({required ServerDetailsData data}) => AddServerRequest(
        name: data.serverName,
        ipAddress: data.ipAddress,
        domain: data.domain,
        login: data.username,
        password: data.password,
        vpnProtocol: data.protocol,
        dnsServers: data.dnsServers,
        routingProfileId: data.routingProfileId,
      );

  @override
  UpdateServerRequest toUpdateServerRequest({
    required int id,
    required ServerDetailsData data,
  }) =>
      UpdateServerRequest(
        id: id,
        name: data.serverName,
        ipAddress: data.ipAddress,
        domain: data.domain,
        login: data.username,
        password: data.password,
        vpnProtocol: data.protocol,
        dnsServers: data.dnsServers,
        routingProfileId: data.routingProfileId,
      );

  @override
  Future<void> deleteServer({required int serverId}) async {
    if (serverId == await _serverRepository.getSelectedServerId()) {
      await _vpnService.stop();
    }

    await _serverRepository.deleteServer(serverId: serverId);
  }

  @override
  ServerDetailsData toServerDetailsData({required Server server}) => ServerDetailsData(
        serverName: server.name,
        ipAddress: server.ipAddress,
        domain: server.domain,
        username: server.login,
        password: server.password,
        protocol: server.vpnProtocol,
        routingProfileId: server.routingProfileId,
        dnsServers: server.dnsServers.cast<String>(),
      );

  PresentationField _getRequiredField(PresentationFieldName fieldName) => PresentationField(
        code: PresentationFieldErrorCode.fieldRequired,
        fieldName: fieldName,
      );
}
