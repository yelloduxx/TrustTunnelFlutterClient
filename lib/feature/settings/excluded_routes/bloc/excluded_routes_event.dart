part of 'excluded_routes_bloc.dart';

@freezed
sealed class ExcludedRoutesEvent with _$ExcludedRoutesEvent {
  const factory ExcludedRoutesEvent.init() = _Init;

  const factory ExcludedRoutesEvent.dataChanged({required String excludedRoutes}) = _DataChanged;

  const factory ExcludedRoutesEvent.saveExcludedRoutes() = _SaveExcludedRoutes;
}
