import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vpn/data/model/routing_mode.dart';

part 'vpn_request.freezed.dart';

@freezed
abstract class VpnRequest with _$VpnRequest {
  const factory VpnRequest({
    required int id,
    required DateTime zonedDateTime,
    required String protocolName,
    required RoutingMode decision,
    required String sourceIpAddress,
    required String destinationIpAddress,
    String? sourcePort,
    String? destinationPort,
    String? domain,
  }) = _VpnRequest;
}
