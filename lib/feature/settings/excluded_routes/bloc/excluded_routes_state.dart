part of 'excluded_routes_bloc.dart';

@freezed
abstract class ExcludedRoutesState with _$ExcludedRoutesState {
  const ExcludedRoutesState._();

  const factory ExcludedRoutesState({
    @Default('') String excludedRoutes,
    @Default('') String initialExcludedRoutes,
    @Default(ExcludedRoutesAction.none) ExcludedRoutesAction action,
    @Default(ExcludedRoutesLoadingStatus.initialLoading) ExcludedRoutesLoadingStatus loadingStatus,
  }) = _ExcludedRoutesState;

  bool get isLoading => loadingStatus != ExcludedRoutesLoadingStatus.idle;

  bool get hasChanges => excludedRoutes != initialExcludedRoutes;
}

enum ExcludedRoutesLoadingStatus {
  initialLoading,
  loading,
  idle,
}

enum ExcludedRoutesAction {
  saved,
  none,
}
