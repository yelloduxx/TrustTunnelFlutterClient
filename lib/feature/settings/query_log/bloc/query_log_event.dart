part of 'query_log_bloc.dart';

@freezed
sealed class QueryLogEvent with _$QueryLogEvent {
  const factory QueryLogEvent.init() = _Init;
}
