import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vpn/common/extensions/context_extensions.dart';
import 'package:vpn/view/hover_theme_provider.dart';

enum FloatingActionButtonSvgType { extended, standart, small, large }

class FloatingActionButtonSvg extends StatelessWidget {
  final String icon;
  final VoidCallback? onPressed;
  final FloatingActionButtonSvgType type;
  final String? label;

  const FloatingActionButtonSvg({
    super.key,
    required this.icon,
    required this.onPressed,
  })  : type = FloatingActionButtonSvgType.standart,
        label = null;

  const FloatingActionButtonSvg.extended({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.label,
  }) : type = FloatingActionButtonSvgType.extended;

  const FloatingActionButtonSvg.small({
    super.key,
    required this.icon,
    required this.onPressed,
  })  : type = FloatingActionButtonSvgType.small,
        label = null;

  const FloatingActionButtonSvg.large({
    super.key,
    required this.icon,
    required this.onPressed,
  })  : type = FloatingActionButtonSvgType.large,
        label = null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).floatingActionButtonTheme;
    final svgIcon = SvgPicture.asset(
      icon,
      height: theme.iconSize,
      width: theme.iconSize,
      fit: BoxFit.scaleDown,
      colorFilter: ColorFilter.mode(
        theme.foregroundColor ?? context.colors.primary1,
        BlendMode.srcIn,
      ),
    );

    final Widget button = switch (type) {
      FloatingActionButtonSvgType.standart => FloatingActionButton(onPressed: onPressed, child: svgIcon),
      FloatingActionButtonSvgType.extended => label != null
          ? FloatingActionButton.extended(
              onPressed: onPressed,
              icon: svgIcon,
              label: Text(
                label!,
                style: context.theme.textTheme.labelLarge?.copyWith(color: theme.foregroundColor),
              ),
            )
          : FloatingActionButton(onPressed: onPressed, child: svgIcon),
      FloatingActionButtonSvgType.small => FloatingActionButton.small(onPressed: onPressed, child: svgIcon),
      FloatingActionButtonSvgType.large => FloatingActionButton.large(onPressed: onPressed, child: svgIcon),
      _ => FloatingActionButton(onPressed: onPressed, child: svgIcon)
    };

    return HoverThemeProvider(child: button);
  }
}
