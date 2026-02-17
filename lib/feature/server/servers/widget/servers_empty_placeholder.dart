import 'package:flutter/material.dart';
import 'package:trusttunnel/common/assets/assets_images.dart';
import 'package:trusttunnel/common/extensions/context_extensions.dart';
import 'package:trusttunnel/common/localization/localization.dart';
import 'package:trusttunnel/feature/server/import/widgets/server_config_import_flow.dart';
import 'package:trusttunnel/feature/server/server_details/widgets/server_details_popup.dart';
import 'package:trusttunnel/feature/server/servers/widget/scope/servers_scope.dart';
import 'package:trusttunnel/widgets/default_page.dart';

class ServersEmptyPlaceholder extends StatelessWidget {
  const ServersEmptyPlaceholder({super.key});

  @override
  Widget build(BuildContext context) => DefaultPage(
    title: context.ln.serversEmptyTitle,
    description: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.ln.serversEmptyDescription,
          textAlign: TextAlign.left,
        ),
        const SizedBox(height: 10),
        const Text('1. Server address (IP + domain)'),
        const Text('2. Username and password'),
        const Text('3. Tap Connect'),
      ],
    ),
    imagePath: AssetImages.server,
    imageSize: const Size.square(248),
    button: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton(
            onPressed: () => _pushServerDetailsScreen(context),
            child: Text(context.ln.create),
          ),
          TextButton.icon(
            onPressed: () => ServerConfigImportFlow.showImportOptions(context),
            icon: const Icon(Icons.file_open_outlined),
            label: Text(context.ln.importConfig),
          ),
        ],
      ),
    ),
    alignment: Alignment.center,
  );

  void _pushServerDetailsScreen(BuildContext context) async {
    final controller = ServersScope.controllerOf(context, listen: false);

    await context.push(
      const ServerDetailsPopUp(),
    );

    controller.fetchServers();
  }
}
