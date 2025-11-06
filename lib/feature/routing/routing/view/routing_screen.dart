import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vpn/common/extensions/context_extensions.dart';
import 'package:vpn/feature/routing/routing/bloc/routing_bloc.dart';
import 'package:vpn/feature/routing/routing/view/widget/routing_screen_view.dart';

class RoutingScreen extends StatelessWidget {
  const RoutingScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider<RoutingBloc>(
    lazy: false,
    create: (context) => context.blocFactory.routingBloc()
      ..add(
        const RoutingEvent.fetch(),
      ),
    child: const RoutingScreenView(),
  );
}
