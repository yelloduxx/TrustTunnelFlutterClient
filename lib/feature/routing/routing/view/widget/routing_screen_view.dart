import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vpn/common/localization/localization.dart';
import 'package:vpn/feature/routing/routing/bloc/routing_bloc.dart';
import 'package:vpn/feature/routing/routing/view/widget/routing_card.dart';
import 'package:vpn/view/custom_app_bar.dart';

class RoutingScreenView extends StatelessWidget {
  const RoutingScreenView({
    super.key,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: CustomAppBar(
          title: context.ln.routing,
        ),
        body: BlocBuilder<RoutingBloc, RoutingState>(
          builder: (context, state) => ListView.separated(
            itemCount: state.routingList.length,
            itemBuilder: (context, index) {
              final item = state.routingList[index];

              return RoutingCard(
                routing: item,
              );
            },
            separatorBuilder: (context, index) => const Divider(),
          ),
        ),
      );
}
