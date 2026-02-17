import 'package:flutter/material.dart';
import 'package:trusttunnel/common/assets/asset_icons.dart';
import 'package:trusttunnel/common/extensions/context_extensions.dart';
import 'package:trusttunnel/common/localization/localization.dart';
import 'package:trusttunnel/data/model/server.dart';
import 'package:trusttunnel/feature/server/import/widgets/server_config_import_flow.dart';
import 'package:trusttunnel/feature/server/server_details/widgets/server_details_popup.dart';
import 'package:trusttunnel/feature/server/servers/widget/scope/servers_scope.dart';
import 'package:trusttunnel/feature/server/servers/widget/scope/servers_scope_aspect.dart';
import 'package:trusttunnel/feature/server/servers/widget/servers_card.dart';
import 'package:trusttunnel/feature/server/servers/widget/servers_empty_placeholder.dart';
import 'package:trusttunnel/widgets/buttons/custom_floating_action_button.dart';
import 'package:trusttunnel/widgets/custom_app_bar.dart';
import 'package:trusttunnel/widgets/scaffold_wrapper.dart';

class ServersScreenView extends StatefulWidget {
  const ServersScreenView({
    super.key,
  });

  @override
  State<ServersScreenView> createState() => _ServersScreenViewState();
}

class _ServersScreenViewState extends State<ServersScreenView> {
  late List<Server> _servers;

  @override
  void initState() {
    super.initState();
    final initialController = ServersScope.controllerOf(context, listen: false);
    _servers = initialController.servers;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _servers = ServersScope.controllerOf(
      context,
      aspect: ServersScopeAspect.servers,
    ).servers;
  }

  @override
  Widget build(BuildContext context) => ScaffoldWrapper(
    child: ScaffoldMessenger(
      child: Scaffold(
        appBar: CustomAppBar(
          title: context.ln.servers,
        ),
        body: _servers.isEmpty
            ? const ServersEmptyPlaceholder()
            : ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: _servers.length + 1,
                itemBuilder: (_, index) {
                  if (index == 0) {
                    return const Padding(
                      padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Text(
                            'Tip: tap server name to edit settings. '
                            'Use Connect button to start VPN.',
                          ),
                        ),
                      ),
                    );
                  }

                  final serverIndex = index - 1;
                  return Column(
                    children: [
                      ServersCard(
                        server: _servers[serverIndex],
                      ),
                      if (serverIndex != _servers.length - 1) const Divider(),
                    ],
                  );
                },
              ),
        floatingActionButton: Builder(
          builder: (context) => CustomFloatingActionButton.extended(
            icon: AssetIcons.add,
            onPressed: () => ServerConfigImportFlow.showImportOptions(
              context,
              onAddManually: () => _pushServerDetailsScreen(context),
            ),
            label: context.ln.addServer,
          ),
        ),
      ),
    ),
  );

  void _pushServerDetailsScreen(BuildContext context) async {
    final controller = ServersScope.controllerOf(context, listen: false);

    await context.push(
      const ServerDetailsPopUp(),
    );

    controller.fetchServers();
  }
}
