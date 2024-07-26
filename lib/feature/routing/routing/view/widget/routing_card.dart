import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vpn/common/assets/asset_icons.dart';
import 'package:vpn/common/extensions/common_extensions.dart';
import 'package:vpn/common/extensions/context_extensions.dart';
import 'package:vpn/common/localization/localization.dart';
import 'package:vpn/feature/routing/routing/bloc/routing_bloc.dart';
import 'package:vpn/feature/routing/routing/common/routing_profile_utils.dart';
import 'package:vpn/feature/routing/routing/view/widget/routing_delete_profile_dialog.dart';
import 'package:vpn/feature/routing/routing/view/widget/routing_edit_name_dialog.dart';
import 'package:vpn/feature/routing/routing_details/view/routing_details_screen.dart';
import 'package:vpn/view/common/custom_list_tile_separated.dart';
import 'package:vpn/view/custom_svg_picture.dart';
import 'package:vpn_plugin/platform_api.g.dart';

class RoutingCard extends StatelessWidget {
  final RoutingProfile routingProfile;

  const RoutingCard({
    super.key,
    required this.routingProfile,
  });

  @override
  Widget build(BuildContext context) => CustomListTileSeparated(
        title: routingProfile.name,
        onTileTap: () => _pushDetailsScreen(context),
        trailing: PopupMenuButton(
          icon: const CustomSvgPicture(
            icon: AssetIcons.moreVert,
            size: 24,
          ),
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              onTap: () => _onEditName(context),
              child: Row(
                children: [
                  const CustomSvgPicture(
                    icon: AssetIcons.modeEdit,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(context.ln.editProfile).bodyLarge(context),
                ],
              ),
            ),
            if (!RoutingProfileUtils.isDefaultRoutingProfile(profile: routingProfile))
              PopupMenuItem<String>(
                onTap: () => _onDeleteProfile(context),
                child: Row(
                  children: [
                    CustomSvgPicture(
                      icon: AssetIcons.delete,
                      size: 24,
                      color: context.colors.red1,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      context.ln.deleteProfile,
                      style: context.textTheme.bodyLarge?.copyWith(
                        color: context.colors.red1,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );

  void _onEditName(BuildContext context) {
    final bloc = context.read<RoutingBloc>();
    showDialog(
      context: context,
      builder: (_) => RoutingEditNameDialog(
        onSavePressed: (String value) => _editNameSubmit(bloc, value),
        currentRoutingName: routingProfile.name,
      ),
    );
  }

  void _onDeleteProfile(BuildContext context) {
    final bloc = context.read<RoutingBloc>();
    showDialog(
      context: context,
      builder: (_) => RoutingDeleteProfileDialog(
        onDeletePressed: () => _deleteProfileSubmit(bloc),
        profileName: routingProfile.name,
      ),
    );
  }

  void _editNameSubmit(RoutingBloc bloc, String value) => bloc.add(
        RoutingEvent.editName(
          id: routingProfile.id,
          newName: value,
        ),
      );

  void _deleteProfileSubmit(RoutingBloc bloc) => bloc.add(
        RoutingEvent.deleteProfile(
          id: routingProfile.id,
        ),
      );

  void _pushDetailsScreen(BuildContext context) => context.push(
        RoutingDetailsScreen(
          routingId: routingProfile.id,
        ),
      );
}
