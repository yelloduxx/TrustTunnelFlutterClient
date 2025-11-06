import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vpn/data/model/vpn_request.dart';
import 'package:vpn/data/repository/settings_repository.dart';

part 'query_log_bloc.freezed.dart';
part 'query_log_event.dart';
part 'query_log_state.dart';

class QueryLogBloc extends Bloc<QueryLogEvent, QueryLogState> {
  final SettingsRepository _settingsRepository;

  QueryLogBloc({
    required SettingsRepository settingsRepository,
  }) : _settingsRepository = settingsRepository,
       super(const QueryLogState()) {
    on<QueryLogEvent>(
      (event, emit) => switch (event) {
        _Init() => _init(event, emit),
      },
    );
  }

  void _init(
    _Init event,
    Emitter<QueryLogState> emit,
  ) async => emit(
    state.copyWith(
      logs: await _settingsRepository.getAllRequests(),
    ),
  );
}
