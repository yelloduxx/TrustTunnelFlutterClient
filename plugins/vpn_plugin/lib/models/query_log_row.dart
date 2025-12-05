import 'package:vpn_plugin/models/connection_protocol.dart';
import 'package:vpn_plugin/models/query_log_action.dart';

class QueryLogRow {
  final QueryLogAction action;
  final ConnectionProtocol protocol;
  final String source;
  final String destination;
  final String? domain;
  final DateTime stamp;

  QueryLogRow({
    required this.action,
    required this.source,
    required this.destination,
    required this.protocol,
    required this.stamp,
    this.domain,
  });

  @override
  String toString() =>
      'QueryLogRow(action: $action, protocol: $protocol, source: $source, destination: $destination, domain: $domain)';
}
