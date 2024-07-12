import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vpn/common/assets/asset_icons.dart';
import 'package:vpn/common/extensions/common_extensions.dart';
import 'package:vpn/common/extensions/context_extensions.dart';
import 'package:vpn/view/custom_svg_picture.dart';

abstract class NavigationScreenUtils {
  static List<Map<String, String>> get destinations => [
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

  static List<NavigationRailDestination> getNavigationRailDestinations(
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

  static List<NavigationDestination> getBottomNavigationDestinations(
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
