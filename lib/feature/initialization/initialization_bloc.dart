import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vpn/di/common/initialization_helper.dart';
import 'package:vpn/di/common/initialization_result.dart';

part 'initialization_bloc.freezed.dart';
part 'initialization_event.dart';
part 'initialization_state.dart';

class InitializationBloc extends Bloc<InitializationEvent, InitializationState> {
  final InitializationHelper initializationHelper;

  InitializationBloc({required this.initializationHelper}) : super(const InitializationState()) {
    on<InitializationEvent>(
      (event, emit) => switch (event) {
        _InitEvent() => _init(event, emit),
      },
    );
  }

  Future<void> _init(
    _InitEvent event,
    Emitter<InitializationState> emit,
  ) async => emit(
    state.copyWith(
      initializationResult: await initializationHelper.init(),
    ),
  );
}
