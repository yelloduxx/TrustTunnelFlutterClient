part of 'query_log_bloc.dart';

@freezed
abstract class QueryLogState with _$QueryLogState {
  const factory QueryLogState({@Default([]) List<VpnRequest> logs}) = _QueryLogState;
}
