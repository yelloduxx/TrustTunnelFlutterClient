part of 'routing_details_bloc.dart';

@freezed
class RoutingDetailsEvent with _$RoutingDetailsEvent {
  const factory RoutingDetailsEvent.init() = _Init;

  const factory RoutingDetailsEvent.dataChanged({
    RoutingMode? defaultMode,
    List<String>? bypassRules,
    List<String>? vpnRules,
  }) = _DataChanged;

  const factory RoutingDetailsEvent.addRouting() = _AddRouting;
}
