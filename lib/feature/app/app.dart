import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:trusttunnel/common/extensions/context_extensions.dart';
import 'package:trusttunnel/common/localization/localization.dart';
import 'package:trusttunnel/feature/navigation/navigation_screen.dart';
import 'package:trusttunnel/feature/routing/happ/domain/service/happ_routing_import_service.dart';
import 'package:trusttunnel/feature/routing/happ/domain/service/routing_sync_coordinator.dart';
import 'package:trusttunnel/feature/routing/happ/widgets/routing_sync_coordinator_scope.dart';
import 'package:trusttunnel/feature/routing/routing/widgets/scope/routing_scope.dart';
import 'package:trusttunnel/feature/server/import/domain/service/server_config_import_service.dart';
import 'package:trusttunnel/feature/server/servers/widget/scope/servers_scope.dart';
import 'package:trusttunnel/feature/server/subscription/domain/service/server_subscription_coordinator.dart';
import 'package:trusttunnel/feature/server/subscription/domain/service/server_subscription_service.dart';
import 'package:trusttunnel/feature/settings/excluded_routes/widgets/scope/excluded_routes_scope.dart';
import 'package:trusttunnel/data/model/vpn_state.dart';
import 'package:trusttunnel/feature/vpn/widgets/vpn_scope.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  final _handledLinks = <String, DateTime>{};
  static const _deepLinkDedupWindow = Duration(seconds: 5);

  late final AppLinks _appLinks;
  late final HappRoutingImportService _happRoutingImportService;
  late final RoutingSyncCoordinator _routingSyncCoordinator;
  late final ServerSubscriptionCoordinator _serverSubscriptionCoordinator;
  StreamSubscription<Uri>? _uriSubscription;

  @override
  void initState() {
    super.initState();
    _appLinks = AppLinks();
    _happRoutingImportService = HappRoutingImportService(
      routingRepository: context.repositoryFactory.routingRepository,
    );
    _routingSyncCoordinator = RoutingSyncCoordinator(
      settingsRepository: context.repositoryFactory.settingsRepository,
      importService: _happRoutingImportService,
      onProfileUpdated: _onManagedProfileUpdated,
    );
    _serverSubscriptionCoordinator = ServerSubscriptionCoordinator(
      serverRepository: context.repositoryFactory.serverRepository,
      subscriptionService: ServerSubscriptionService(
        serverRepository: context.repositoryFactory.serverRepository,
      ),
      onServerUpdated: _onServerSubscriptionUpdated,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initDeepLinkImport();
      _routingSyncCoordinator.start();
      _serverSubscriptionCoordinator.start();
    });
  }

  @override
  void dispose() {
    _uriSubscription?.cancel();
    _routingSyncCoordinator.dispose().ignore();
    _serverSubscriptionCoordinator.dispose().ignore();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    scaffoldMessengerKey: _scaffoldMessengerKey,
    theme: context.dependencyFactory.lightThemeData,
    home: RoutingSyncCoordinatorScope(
      coordinator: _routingSyncCoordinator,
      child: const NavigationScreen(),
    ),
    onGenerateTitle: (context) => context.ln.appTitle,
    locale: Localization.defaultLocale,
    localizationsDelegates: Localization.localizationDelegates,
    supportedLocales: Localization.supportedLocales,
  );

  Future<void> _initDeepLinkImport() async {
    if (!mounted) {
      return;
    }

    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        await _handleIncomingUri(initialUri);
      }
    } catch (_) {
      // Ignore startup link errors and keep app functional.
    }

    _uriSubscription = _appLinks.uriLinkStream.listen(
      _handleIncomingUri,
      onError: (_) {},
    );
  }

  Future<void> _handleIncomingUri(Uri uri) async {
    if (!mounted) {
      return;
    }

    final key = uri.toString();
    final now = DateTime.now();
    _handledLinks.removeWhere((_, time) => now.difference(time) > const Duration(minutes: 1));
    final previous = _handledLinks[key];
    if (previous != null && now.difference(previous) < _deepLinkDedupWindow) {
      return;
    }
    _handledLinks[key] = now;

    final repositoryFactory = context.repositoryFactory;
    final scheme = uri.scheme.toLowerCase();
    if (scheme == 'tt') {
      final importer = ServerConfigImportService(
        serverRepository: repositoryFactory.serverRepository,
        routingRepository: repositoryFactory.routingRepository,
      );

      try {
        final importedName = await importer.importFromUri(uri: uri);
        if (!mounted) return;

        ServersScope.controllerOf(context, listen: false).fetchServers();
        _showSnack(
          textBuilder: (context) => context.ln.serverImportedSnackbar(importedName),
          fallback: 'Server "$importedName" imported',
        );
      } on FormatException {
        _showSnack(
          textBuilder: (context) => context.ln.importConfigInvalidFormat,
          fallback: 'Config format is invalid',
        );
      } catch (_) {
        _showSnack(
          textBuilder: (context) => context.ln.importConfigFailed,
          fallback: 'Failed to import config',
        );
      }
      return;
    }

    if (scheme == 'happ') {
      try {
        final imported = await _happRoutingImportService.importFromUri(uri: uri);
        if (!mounted) return;

        RoutingScope.controllerOf(context, listen: false).fetchProfiles();
        final warning = imported.unsupportedBlockRules > 0
            ? ' Block rules skipped: ${imported.unsupportedBlockRules}.'
            : '';
        _showSnack(
          textBuilder: (_) => 'HAPP routing profile "${imported.profileName}" imported.$warning',
          fallback: 'HAPP routing profile "${imported.profileName}" imported.$warning',
        );
      } on FormatException catch (e) {
        _showSnack(
          textBuilder: (_) => e.message,
          fallback: e.message,
        );
      } catch (e) {
        _showSnack(
          textBuilder: (_) => 'Failed to import HAPP routing: $e',
          fallback: 'Failed to import HAPP routing: $e',
        );
      }
      return;
    }
  }

  void _showSnack({
    required String Function(BuildContext context) textBuilder,
    required String fallback,
  }) {
    final messenger = _scaffoldMessengerKey.currentState;
    if (messenger == null) {
      return;
    }

    final innerContext = _scaffoldMessengerKey.currentContext;
    final text = innerContext != null ? textBuilder(innerContext) : fallback;

    messenger
      ..removeCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
        ),
      );
  }

  Future<void> _onManagedProfileUpdated(int profileId) async {
    if (!mounted) {
      return;
    }

    RoutingScope.controllerOf(context, listen: false).fetchProfiles();
    ServersScope.controllerOf(context, listen: false).fetchServers();

    final vpnController = VpnScope.vpnControllerOf(context, listen: false);
    if (vpnController.state == VpnState.disconnected) {
      return;
    }

    final serversScope = ServersScope.controllerOf(context, listen: false);
    final selected = serversScope.selectedServer;
    if (selected == null || selected.routingProfile.id != profileId) {
      return;
    }

    final routingScope = RoutingScope.controllerOf(context, listen: false);
    final profile = routingScope.routingList.firstWhereOrNull((item) => item.id == profileId);
    if (profile == null) {
      return;
    }

    await vpnController.start(
      server: selected.copyWith(routingProfile: profile),
      routingProfile: profile,
      excludedRoutes: ExcludedRoutesScope.controllerOf(context, listen: false).excludedRoutes,
    );
  }

  Future<void> _onServerSubscriptionUpdated(int serverId) async {
    if (!mounted) {
      return;
    }

    ServersScope.controllerOf(context, listen: false).fetchServers();

    final vpnController = VpnScope.vpnControllerOf(context, listen: false);
    if (vpnController.state == VpnState.disconnected) {
      return;
    }

    final serversScope = ServersScope.controllerOf(context, listen: false);
    final selected = serversScope.selectedServer;
    if (selected == null || selected.id != serverId) {
      return;
    }

    // Reload the updated server from DB to get fresh values.
    final updatedServer = await context.repositoryFactory.serverRepository.getServerById(id: serverId);
    if (updatedServer == null || !mounted) {
      return;
    }

    await vpnController.start(
      server: updatedServer,
      routingProfile: updatedServer.routingProfile,
      excludedRoutes: ExcludedRoutesScope.controllerOf(context, listen: false).excludedRoutes,
    );
  }
}
