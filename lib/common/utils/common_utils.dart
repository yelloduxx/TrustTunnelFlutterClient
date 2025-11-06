import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vpn/data/model/breakpoint.dart';
import 'package:vpn/view/common/scaffold_messenger_provider.dart';

class CommonUtils {
  const CommonUtils._();

  static const widthBreakpointXS = 600;
  static const widthBreakpointS = 904;

  static double getScreenWidth() =>
      WidgetsBinding.instance.platformDispatcher.views.first.physicalSize.width /
      WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;

  static Breakpoint getBreakpointByWidth(double width) => switch (width) {
    >= CommonUtils.widthBreakpointS => Breakpoint.M,
    >= CommonUtils.widthBreakpointXS => Breakpoint.S,
    _ => Breakpoint.XS,
  };

  static Breakpoint getBreakpoint() => getBreakpointByWidth(getScreenWidth());

  static Route<T> getRoute<T>(BuildContext context, Widget widget) => kIsWeb
      ? PageRouteBuilder<T>(
          pageBuilder: (innerContext, animation, secondaryAnimation) =>
              _getWidgetBuilder(context, widget).call(innerContext),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        )
      : MaterialPageRoute<T>(
          builder: (innerContext) => _getWidgetBuilder(context, widget).call(innerContext),
        );

  static WidgetBuilder _getWidgetBuilder(BuildContext context, Widget widget) {
    final parentScaffoldMessenger = ScaffoldMessenger.maybeOf(context);
    return (innerContext) => ScaffoldMessengerProvider(
      value: parentScaffoldMessenger ?? ScaffoldMessenger.of(innerContext),
      child: widget,
    );
  }
}
