import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vpn/common/extensions/context_extensions.dart';

class IconButtonSvgExternalState extends StatelessWidget {
  final String icon;
  final String? selectedIcon;
  final VoidCallback? onPressed;
  final double? height;
  final double? width;
  final double? padding;
  final String? tooltip;
  final Color? color;
  final bool isSelected;

  const IconButtonSvgExternalState({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.isSelected,
    this.height,
    this.width,
    this.padding,
    this.tooltip,
    this.color,
  }) : selectedIcon = null;

  const IconButtonSvgExternalState.square({
    super.key,
    required this.icon,
    required this.onPressed,
    required double size,
    this.padding,
    this.tooltip,
    this.color,
    required this.isSelected,
  })  : height = size,
        width = size,
        selectedIcon = null;

  const IconButtonSvgExternalState.toggleable({
    super.key,
    required this.icon,
    required this.selectedIcon,
    required this.onPressed,
    required this.isSelected,
    this.height,
    this.width,
    this.padding,
    this.tooltip,
    this.color,
  });

  @override
  Widget build(BuildContext context) => IconButton(
        onPressed: onPressed != null ? () => onPressed!() : null,
        tooltip: tooltip ?? '',
        padding: EdgeInsets.all(padding ?? 8),
        isSelected: isSelected,
        selectedIcon: selectedIcon != null
            ? SvgPicture.asset(
                selectedIcon!,
                height: height,
                width: width,
                fit: BoxFit.scaleDown,
                colorFilter: ColorFilter.mode(
                  onPressed == null
                      ? context.colors.contrast4
                      : color ?? context.colors.contrast1,
                  BlendMode.srcIn,
                ),
              )
            : null,
        icon: SvgPicture.asset(
          icon,
          height: height,
          width: width,
          fit: BoxFit.scaleDown,
          colorFilter: ColorFilter.mode(
            color ?? context.colors.contrast1,
            BlendMode.srcIn,
          ),
        ),
      );
}
