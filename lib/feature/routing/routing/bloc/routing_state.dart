part of 'routing_bloc.dart';

@freezed
abstract class RoutingState with _$RoutingState {
  const factory RoutingState({
    @Default([]) List<RoutingProfile> routingList,
  }) = _RoutingState;
}
