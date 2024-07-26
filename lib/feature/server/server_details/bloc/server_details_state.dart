part of 'server_details_bloc.dart';

@freezed
sealed class ServerDetailsState with _$ServerDetailsState {
  const ServerDetailsState._();

  const factory ServerDetailsState({
    int? serverId,
    @Default(ServerDetailsData()) ServerDetailsData data,
    @Default(ServerDetailsData()) ServerDetailsData initialData,
    @Default(ServerDetailsLoadingStatus.initialLoading) ServerDetailsLoadingStatus loadingStatus,
    @Default(ServerDetailsAction.none()) ServerDetailsAction action,
    @Default([]) List<PresentationField> fieldErrors,
    @Default(<RoutingProfile>[]) List<RoutingProfile> availableRoutingProfiles,
  }) = _ServersDetailsState;

  bool get isEditing => serverId != null;

  bool get hasChanges => data != initialData;

  RoutingProfile get selectedRoutingProfile => availableRoutingProfiles.firstWhere(
        (profile) => profile.id == data.routingProfileId,
      );
}

enum ServerDetailsLoadingStatus {
  initialLoading,
  idle,
}

@Freezed(
  copyWith: false,
  fromJson: false,
  toJson: false,
)
sealed class ServerDetailsAction with _$ServerDetailsAction {
  const factory ServerDetailsAction.presentationError(
    PresentationError error,
  ) = ServerDetailsPresentationError;

  const factory ServerDetailsAction.saved() = ServerDetailsSaved;

  const factory ServerDetailsAction.deleted() = ServerDetailsDeleted;

  const factory ServerDetailsAction.none() = _ServerDetailsNone;
}
