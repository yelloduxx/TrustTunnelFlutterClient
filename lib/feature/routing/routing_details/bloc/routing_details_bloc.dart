import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vpn/data/model/routing_mode.dart';
import 'package:vpn/feature/routing/routing_details/data/routing_details_data.dart';

part 'routing_details_bloc.freezed.dart';
part 'routing_details_event.dart';
part 'routing_details_state.dart';

class RoutingDetailsBloc
    extends Bloc<RoutingDetailsEvent, RoutingDetailsState> {
  RoutingDetailsBloc({int? routingId})
      : super(RoutingDetailsState(routingId: routingId)) {
    on<_Init>(_init);
    on<_DataChanged>(_dataChanged);
    on<_AddRouting>(_addRouting);
  }

  Future<void> _init(
    _Init event,
    Emitter<RoutingDetailsState> emit,
  ) async {
    if (state.routingId == null) {
      emit(
        state.copyWith(
          routingName: _generateNewRoutingProfileName(),
          loadingStatus: RoutingDetailsLoadingStatus.idle,
        ),
      );
      return;
    }
    // async request imitation
    await Future.delayed(
      const Duration(milliseconds: 100),
    );
    // TODO fetch routing details by id
    String routingProfileName = 'Profile name';
    RoutingDetailsData initialData = const RoutingDetailsData(bypassRules: [
      '1.1.1.1',
      '2.2.2.2',
    ], vpnRules: [
      '3.3.3.3',
    ], defaultMode: RoutingMode.bypass);

    emit(
      state.copyWith(
        routingName: routingProfileName,
        data: initialData,
        initialData: initialData,
        loadingStatus: RoutingDetailsLoadingStatus.idle,
      ),
    );
  }

  void _dataChanged(
    _DataChanged event,
    Emitter<RoutingDetailsState> emit,
  ) {
    final mode = event.defaultMode ?? state.data.defaultMode;
    final bypassRules = event.bypassRules ?? state.data.bypassRules;
    final vpnRules = event.vpnRules ?? state.data.vpnRules;

    emit(
      state.copyWith(
        data: state.data.copyWith(
          defaultMode: mode,
          bypassRules: bypassRules,
          vpnRules: vpnRules,
        ),
      ),
    );
  }

  void _addRouting(
    _AddRouting event,
    Emitter<RoutingDetailsState> emit,
  ) {
    // TODO add routing
  }

  // TODO generate new routing profile name
  String _generateNewRoutingProfileName() => 'New profile';
}
