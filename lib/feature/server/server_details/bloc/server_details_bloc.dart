import 'dart:async';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vpn/common/error/error_utils.dart';
import 'package:vpn/common/error/model/presentation_base_error.dart';
import 'package:vpn/common/error/model/presentation_error.dart';
import 'package:vpn/common/error/model/presentation_field.dart';
import 'package:vpn/common/error/model/presentation_field_error.dart';
import 'package:vpn/data/model/routing_profile.dart';
import 'package:vpn/data/model/vpn_protocol.dart';
import 'package:vpn/data/repository/routing_repository.dart';
import 'package:vpn/data/repository/server_repository.dart';
import 'package:vpn/data/repository/vpn_repository.dart';
import 'package:vpn/feature/server/server_details/data/server_details_data.dart';
import 'package:vpn/feature/server/server_details/domain/server_details_service.dart';

part 'server_details_bloc.freezed.dart';
part 'server_details_event.dart';
part 'server_details_state.dart';

class ServerDetailsBloc extends Bloc<ServerDetailsEvent, ServerDetailsState> {
  final ServerRepository _serverRepository;
  final RoutingRepository _routingRepository;
  final ServerDetailsService _serverDetailsService;
  final VpnRepository _vpnRepository;
  late final ServerDetailsData _initialData;

  ServerDetailsBloc({
    int? serverId,
    required RoutingRepository routingRepository,
    required ServerRepository serverRepository,
    required ServerDetailsService serverDetailsService,
    required VpnRepository vpnRepository,
  }) : _serverRepository = serverRepository,
       _serverDetailsService = serverDetailsService,
       _routingRepository = routingRepository,
       _vpnRepository = vpnRepository,
       super(
         ServerDetailsState(
           serverId: serverId,
         ),
       ) {
    on<ServerDetailsEvent>(
      (event, emit) => switch (event) {
        _Fetch() => _fetch(event, emit),
        _Submit() => _submit(event, emit),
        _Delete() => _delete(event, emit),
        _DataChanged() => _dataChanged(event, emit),
      },
    );
  }

  Future<void> _fetch(
    _Fetch event,
    Emitter<ServerDetailsState> emit,
  ) async {
    try {
      final profiles = await _routingRepository.getAllProfiles();
      emit(state.copyWith(availableRoutingProfiles: profiles, ));

      if (state.serverId == null) {
        emit(
          state.copyWith(
            loadingStatus: ServerDetailsLoadingStatus.idle,
          ),
        );
        return;
      }

      final server = await _serverRepository.getServerById(id: state.serverId!);
      if (server == null) {
        throw PresentationNotFoundError();
      }
      _initialData = _serverDetailsService.toServerDetailsData(server: server);

      emit(
        state.copyWith(
          initialData: _initialData.copyWith(),
          data: _initialData.copyWith(),
        ),
      );
    } catch (e) {
      _onException(emit, e);
      rethrow;
    } finally {
      emit(state.copyWith(loadingStatus: ServerDetailsLoadingStatus.idle));
    }
  }

  Future<void> _dataChanged(
    _DataChanged event,
    Emitter<ServerDetailsState> emit,
  ) async => emit(
    state.copyWith(
      data: state.data.copyWith(
        serverName: event.serverName ?? state.data.serverName,
        ipAddress: event.ipAddress ?? state.data.ipAddress,
        domain: event.domain ?? state.data.domain,
        username: event.username ?? state.data.username,
        password: event.password ?? state.data.password,
        protocol: event.protocol ?? state.data.protocol,
        routingProfileId: event.routingProfileId ?? state.data.routingProfileId,
        dnsServers: event.dnsServers ?? state.data.dnsServers,
      ),
    ),
  );

  Future<void> _submit(
    _Submit event,
    Emitter<ServerDetailsState> emit,
  ) async {
    emit(state.copyWith(loadingStatus: ServerDetailsLoadingStatus.loading));

    final List<PresentationField> filedErrors = _serverDetailsService.validateData(data: state.data);

    if (filedErrors.isNotEmpty) {
      emit(
        state.copyWith(
          fieldErrors: filedErrors,
          loadingStatus: ServerDetailsLoadingStatus.idle,
        ),
      );
      return;
    }

    try {
      if (state.isEditing) {
        await _serverRepository.setNewServer(
          id: state.serverId!,
          request: (
            dnsServers: state.data.dnsServers,
            name: state.data.serverName,
            ipAddress: state.data.ipAddress,
            domain: state.data.domain,
            username: state.data.username,
            password: state.data.password,
            vpnProtocol: state.data.protocol,
            routingProfileId: state.data.routingProfileId,
          ),
        );
        emit(state.copyWith(action: const ServerDetailsAction.saved()));
      } else {
        await _serverRepository.addNewServer(
          request: (
            dnsServers: state.data.dnsServers,
            name: state.data.serverName,
            ipAddress: state.data.ipAddress,
            domain: state.data.domain,
            username: state.data.username,
            password: state.data.password,
            vpnProtocol: state.data.protocol,
            routingProfileId: state.data.routingProfileId,
          ),
        );
        emit(
          state.copyWith(
            action: ServerDetailsAction.created(state.data.serverName),
          ),
        );
      }

      emit(state.copyWith(action: const ServerDetailsAction.none()));
    } catch (e) {
      _onException(emit, e);
      rethrow;
    } finally {
      emit(state.copyWith(loadingStatus: ServerDetailsLoadingStatus.idle));
    }
  }

  Future<void> _delete(_Delete event, Emitter<ServerDetailsState> emit) async {
    try {
      emit(state.copyWith(loadingStatus: ServerDetailsLoadingStatus.loading));
      await _vpnRepository.stop();
      await _serverRepository.removeServer(serverId: state.serverId!);
      emit(state.copyWith(action: ServerDetailsAction.deleted(state.data.serverName)));
      emit(state.copyWith(action: const ServerDetailsAction.none()));
    } catch (e) {
      _onException(emit, e);
      rethrow;
    } finally {
      emit(state.copyWith(loadingStatus: ServerDetailsLoadingStatus.idle));
    }
  }

  Future<void> _onException(
    Emitter<ServerDetailsState> emit,
    Object exception,
  ) async {
    final PresentationError error = ErrorUtils.toPresentationError(exception: exception);

    if (error is PresentationFieldError) {
      emit(state.copyWith(fieldErrors: error.fields));
    }
    emit(state.copyWith(action: ServerDetailsAction.presentationError(error)));
    emit(state.copyWith(action: const ServerDetailsAction.none()));
  }
}
