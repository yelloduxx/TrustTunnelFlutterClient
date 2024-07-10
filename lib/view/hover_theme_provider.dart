import 'package:flutter/material.dart';
import 'package:vpn/common/extensions/context_extensions.dart';

/// Виджет необходим в ситуациях, когда цвет Hover или Focus определяется
/// WidgetState, т.е. элемент управления раскрашен и не должен окрашиваться
/// в дефолтные цвета hover и focus
class HoverThemeProvider extends StatelessWidget {
  final Widget child;

  const HoverThemeProvider({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => Theme(
        data: context.theme.copyWith(
          hoverColor: context.colors.staticTransparent,
          focusColor: context.colors.staticTransparent,
        ),
        child: child,
      );
}
