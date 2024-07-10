import 'package:vpn/common/extensions/context_extensions.dart';
import 'package:vpn/common/extensions/theme_extensions.dart';
import 'package:vpn/view/hover_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FilledButtonSvg extends StatelessWidget {
  final String icon;
  final VoidCallback? onPressed;
  final String label;

  const FilledButtonSvg({
    super.key,
    required this.icon,
    required this.label,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) => Theme(
        data: context.theme.copyWith(
          filledButtonTheme: context.theme.extension<CustomFilledButtonTheme>()!.iconButton,
        ),
        child: HoverThemeProvider(
          child: FilledButton.icon(
            onPressed: onPressed,
            label: Text(label),
            icon: SvgPicture.asset(
              icon,
              height: 18,
              width: 18,
              fit: BoxFit.scaleDown,
              colorFilter: ColorFilter.mode(
                context.theme.filledButtonTheme.style?.foregroundColor?.resolve({}) ?? context.colors.staticWhite,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      );
}
