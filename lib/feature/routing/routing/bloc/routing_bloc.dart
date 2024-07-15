import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'routing_bloc.freezed.dart';
part 'routing_event.dart';
part 'routing_state.dart';

class RoutingBloc extends Bloc<RoutingEvent, RoutingState> {
  RoutingBloc() : super(const RoutingState()) {
    on<_Init>(_init);
  }

  void _init(
    _Init event,
    Emitter<RoutingState> emit,
  ) =>
      emit(
        state.copyWith(
          routingList: List.filled(
            10,
            Object(),
          ),
        ),
      );
}
