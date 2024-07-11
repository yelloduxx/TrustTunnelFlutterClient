import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vpn/data/model/breakpoint.dart';

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

  static Route<T> getRoute<T>(Widget widget) => kIsWeb
      ? PageRouteBuilder<T>(
          pageBuilder: (context, animation, secondaryAnimation) => widget,
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        )
      : MaterialPageRoute<T>(
          builder: (_) => widget,
        );
}
