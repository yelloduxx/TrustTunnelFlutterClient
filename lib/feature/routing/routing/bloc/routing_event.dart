part of 'routing_bloc.dart';

@freezed
sealed class RoutingEvent with _$RoutingEvent {
  const factory RoutingEvent.fetch() = _Fetch;

  const factory RoutingEvent.dataChanged({List<PresentationField>? fieldError}) = _DataChanged;

  const factory RoutingEvent.editName({required int id, required String newName}) = _EditName;

  const factory RoutingEvent.deleteProfile({required int id}) = _DeleteProfile;
}
