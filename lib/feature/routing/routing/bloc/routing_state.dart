part of 'routing_bloc.dart';

@freezed
abstract class RoutingState with _$RoutingState {
  const factory RoutingState({
    @Default([]) List<RoutingProfile> routingList,
    @Default([]) List<PresentationField> fieldErrors,
    @Default(RoutingAction.none()) RoutingAction action,
  }) = _RoutingState;
}

@Freezed(copyWith: false, fromJson: false, toJson: false)
sealed class RoutingAction with _$RoutingAction {
  const factory RoutingAction.presentationError(PresentationError error) = RoutingActionError;

  const factory RoutingAction.saved() = RoutingActionSaved;

  const factory RoutingAction.deleted() = RoutingActionDeleted;

  const factory RoutingAction.none() = _RoutingActionNone;
}
