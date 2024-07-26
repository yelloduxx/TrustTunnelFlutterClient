import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vpn/common/error/error_utils.dart';
import 'package:vpn/common/error/model/presentation_error.dart';
import 'package:vpn/data/repository/routing_repository.dart';
import 'package:vpn/feature/routing/routing_details/data/routing_details_data.dart';
import 'package:vpn/feature/routing/routing_details/domain/routing_details_service.dart';
import 'package:vpn_plugin/platform_api.g.dart';

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
  })  : _routingRepository = routingRepository,
        _routingDetailsService = routingDetailsService,
        super(RoutingDetailsState(routingId: routingId)) {
    on<_Init>(_init);
    on<_DataChanged>(_dataChanged);
    on<_Submit>(_submit);
  }

  Future<void> _init(
    _Init event,
    Emitter<RoutingDetailsState> emit,
  ) async {
    if (state.routingId != null) {
      final routingProfile = await _routingRepository.getRoutingProfileById(
        id: state.routingId!,
      );
      final initialData = _routingDetailsService.toRoutingDetailsData(
        routingProfile: routingProfile,
      );

      emit(
        state.copyWith(
          data: initialData,
          routingName: routingProfile.name,
          initialData: initialData,
          loadingStatus: RoutingDetailsLoadingStatus.idle,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        routingName: _routingDetailsService.getNewProfileName(),
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

  Future<void> _submit(
    _Submit event,
    Emitter<RoutingDetailsState> emit,
  ) async {
    try {
      if (state.isEditing) {
        await _routingRepository.updateRoutingProfile(
          request: _routingDetailsService.toUpdateRoutingProfileRequest(
            id: state.routingId!,
            data: state.data,
          ),
        );
      } else {
        await _routingRepository.addRoutingProfile(
          request: _routingDetailsService.toAddRoutingProfileRequest(
            profileName: state.routingName,
            data: state.data,
          ),
        );
      }

      emit(state.copyWith(action: const RoutingDetailsAction.saved()));
      emit(state.copyWith(action: const RoutingDetailsAction.none()));
    } catch (e) {
      final PresentationError error = ErrorUtils.toPresentationError(exception: e);

      emit(state.copyWith(action: RoutingDetailsAction.presentationError(error)));
      emit(state.copyWith(action: const RoutingDetailsAction.none()));
    }
  }
}
