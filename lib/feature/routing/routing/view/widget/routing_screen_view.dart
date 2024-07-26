import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vpn/common/assets/asset_icons.dart';
import 'package:vpn/common/extensions/context_extensions.dart';
import 'package:vpn/common/localization/localization.dart';
import 'package:vpn/feature/routing/routing/bloc/routing_bloc.dart';
import 'package:vpn/feature/routing/routing/view/widget/routing_card.dart';
import 'package:vpn/feature/routing/routing_details/view/routing_details_screen.dart';
import 'package:vpn/view/buttons/floating_action_button_svg.dart';
import 'package:vpn/view/custom_app_bar.dart';
import 'package:vpn/view/scaffold_wrapper.dart';

class RoutingScreenView extends StatelessWidget {
  const RoutingScreenView({super.key});

  @override
  Widget build(BuildContext context) => ScaffoldWrapper(
        child: Scaffold(
          appBar: CustomAppBar(
            title: context.ln.routing,
          ),
          body: BlocBuilder<RoutingBloc, RoutingState>(
            builder: (context, state) => ListView.builder(
              itemBuilder: (context, index) => Column(
                children: [
                  RoutingCard(
                    routingProfile: state.routingList[index],
                  ),
                  index == state.routingList.length - 1 ? const SizedBox(height: 80) : const Divider(),
                ],
              ),
              itemCount: state.routingList.length,
            ),
          ),
          floatingActionButton: FloatingActionButtonSvg.extended(
            icon: AssetIcons.add,
            onPressed: () => _pushRoutingProfileDetailsScreen(context),
            label: context.ln.addProfile,
          ),
        ),
      );

  _pushRoutingProfileDetailsScreen(BuildContext context) => context.push(
        const RoutingDetailsScreen(),
      );
}
