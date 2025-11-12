import 'dart:async';
import 'dart:collection';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vpn/common/error/error_utils.dart';
import 'package:vpn/common/error/model/presentation_error.dart';
import 'package:vpn/data/model/server.dart';
import 'package:vpn/data/repository/server_repository.dart';

part 'servers_bloc.freezed.dart';
part 'servers_event.dart';
part 'servers_state.dart';

class ServersBloc extends Bloc<ServersEvent, ServersState> {
  final ServerRepository _serverRepository;

  ServersBloc({
    required ServerRepository serverRepository,
  }) : _serverRepository = serverRepository,
       super(const ServersState()) {
    on<ServersEvent>(
      (event, emit) => switch (event) {
        _Fetch() => _fetch(event, emit),
        _SelectServer() => _selectServer(event, emit),
      },
    );
  }

  Future<void> _fetch(
    _Fetch event,
    Emitter<ServersState> emit,
  ) async {
    try {
      emit(state.copyWith(loadingState: ServerLoadingState.initialLoading));
      final servers = await _serverRepository.getAllServers();
      emit(
        state.copyWith(
          loadingState: ServerLoadingState.idle,
          serverList: servers,
          selectedServerId: servers.where((s) => s.selected).firstOrNull?.id,
        ),
      );
    } catch (e) {
      _onException(emit, e);
      rethrow;
    } finally {
      emit(state.copyWith(loadingState: ServerLoadingState.idle));
    }
  }

  Future<void> _selectServer(
    _SelectServer event,
    Emitter<ServersState> emit,
  ) async {
    if (event.serverId == null) {
      emit(state.copyWith(selectedServerId: null));
      return;
    }

    try {
      emit(state.copyWith(loadingState: ServerLoadingState.loading));
      await _serverRepository.setSelectedServerId(id: event.serverId!);

      emit(
        state.copyWith(
          selectedServerId: event.serverId,
        ),
      );
    } catch (e) {
      _onException(emit, e);
      rethrow;
    } finally {
      emit(state.copyWith(loadingState: ServerLoadingState.idle));
    }
  }

  Future<void> _onException(
    Emitter<ServersState> emit,
    Object exception,
  ) async {
    final PresentationError error = ErrorUtils.toPresentationError(exception: exception);

    emit(state.copyWith(action: ServerAction.presentationError(error)));
    emit(state.copyWith(action: const ServerAction.none()));
  }
}
