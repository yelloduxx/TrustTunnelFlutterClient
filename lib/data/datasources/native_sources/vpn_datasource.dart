import 'dart:async';

import 'package:vpn/common/extensions/model_extensions.dart';
import 'package:vpn/common/utils/upstream_protocol_encoder.dart';
import 'package:vpn/common/utils/vpn_mode_encoder.dart';
import 'package:vpn/data/datasources/vpn_datasource.dart';
import 'package:vpn/data/model/routing_profile.dart';
import 'package:vpn/data/model/server.dart';
import 'package:vpn/data/model/vpn_log.dart';
import 'package:vpn/data/model/vpn_state.dart';
import 'package:vpn/feature/vpn/domain/services/vpn_log_converter.dart';
import 'package:vpn_plugin/models/configuration.dart';
import 'package:vpn_plugin/models/endpoint.dart';
import 'package:vpn_plugin/models/query_log_row.dart';
import 'package:vpn_plugin/models/socks.dart';
import 'package:vpn_plugin/models/tun.dart';
import 'package:vpn_plugin/platform_api.g.dart' as p;
import 'package:vpn_plugin/vpn_plugin.dart';

class VpnDataSourceImpl implements VpnDataSource {
  final VpnPlugin _platformApi;

  VpnDataSourceImpl({
    required VpnPlugin vpnPlugin,
  }) : _platformApi = vpnPlugin;

  @override
  Stream<VpnState> get vpnState => _platformApi.states.transform(
    StreamTransformer<p.VpnManagerState, VpnState>.fromHandlers(
      handleData: (data, sink) => sink.add(
        VpnStateFromApi.parse(data),
      ),
      handleDone: (sink) async {
        await _platformApi.stop();
        sink.add(VpnState.disconnected);
        sink.close();
      },
    ),
  );

  @override
  Stream<VpnLog> get vpnLogs => _platformApi.queryLog.transform(
    StreamTransformer<QueryLogRow, VpnLog>.fromHandlers(
      handleData: (data, sink) => sink.add(
        VpnLogConverter().convert(data),
      ),
      handleDone: (sink) {
        sink.close();
      },
    ),
  );

  @override
  Future<void> start({
    required Server server,
    required RoutingProfile routingProfile,
  }) {
    final endPoint = Endpoint(
      hostName: server.domain,
      hasIpv6: true,
      username: server.username,
      password: server.password,
      addresses: [
        server.ipAddress,
      ],
      upStreamProtocol: UpStreamProtocolEncoder().convert(
        server.vpnProtocol,
      ),
    );

    return _platformApi.start(
      configuration: Configuration(
        vpnMode: VpnModeEncoder().convert(
          routingProfile.defaultMode,
        ),
        endpoint: endPoint,
        tun: Tun(),
        socks: Socks(),
      ),
    );
  }

  @override
  Future<void> stop() => _platformApi.stop();
}
