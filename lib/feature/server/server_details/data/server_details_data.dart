import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vpn/data/model/vpn_protocol.dart';
import 'package:vpn/feature/routing/routing/common/routing_profile_utils.dart';

part 'server_details_data.freezed.dart';

@freezed
abstract class ServerDetailsData with _$ServerDetailsData {
  const factory ServerDetailsData({
    @Default('') String serverName,
    @Default('') String ipAddress,
    @Default('') String domain,
    @Default('') String username,
    @Default('') String password,
    @Default(VpnProtocol.http2) VpnProtocol protocol,
    @Default(RoutingProfileUtils.defaultRoutingProfileId) int routingProfileId,
    @Default(<String>[]) List<String> dnsServers,
  }) = _ServerDetailsData;
}
