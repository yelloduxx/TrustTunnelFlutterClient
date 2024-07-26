part of 'routing_details_bloc.dart';

@freezed
sealed class RoutingDetailsState with _$RoutingDetailsState {
  const RoutingDetailsState._();

  const factory RoutingDetailsState({
    int? routingId,
    @Default('') String routingName,
    @Default(RoutingDetailsData()) RoutingDetailsData data,
    @Default(RoutingDetailsData()) RoutingDetailsData initialData,
    @Default(RoutingDetailsLoadingStatus.initialLoading) RoutingDetailsLoadingStatus loadingStatus,
    @Default(RoutingDetailsAction.none()) RoutingDetailsAction action,
  }) = _RoutingDetailsState;

  bool get hasChanges => data != initialData;

  bool get isEditing => routingId != null;
}

enum RoutingDetailsLoadingStatus {
  initialLoading,
  idle,
}

@Freezed(
  copyWith: false,
  fromJson: false,
  toJson: false,
)
sealed class RoutingDetailsAction with _$RoutingDetailsAction {
  const factory RoutingDetailsAction.presentationError(
    PresentationError error,
  ) = RoutingDetailsPresentationError;

  const factory RoutingDetailsAction.saved() = RoutingDetailsSaved;

  const factory RoutingDetailsAction.none() = _RoutingDetailsNone;
}
