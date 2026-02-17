import 'package:flutter/material.dart';
import 'package:trusttunnel/common/assets/asset_icons.dart';
import 'package:trusttunnel/common/extensions/context_extensions.dart';
import 'package:trusttunnel/common/localization/localization.dart';
import 'package:trusttunnel/data/model/routing_profile.dart';
import 'package:trusttunnel/feature/routing/happ/domain/service/happ_routing_import_service.dart';
import 'package:trusttunnel/feature/routing/routing/widgets/routing_card.dart';
import 'package:trusttunnel/feature/routing/routing/widgets/scope/routing_scope.dart';
import 'package:trusttunnel/feature/routing/routing/widgets/scope/routing_scope_aspect.dart';
import 'package:trusttunnel/feature/routing/routing_details/widgets/routing_details_screen.dart';
import 'package:trusttunnel/widgets/buttons/custom_floating_action_button.dart';
import 'package:trusttunnel/widgets/custom_app_bar.dart';
import 'package:trusttunnel/widgets/scaffold_wrapper.dart';

class RoutingScreenView extends StatefulWidget {
  const RoutingScreenView({super.key});

  @override
  State<RoutingScreenView> createState() => _RoutingScreenViewState();
}

class _RoutingScreenViewState extends State<RoutingScreenView> {
  late List<RoutingProfile> _routingProfiles;

  @override
  void initState() {
    super.initState();
    _routingProfiles = RoutingScope.controllerOf(context, listen: false).routingList;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _routingProfiles = RoutingScope.controllerOf(
      context,
      aspect: RoutingScopeAspect.profiles,
    ).routingList;
  }

  @override
  Widget build(BuildContext context) => ScaffoldWrapper(
    child: ScaffoldMessenger(
      child: Scaffold(
        appBar: CustomAppBar(
          title: context.ln.routing,
          actions: [
            IconButton(
              onPressed: () => _importHappRouting(context),
              icon: const Icon(Icons.link),
              tooltip: 'Import HAPP routing',
            ),
          ],
        ),
        body: ListView.builder(
          itemBuilder: (context, index) => Column(
            children: [
              RoutingCard(
                routingProfile: _routingProfiles[index],
              ),
              index == _routingProfiles.length - 1 ? const SizedBox(height: 80) : const Divider(),
            ],
          ),
          itemCount: _routingProfiles.length,
        ),
        floatingActionButton: Builder(
          builder: (context) => CustomFloatingActionButton.extended(
            icon: AssetIcons.add,
            onPressed: () => _pushRoutingProfileDetailsScreen(context),
            label: context.ln.addProfile,
          ),
        ),
      ),
    ),
  );

  void _pushRoutingProfileDetailsScreen(BuildContext context) async {
    await context.push(
      const RoutingDetailsScreen(),
    );

    if (context.mounted) {
      RoutingScope.controllerOf(context, listen: false).fetchProfiles();
    }
  }

  Future<void> _importHappRouting(BuildContext context) async {
    final controller = TextEditingController();
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import HAPP routing'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Paste happ:// or https:// routing link',
          ),
          minLines: 1,
          maxLines: 3,
          textInputAction: TextInputAction.done,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.ln.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Import'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (value == null || value.trim().isEmpty || !context.mounted) {
      return;
    }

    final uri = Uri.tryParse(value.trim());
    if (uri == null) {
      context.showInfoSnackBar(message: 'Invalid routing link');
      return;
    }

    final service = HappRoutingImportService(
      routingRepository: context.repositoryFactory.routingRepository,
    );

    try {
      final result = await service.importFromUri(uri: uri);
      if (!context.mounted) return;

      RoutingScope.controllerOf(context, listen: false).fetchProfiles();
      final reused = result.reusedExistingProfile ? 'updated' : 'created';
      final warning = result.unsupportedBlockRules > 0
          ? ' (block rules skipped: ${result.unsupportedBlockRules})'
          : '';
      context.showInfoSnackBar(
        message: 'HAPP profile "${result.profileName}" $reused$warning',
      );
    } on FormatException catch (e) {
      if (!context.mounted) return;
      context.showInfoSnackBar(message: e.message);
    } catch (e) {
      if (!context.mounted) return;
      context.showInfoSnackBar(message: 'Failed to import HAPP routing: $e');
    }
  }
}
