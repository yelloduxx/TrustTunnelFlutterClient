import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vpn/common/assets/asset_icons.dart';
import 'package:vpn/common/extensions/common_extensions.dart';
import 'package:vpn/common/extensions/context_extensions.dart';
import 'package:vpn/common/localization/localization.dart';
import 'package:vpn/data/model/routing_mode.dart';
import 'package:vpn/feature/routing/routing_details/bloc/routing_details_bloc.dart';
import 'package:vpn/feature/routing/routing_details/view/widget/routing_details_change_routing_dialog.dart';
import 'package:vpn/feature/routing/routing_details/view/widget/routing_details_delete_rules_dialog.dart';
import 'package:vpn/view/custom_svg_picture.dart';

class RoutingDetailsScreenAppBarAction extends StatelessWidget {
  const RoutingDetailsScreenAppBarAction({
    super.key,
  });

  @override
  Widget build(BuildContext context) => PopupMenuButton(
        icon: const CustomSvgPicture(
          icon: AssetIcons.moreVert,
          size: 24,
        ),
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          PopupMenuItem<String>(
            onTap: () => _onChangeDefaultRoutingMode(context),
            child: Row(
              children: [
                const CustomSvgPicture(
                  icon: AssetIcons.update,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(context.ln.changeDefaultRoutingMode).bodyLarge(context),
              ],
            ),
          ),
          PopupMenuItem<String>(
            onTap: () => _onDeleteRules(context),
            child: Row(
              children: [
                CustomSvgPicture(
                  icon: AssetIcons.delete,
                  size: 24,
                  color: context.colors.red1,
                ),
                const SizedBox(width: 12),
                Text(
                  context.ln.deleteAllRules,
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: context.colors.red1,
                  ),
                ),
              ],
            ),
          ),
        ],
      );

  void _onDeleteRules(BuildContext context) {
    final bloc = context.read<RoutingDetailsBloc>();
    showDialog(
      context: context,
      builder: (_) => RoutingDetailsDeleteRulesDialog(
        onDeletePressed: () => _onDeleteRulesSubmit(bloc: bloc),
        profileName: bloc.state.routingName,
      ),
    );
  }

  void _onChangeDefaultRoutingMode(BuildContext context) {
    final bloc = context.read<RoutingDetailsBloc>();
    showDialog(
      context: context,
      builder: (_) => RoutingDetailsChangeRoutingDialog(
        onSavePressed: (mode) =>
            _onChangeDefaultRoutingModeSubmit(bloc: bloc, mode: mode),
        currentRoutingMode: bloc.state.data.defaultMode,
      ),
    );
  }

  void _onDeleteRulesSubmit({
    required RoutingDetailsBloc bloc,
  }) =>
      bloc.add(
        const RoutingDetailsEvent.dataChanged(
          vpnRules: [],
          bypassRules: [],
        ),
      );

  void _onChangeDefaultRoutingModeSubmit({
    required RoutingDetailsBloc bloc,
    required RoutingMode mode,
  }) =>
      bloc.add(
        RoutingDetailsEvent.dataChanged(
          defaultMode: mode,
        ),
      );
}
