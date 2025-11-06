part of 'initialization_bloc.dart';

@freezed
abstract class InitializationState with _$InitializationState {
  const factory InitializationState({
    InitializationResult? initializationResult,
  }) = _InitializationState;
}
