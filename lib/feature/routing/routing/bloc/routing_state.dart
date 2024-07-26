part of 'routing_bloc.dart';

@freezed
class RoutingState with _$RoutingState {
  const RoutingState._();

  const factory RoutingState({
    @Default([]) List<RoutingProfile> routingList,
  }) = _RoutingState;
}
