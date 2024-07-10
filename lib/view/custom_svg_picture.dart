import 'package:vpn/common/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CustomSvgPicture extends StatelessWidget {
  final String icon;
  final double? size;
  final Color? color;

  const CustomSvgPicture({
    super.key,
    required this.icon,
    this.size,
    this.color,
  });

  @override
  SvgPicture build(BuildContext context) => SvgPicture.asset(
        icon,
        height: size ?? 24,
        width: size ?? 24,
        fit: BoxFit.scaleDown,
        colorFilter: ColorFilter.mode(
          color ?? context.theme.dialogTheme.iconColor ?? context.colors.contrast1,
          BlendMode.srcIn,
        ),
      );
}
