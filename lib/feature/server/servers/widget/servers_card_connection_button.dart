import 'package:flutter/material.dart';
import 'package:trusttunnel/data/model/vpn_state.dart';

class ServersCardConnectionButton extends StatelessWidget {
  final VpnState vpnManagerState;
  final VoidCallback onPressed;
  final int serverId;

  const ServersCardConnectionButton({
    super.key,
    required this.serverId,
    required this.vpnManagerState,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isBusy = vpnManagerState == VpnState.connecting ||
        vpnManagerState == VpnState.recovering ||
        vpnManagerState == VpnState.waitingForRecovery ||
        vpnManagerState == VpnState.waitingForNetwork;

    final isConnected = vpnManagerState == VpnState.connected;

    if (isBusy) {
      return SizedBox(
        width: 124,
        child: FilledButton(
          onPressed: null,
          child: const Text('Connecting...'),
        ),
      );
    }

    if (isConnected) {
      return SizedBox(
        width: 124,
        child: OutlinedButton(
          onPressed: onPressed,
          child: const Text('Disconnect'),
        ),
      );
    }

    return SizedBox(
      width: 124,
      child: FilledButton(
        onPressed: onPressed,
        child: const Text('Connect'),
      ),
    );
  }
}
