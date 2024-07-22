import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vpn/common/extensions/context_extensions.dart';
import 'package:vpn/feature/routing/routing_details/bloc/routing_details_bloc.dart';
import 'package:vpn/feature/routing/routing_details/view/widget/routing_details_screen_view.dart';

class RoutingDetailsScreen extends StatelessWidget {
  final int? routingId;

  const RoutingDetailsScreen({super.key, this.routingId});

  @override
  Widget build(BuildContext context) => BlocProvider<RoutingDetailsBloc>(
        create: (context) => context.blocFactory.routingDetailsBloc(
          routingId: routingId,
        )..add(const RoutingDetailsEvent.init()),
        child: const RoutingDetailsScreenView(),
      );
}
