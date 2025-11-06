part of 'server_details_bloc.dart';

@freezed
abstract class ServerDetailsState with _$ServerDetailsState {
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

  bool get isLoading => loadingStatus != ServerDetailsLoadingStatus.idle;

  RoutingProfile get selectedRoutingProfile =>
      availableRoutingProfiles.firstWhereOrNull((profile) => profile.id == data.routingProfileId) ??
      availableRoutingProfiles.first;
}

enum ServerDetailsLoadingStatus {
  initialLoading,
  loading,
  idle,
}

@Freezed(copyWith: false, fromJson: false, toJson: false)
sealed class ServerDetailsAction with _$ServerDetailsAction {
  const factory ServerDetailsAction.presentationError(PresentationError error) = ServerDetailsPresentationError;

  const factory ServerDetailsAction.saved() = ServerDetailsSaved;

  const factory ServerDetailsAction.created(String name) = ServerDetailsCreated;

  const factory ServerDetailsAction.deleted(String name) = ServerDetailsDeleted;

  const factory ServerDetailsAction.none() = _ServerDetailsNone;
}
