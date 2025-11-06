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
    @Default(false) bool hasInvalidRules,
  }) = _RoutingDetailsState;

  DeepCollectionEquality get _collectionEquality => const DeepCollectionEquality();

  bool get hasChanges => !_collectionEquality.equals(data, initialData);

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

  const factory RoutingDetailsAction.created(
    String name,
  ) = RoutingDetailsCreated;

  const factory RoutingDetailsAction.deleted(
    String name,
  ) = RoutingDetailsDeleted;

  const factory RoutingDetailsAction.cleared() = RoutingDetailsCleared;

  const factory RoutingDetailsAction.defaultModeChanged() = RoutingDetailsDefaultModeChanged;

  const factory RoutingDetailsAction.none() = _RoutingDetailsNone;
}
