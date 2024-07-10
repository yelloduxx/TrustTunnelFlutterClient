import 'package:vpn/common/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class IconButtonSvg extends StatefulWidget {
  final String icon;
  final String? selectedIcon;
  final VoidCallback? onPressed;
  final double? height;
  final double? width;
  final double? padding;
  final String? tooltip;
  final Color? color;

  const IconButtonSvg({
    super.key,
    required this.icon,
    required this.onPressed,
    this.height,
    this.width,
    this.padding,
    this.tooltip,
    this.color,
  }) : selectedIcon = null;

  const IconButtonSvg.square({
    super.key,
    required this.icon,
    required this.onPressed,
    required double size,
    this.padding,
    this.tooltip,
    this.color,
  })  : height = size,
        width = size,
        selectedIcon = null;

  const IconButtonSvg.toggleable({
    super.key,
    required this.icon,
    required this.selectedIcon,
    required this.onPressed,
    this.height,
    this.width,
    this.padding,
    this.tooltip,
    this.color,
  });

  @override
  State<IconButtonSvg> createState() => _IconButtonSvgState();
}

class _IconButtonSvgState extends State<IconButtonSvg> {
  bool _isSelected = false;

  @override
  Widget build(BuildContext context) => IconButton(
        onPressed: widget.onPressed != null
            ? () {
                widget.onPressed!();
                setState(() => _isSelected = !_isSelected);
              }
            : null,
        tooltip: widget.tooltip ?? '',
        padding: EdgeInsets.all(widget.padding ?? 8),
        isSelected: _isSelected,
        selectedIcon: widget.selectedIcon != null
            ? SvgPicture.asset(
                widget.selectedIcon!,
                height: widget.height,
                width: widget.width,
                fit: BoxFit.scaleDown,
                colorFilter: ColorFilter.mode(
                  widget.onPressed == null ? context.colors.contrast4 : widget.color ?? context.colors.contrast1,
                  BlendMode.srcIn,
                ),
              )
            : null,
        icon: SvgPicture.asset(
          widget.icon,
          height: widget.height,
          width: widget.width,
          fit: BoxFit.scaleDown,
          colorFilter: ColorFilter.mode(
            widget.onPressed == null ? context.colors.contrast4 : widget.color ?? context.colors.contrast1,
            BlendMode.srcIn,
          ),
        ),
      );
}
