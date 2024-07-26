import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vpn/common/extensions/context_extensions.dart';
import 'package:vpn/feature/server/server_details/view/server_details_screen.dart';
import 'package:vpn/feature/server/servers/bloc/servers_bloc.dart';
import 'package:vpn/feature/server/servers/view/widget/servers_card_connection_button.dart';
import 'package:vpn/view/common/custom_list_tile_separated.dart';
import 'package:vpn_plugin/platform_api.g.dart';

class ServersCard extends StatelessWidget {
  final Server server;

  const ServersCard({
    super.key,
    required this.server,
  });

  @override
  Widget build(BuildContext context) => CustomListTileSeparated(
        title: server.name,
        titleStyle: context.textTheme.titleSmall,
        subtitle: server.ipAddress,
        subtitleStyle: context.textTheme.bodyMedium?.copyWith(
          color: context.colors.gray1,
        ),
        onTileTap: () => _pushServerDetailsScreen(
          context,
          server: server,
        ),
        trailing: BlocBuilder<ServersBloc, ServersState>(
          buildWhen: (previous, current) =>
              previous.selectedServerId != current.selectedServerId ||
              previous.vpnManagerState != current.vpnManagerState,
          builder: (context, state) {
            final vpnManagerState = state.selectedServerId == server.id
                ? state.vpnManagerState
                : VpnManagerState.disconnected;

            return ServersCardConnectionButton(
              vpnManagerState: vpnManagerState,
              serverId: server.id,
            );
          },
        ),
      );

  void _pushServerDetailsScreen(
    BuildContext context, {
    required Server server,
  }) =>
      context.push(
        ServerDetailsScreen(serverId: server.id),
      );
}
