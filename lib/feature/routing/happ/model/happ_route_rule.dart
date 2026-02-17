import 'package:meta/meta.dart';
import 'package:trusttunnel/feature/routing/happ/model/happ_outbound.dart';

@immutable
class HappRouteRule {
  final HappOutbound outbound;
  final String value;
  final bool geoRule;

  const HappRouteRule({
    required this.outbound,
    required this.value,
    required this.geoRule,
  });
}
