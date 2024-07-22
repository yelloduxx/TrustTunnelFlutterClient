part of 'routing_details_bloc.dart';

@freezed
sealed class RoutingDetailsState with _$RoutingDetailsState {
  const RoutingDetailsState._();

  const factory RoutingDetailsState({
    int? routingId,
    @Default('') String routingName,
    @Default(RoutingDetailsData()) RoutingDetailsData data,
    @Default(RoutingDetailsData()) RoutingDetailsData initialData,
    @Default(RoutingMode.values) List<RoutingMode> availableRoutingModes,
    @Default(RoutingDetailsLoadingStatus.initialLoading)
    RoutingDetailsLoadingStatus loadingStatus,
  }) = _RoutingDetailsState;

  bool get hasChanges => data != initialData;
}

enum RoutingDetailsLoadingStatus {
  initialLoading,
  loading,
  error,
  idle,
}
