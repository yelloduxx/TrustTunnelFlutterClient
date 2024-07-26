part of 'routing_bloc.dart';

@freezed
class RoutingEvent with _$RoutingEvent {
  const factory RoutingEvent.init() = _Init;

  const factory RoutingEvent.dataChanged({
    required List<RoutingProfile> profiles,
  }) = _DataChanged;

  const factory RoutingEvent.editName({
    required int id,
    required String newName,
  }) = _EditName;

  const factory RoutingEvent.deleteProfile({
    required int id,
  }) = _DeleteProfile;
}
