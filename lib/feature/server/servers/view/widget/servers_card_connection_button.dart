import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vpn/common/assets/asset_icons.dart';
import 'package:vpn/common/extensions/context_extensions.dart';
import 'package:vpn/common/extensions/theme_extensions.dart';
import 'package:vpn/data/model/server.dart';
import 'package:vpn/data/model/vpn_manager_state.dart';
import 'package:vpn/feature/server/servers/bloc/servers_bloc.dart';
import 'package:vpn/view/buttons/icon_button_svg_external_state.dart';
import 'package:vpn/view/rotating_wrapper.dart';

class ServersCardConnectionButton extends StatelessWidget {
  final VpnManagerState vpnManagerState;
  final Server server;

  const ServersCardConnectionButton({
    super.key,
    required this.server,
    required this.vpnManagerState,
  });

  @override
  Widget build(BuildContext context) => Theme(
        data: context.theme.copyWith(
          iconButtonTheme: vpnManagerState == VpnManagerState.connecting
              ? context.theme
                  .extension<CustomFilledIconButtonTheme>()!
                  .iconButtonInProgress
              : context.theme
                  .extension<CustomFilledIconButtonTheme>()!
                  .iconButton,
        ),
        child: vpnManagerState == VpnManagerState.connecting
            ? RotatingWidget(
                duration: const Duration(seconds: 1),
                child: IconButtonSvgExternalState.square(
                  icon: AssetIcons.update,
                  onPressed: null,
                  size: 24,
                  color: context.colors.staticWhite,
                  isSelected: true,
                ),
              )
            : IconButtonSvgExternalState.square(
                icon: AssetIcons.powerSettingsNew,
                onPressed: () => _changeServerConnectionStatus(context),
                size: 24,
                color: context.colors.staticWhite,
                isSelected: vpnManagerState == VpnManagerState.connected,
              ),
      );

  void _changeServerConnectionStatus(BuildContext context) {
    final serversBloc = context.read<ServersBloc>();
    vpnManagerState == VpnManagerState.connected
        ? serversBloc.add(ServersEvent.disconnectServer(server: server))
        : serversBloc.add(ServersEvent.connectServer(server: server));
  }
}
