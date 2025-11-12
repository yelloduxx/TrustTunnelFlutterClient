import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vpn/common/extensions/context_extensions.dart';
import 'package:vpn/data/model/server.dart';
import 'package:vpn/data/model/vpn_state.dart';
import 'package:vpn/feature/server/server_details/view/server_details_popup.dart';
import 'package:vpn/feature/server/servers/bloc/servers_bloc.dart';
import 'package:vpn/feature/server/servers/view/widget/servers_card_connection_button.dart';
import 'package:vpn/feature/vpn/widgets/vpn_scope.dart';
import 'package:vpn/view/common/custom_list_tile_separated.dart';

class ServersCard extends StatefulWidget {
  final Server server;

  const ServersCard({
    super.key,
    required this.server,
  });

  @override
  State<ServersCard> createState() => _ServersCardState();
}

class _ServersCardState extends State<ServersCard> {
  VpnState _vpnStatus = VpnState.disconnected;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _vpnStatus = VpnScope.of(context).state;
  }

  @override
  Widget build(BuildContext context) => CustomListTileSeparated(
    title: widget.server.name,
    titleStyle: context.textTheme.titleSmall,
    subtitle: widget.server.ipAddress,
    subtitleStyle: context.textTheme.bodyMedium?.copyWith(
      color: context.colors.gray1,
    ),
    onTileTap: () => _pushServerDetailsScreen(
      context,
      server: widget.server,
    ),
    trailing: BlocBuilder<ServersBloc, ServersState>(
      key: ValueKey(_vpnStatus),
      buildWhen: (previous, current) => previous.selectedServerId != current.selectedServerId,
      builder: (context, state) {
        final vpnManagerState = state.selectedServerId == widget.server.id ? _vpnStatus : VpnState.disconnected;
        return ServersCardConnectionButton(
          vpnManagerState: vpnManagerState,
          onPressed: () {
            if (vpnManagerState != VpnState.disconnected && widget.server.id == state.selectedServerId) {
              _disconnectFromVpn(context);
              _changeServer(context, null);
            } else {
              _connectToVpn(context, widget.server);
              _changeServer(context, widget.server.id);
            }
          },
          serverId: widget.server.id,
        );
      },
    ),
  );

  void _changeServer(BuildContext context, int? serverId) => context.read<ServersBloc>().add(
    ServersEvent.selectServer(
      serverId: serverId,
    ),
  );
  Future<void> _disconnectFromVpn(BuildContext context) async {
    final controller = VpnScope.of(context);
    return controller.stop();
  }

  Future<void> _connectToVpn(
    BuildContext context,
    Server server,
  ) async {
    final controller = VpnScope.of(context);
    await controller.start(
      server: server,
      routingProfile: server.routingProfile,
    );
  }

  void _pushServerDetailsScreen(
    BuildContext context, {
    required Server server,
  }) {
    final serversBloc = context.read<ServersBloc>();
    context
        .push(
          ServerDetailsPopUp(
            serverId: server.id,
          ),
        )
        .then(
          (_) {
            serversBloc.add(
              const ServersEvent.fetch(),
            );
          },
        );
  }
}
