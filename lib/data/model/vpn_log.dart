import 'package:vpn/data/model/vpn_log_action.dart';
import 'package:vpn/data/model/vpn_log_protocol.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'vpn_log.freezed.dart';

@freezed
abstract class VpnLog with _$VpnLog {
  const factory VpnLog({
    required VpnLogAction action,
    required VpnLogProtocol protocol,
    required DateTime timeStamp,
    required String source,
    required String destination,
    String? domain,
  }) = _VpnLog;
}
