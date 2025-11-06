import 'dart:io';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vpn/common/error/error_utils.dart';
import 'package:vpn/common/error/model/presentation_base_error.dart';

import 'package:vpn/common/error/model/presentation_error.dart';
import 'package:vpn/data/model/routing_mode.dart';
import 'package:vpn/data/repository/routing_repository.dart';
import 'package:vpn/feature/routing/routing_details/data/routing_details_data.dart';
import 'package:vpn/feature/routing/routing_details/domain/routing_details_service.dart';

part 'routing_details_bloc.freezed.dart';
part 'routing_details_event.dart';
part 'routing_details_state.dart';

class RoutingDetailsBloc extends Bloc<RoutingDetailsEvent, RoutingDetailsState> {
  final RoutingRepository _routingRepository;
  final RoutingDetailsService _routingDetailsService;

  RoutingDetailsBloc({
    int? routingId,
    required RoutingRepository routingRepository,
    required RoutingDetailsService routingDetailsService,
  }) : _routingRepository = routingRepository,
       _routingDetailsService = routingDetailsService,
       super(RoutingDetailsState(routingId: routingId)) {
    on<RoutingDetailsEvent>(
      (event, emit) => switch (event) {
        _Init() => _init(event, emit),
        _Submit() => _submit(event, emit),
        _DataChanged() => _dataChanged(event, emit),
        _Delete() => _delete(event, emit),
        _Clear() => _clear(event, emit),
        _ChangeDefaultMode() => _changeDefaultMode(event, emit),
      },
      transformer: sequential(),
    );
  }

  Future<void> _init(
    _Init event,
    Emitter<RoutingDetailsState> emit,
  ) async {
    if (state.routingId != null) {
      try {
        final routingProfile = await _routingRepository.getProfileById(id: state.routingId!);
        if (routingProfile == null) {
          throw PresentationNotFoundError();
        }
        final initialData = _routingDetailsService.toRoutingDetailsData(
          routingProfile: routingProfile,
        );

        emit(
          state.copyWith(
            data: initialData,
            initialData: initialData,
            routingName: routingProfile.name,
            loadingStatus: RoutingDetailsLoadingStatus.idle,
          ),
        );
        return;
      } catch (e) {
        _onException(emit, e);
        rethrow;
      } finally {
        emit(state.copyWith(loadingStatus: RoutingDetailsLoadingStatus.idle));
      }
    }
    final profiles = await _routingRepository.getAllProfiles();

    emit(
      state.copyWith(
        routingName: _routingDetailsService.getNewProfileName(profiles.map((p) => p.name).toSet()),
        loadingStatus: RoutingDetailsLoadingStatus.idle,
      ),
    );
  }

  Future<void> _submit(
    _Submit event,
    Emitter<RoutingDetailsState> emit,
  ) async {
    try {
      var routingId = state.routingId;
      if (routingId == null) {
        final newRoute = await _routingRepository.addNewProfile(
          (
            name: state.routingName,
            defaultMode: state.data.defaultMode,
            bypassRules: state.data.bypassRules,
            vpnRules: state.data.vpnRules,
          ),
        );
        routingId = newRoute.id;
        await _updateProfile(state.data, newRoute.id);
      }

      emit(state.copyWith(action: const RoutingDetailsAction.saved()));
      emit(state.copyWith(action: const RoutingDetailsAction.none()));
      emit(state.copyWith(initialData: state.data));
    } catch (e) {
      _onException(emit, e);
      rethrow;
    } finally {
      emit(state.copyWith(loadingStatus: RoutingDetailsLoadingStatus.idle));
    }
  }

  Future<void> _dataChanged(
    _DataChanged event,
    Emitter<RoutingDetailsState> emit,
  ) async {
    emit(
      state.copyWith(
        data: state.data.copyWith(
          defaultMode: event.defaultMode ?? state.data.defaultMode,
          bypassRules: event.bypassRules ?? state.data.bypassRules,
          vpnRules: event.vpnRules ?? state.data.vpnRules,
        ),
        hasInvalidRules: event.hasInvalidRules ?? state.hasInvalidRules,
      ),
    );
  }

  Future<void> _delete(
    _Delete event,
    Emitter<RoutingDetailsState> emit,
  ) async {
    try {
      await _routingRepository.deleteProfile(id: state.routingId!);
      emit(state.copyWith(action: RoutingDetailsAction.deleted(state.routingName)));
      emit(state.copyWith(action: const RoutingDetailsAction.none()));
    } catch (e) {
      _onException(emit, e);
      rethrow;
    } finally {
      emit(state.copyWith(loadingStatus: RoutingDetailsLoadingStatus.idle));
    }
  }

  Future<void> _clear(
    _Clear event,
    Emitter<RoutingDetailsState> emit,
  ) async {
    final clearedData = state.data.copyWith(
      bypassRules: [],
      vpnRules: [],
    );
    if (state.routingId != null) {
      await _updateProfile(
        clearedData,
        state.routingId!,
      );
    }

    emit(
      state.copyWith(
        data: clearedData,
        initialData: clearedData,
      ),
    );

    emit(state.copyWith(action: const RoutingDetailsAction.cleared()));
    emit(state.copyWith(action: const RoutingDetailsAction.none()));
  }

  Future<void> _changeDefaultMode(
    _ChangeDefaultMode event,
    Emitter<RoutingDetailsState> emit,
  ) async {
    final updatedData = state.data.copyWith(
      defaultMode: event.defaultMode,
    );

    await _updateProfile(
      updatedData,
      state.routingId!,
    );

    emit(
      state.copyWith(
        initialData: updatedData,
        data: updatedData,
      ),
    );
    emit(state.copyWith(action: const RoutingDetailsAction.defaultModeChanged()));
    emit(state.copyWith(action: const RoutingDetailsAction.none()));
  }

  Future<void> _onException(
    Emitter<RoutingDetailsState> emit,
    Object exception,
  ) async {
    final PresentationError error = ErrorUtils.toPresentationError(exception: exception);

    emit(state.copyWith(action: RoutingDetailsAction.presentationError(error)));
    emit(state.copyWith(action: const RoutingDetailsAction.none()));
  }

  Future<void> _updateProfile(RoutingDetailsData data, int routingId) async => Future.wait([
    _routingRepository.setDefaultRoutingMode(id: routingId, mode: data.defaultMode),

    _routingRepository.setRules(
      id: routingId,
      mode: RoutingMode.bypass,
      rules: data.bypassRules.join(Platform.lineTerminator),
    ),

    _routingRepository.setRules(
      id: routingId,
      mode: RoutingMode.vpn,
      rules: data.vpnRules.join(Platform.lineTerminator),
    ),
  ]);
}
