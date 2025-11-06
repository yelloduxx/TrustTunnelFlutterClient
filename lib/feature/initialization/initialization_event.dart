part of 'initialization_bloc.dart';

@freezed
sealed class InitializationEvent with _$InitializationEvent {
  const factory InitializationEvent.init() = _InitEvent;
}
