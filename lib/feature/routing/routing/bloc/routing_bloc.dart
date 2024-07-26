import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:vpn/data/repository/routing_repository.dart';
import 'package:vpn_plugin/platform_api.g.dart';

part 'routing_bloc.freezed.dart';
part 'routing_event.dart';
part 'routing_state.dart';

class RoutingBloc extends Bloc<RoutingEvent, RoutingState> {
  final RoutingRepository _routingRepository;

  RoutingBloc({required RoutingRepository routingRepository})
      : _routingRepository = routingRepository,
        super(const RoutingState()) {
    on<_Init>(_init);
    on<_DataChanged>(_dataChanged);
    on<_EditName>(_editName);
    on<_DeleteProfile>(_deleteProfile);

    _initSubs();
  }

  late final StreamSubscription<List<dynamic>> _routingSub;

  void _initSubs() => _routingSub = _routingRepository.routingProfileStream.whereNotNull().listen((value) {
        add(RoutingEvent.dataChanged(profiles: List.of(value)));
      });

  Future<void> _init(_Init event, Emitter<RoutingState> emit) => _routingRepository.loadRoutingProfiles();

  @override
  Future<void> close() {
    _routingSub.cancel();
    return super.close();
  }

  void _dataChanged(_DataChanged event, Emitter<RoutingState> emit) => emit(
        state.copyWith(
          routingList: event.profiles,
        ),
      );

  Future<void> _editName(_EditName event, Emitter<RoutingState> emit) => _routingRepository.updateRoutingProfileName(
        id: event.id,
        name: event.newName,
      );

  Future<void> _deleteProfile(_DeleteProfile event, Emitter<RoutingState> emit) =>
      _routingRepository.deleteRoutingProfileById(
        id: event.id,
      );
}
