import 'package:vpn/common/extensions/context_extensions.dart';
import 'package:vpn/common/extensions/theme_extensions.dart';
import 'package:vpn/view/hover_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TextButtonSvg extends StatefulWidget {
  final String icon;
  final VoidCallback? onPressed;
  final String label;

  const TextButtonSvg({
    super.key,
    required this.icon,
    required this.label,
    this.onPressed,
  });

  @override
  State<TextButtonSvg> createState() => _TextButtonSvgState();
}

class _TextButtonSvgState extends State<TextButtonSvg> {
  late final _statesController = WidgetStatesController();

  @override
  void dispose() {
    _statesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Theme(
        data: context.theme.copyWith(
          textButtonTheme: context.theme.extension<CustomTextButtonTheme>()!.iconButton,
        ),
        child: HoverThemeProvider(
          child: TextButton.icon(
            onPressed: widget.onPressed,
            label: Text(widget.label),
            statesController: _statesController,
            icon: ValueListenableBuilder(
              valueListenable: _statesController,
              builder: (context, value, child) => SvgPicture.asset(
                widget.icon,
                height: 18,
                width: 18,
                fit: BoxFit.scaleDown,
                colorFilter: ColorFilter.mode(
                  context.theme.textButtonTheme.style?.foregroundColor?.resolve(value) ?? context.colors.staticWhite,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
      );
}
