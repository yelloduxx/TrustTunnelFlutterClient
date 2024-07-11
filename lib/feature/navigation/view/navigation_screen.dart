import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vpn/common/assets/asset_icons.dart';
import 'package:vpn/common/extensions/common_extensions.dart';
import 'package:vpn/common/extensions/context_extensions.dart';
import 'package:vpn/feature/navigation/view/widgets/custom_navigation_rail.dart';
import 'package:vpn/feature/routers/routers_screen.dart';
import 'package:vpn/feature/servers/servers_screen/servers_screen.dart';
import 'package:vpn/feature/settings/settings_screen.dart';
import 'package:vpn/feature/test/test_screen.dart';
import 'package:vpn/view/custom_svg_picture.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  late final ValueNotifier<int> _selectedTabNotifier;
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _selectedTabNotifier = ValueNotifier(0);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: context.isMobileBreakpoint
            ? _getContent()
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ValueListenableBuilder(
                    valueListenable: _selectedTabNotifier,
                    builder: (context, index, _) => CustomNavigationRail(
                      selectedIndex: index,
                      onDestinationSelected: _onDestinationSelected,
                      destinations: _getNavigationRailDestinations(context),
                    ),
                  ),
                  Expanded(
                    child: _getContent(),
                  ),
                ],
              ),
        bottomNavigationBar: context.isMobileBreakpoint
            ? ValueListenableBuilder(
                valueListenable: _selectedTabNotifier,
                builder: (context, index, _) => NavigationBar(
                  selectedIndex: index,
                  onDestinationSelected: _onDestinationSelected,
                  destinations: _getBottomNavigationDestinations(context),
                ),
              )
            : null,
      );

  Widget _getContent() => Navigator(
        key: _navigatorKey,
        onGenerateInitialRoutes: (_, __) => [
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const ServersScreen(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        ],
      );

  void _onDestinationSelected(int selectedIndex) {
    if (_selectedTabNotifier.value != selectedIndex) {
      _selectedTabNotifier.value = selectedIndex;

      _navigatorKey.currentState!.pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => getScreenByIndex(selectedIndex),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    }
  }

  Widget getScreenByIndex(int selectedIndex) => switch (selectedIndex) {
        0 => const ServersScreen(),
        1 => const RoutersScreen(),
        2 => const SettingsScreen(),
        3 => const TestScreen(),
        _ => throw Exception('Invalid index: $selectedIndex'),
      };

  List<Map<String, String>> get destinations => [
        {
          'icon': AssetIcons.add,
          'label': 'Servers',
        },
        {
          'icon': AssetIcons.error,
          'label': 'Routing',
        },
        {
          'icon': AssetIcons.cancel,
          'label': 'Settings',
        },
        if (kDebugMode)
          {
            'icon': AssetIcons.arrowBack,
            'label': 'Test',
          },
      ];

  List<NavigationRailDestination> _getNavigationRailDestinations(
    BuildContext context,
  ) =>
      destinations
          .map(
            (e) => NavigationRailDestination(
              icon: CustomSvgPicture(
                icon: e['icon'].toString(),
                size: 24,
                color: context.colors.contrast1,
              ),
              label: Text(
                e['label'].toString(),
                textAlign: TextAlign.center,
              ).labelMedium(context),
            ),
          )
          .toList();

  List<NavigationDestination> _getBottomNavigationDestinations(
    BuildContext context,
  ) =>
      destinations
          .map(
            (e) => NavigationDestination(
              icon: CustomSvgPicture(
                icon: e['icon'].toString(),
                size: 24,
                color: context.colors.contrast1,
              ),
              label: e['label'].toString(),
            ),
          )
          .toList();
}
