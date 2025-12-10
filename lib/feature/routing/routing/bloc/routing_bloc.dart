import 'dart:async';
import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vpn/common/error/model/presentation_base_error.dart';
import 'package:vpn/common/error/model/presentation_error.dart';
import 'package:vpn/common/error/model/presentation_field.dart';
import 'package:vpn/data/model/routing_profile.dart';
import 'package:vpn/data/repository/routing_repository.dart';
import 'package:vpn/feature/routing/routing/domain/routing_service.dart';

part 'routing_bloc.freezed.dart';
part 'routing_event.dart';
part 'routing_state.dart';

class RoutingBloc extends Bloc<RoutingEvent, RoutingState> {
  final RoutingRepository _routingRepository;

  RoutingBloc({required RoutingRepository routingRepository})
    : _routingRepository = routingRepository,
      super(const RoutingState()) {
    on<RoutingEvent>(
      (event, emit) {
        print(event);

        return switch (event) {
          _Fetch() => _fetch(event, emit),
          _EditName() => _editName(event, emit),
          _DeleteProfile() => _deleteProfile(event, emit),
          _DataChanged() => _dataChanged(event, emit),
        };
      },
    );
  }

  Future<void> _fetch(_Fetch event, Emitter<RoutingState> emit) async {
    final result = await _routingRepository.getAllProfiles();
    emit(state.copyWith(routingList: result));
  }

  Future<void> _dataChanged(_DataChanged event, Emitter<RoutingState> emit) async {
    emit(
      state.copyWith(
        fieldErrors: event.fieldError ?? state.fieldErrors,
      ),
    );
  }

  Future<void> _editName(_EditName event, Emitter<RoutingState> emit) async {
    final routingProfile = state.routingList.firstWhereOrNull((element) => element.id == event.id);
    if (routingProfile == null) {
      throw PresentationNotFoundError();
    }
    final otherProfiles = state.routingList.where((element) => element.id != event.id).toSet();

    final fieldErrors = RoutingService.validateRoutingProfileName(otherProfiles, event.newName);

    if (fieldErrors.isNotEmpty) {
      emit(
        state.copyWith(
          fieldErrors: fieldErrors,
        ),
      );

      return;
    }

    await _routingRepository.setProfileName(
      id: event.id,
      name: event.newName,
    );

    final updatedRoutingList = state.routingList.map(
      (element) => element.id == event.id ? element.copyWith(name: event.newName) : element,
    );

    emit(
      state.copyWith(
        routingList: updatedRoutingList.toList(),
      ),
    );
    emit(state.copyWith(action: const RoutingAction.saved()));
    emit(state.copyWith(action: const RoutingAction.none()));
  }

  Future<void> _deleteProfile(_DeleteProfile event, Emitter<RoutingState> emit) async {
    await _routingRepository.deleteProfile(id: event.id);
    final updatedRoutingList = state.routingList.where((element) => element.id != event.id).toList();
    emit(state.copyWith(routingList: updatedRoutingList));
    emit(state.copyWith(action: const RoutingAction.deleted()));
    emit(state.copyWith(action: const RoutingAction.none()));
  }
}
