part of 'routing_details_bloc.dart';

@freezed
sealed class RoutingDetailsEvent with _$RoutingDetailsEvent {
  const factory RoutingDetailsEvent.init() = _Init;

  const factory RoutingDetailsEvent.dataChanged({
    RoutingMode? defaultMode,
    List<String>? bypassRules,
    List<String>? vpnRules,
    bool? hasInvalidRules,
  }) = _DataChanged;

  const factory RoutingDetailsEvent.submit() = _Submit;

  const factory RoutingDetailsEvent.delete() = _Delete;

  const factory RoutingDetailsEvent.clear() = _Clear;

  const factory RoutingDetailsEvent.changeDefaultMode(RoutingMode defaultMode) = _ChangeDefaultMode;
}
