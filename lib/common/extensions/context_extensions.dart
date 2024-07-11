import 'package:flutter/material.dart';
import 'package:vpn/common/extensions/theme_extensions.dart';
import 'package:vpn/common/utils/common_utils.dart';
import 'package:vpn/data/model/breakpoint.dart';
import 'package:vpn/di/dependency_scope.dart';
import 'package:vpn/di/factory/bloc_factory.dart';
import 'package:vpn/di/factory/dependency_factory.dart';
import 'package:vpn/di/factory/repository_factory.dart';

extension ScreenTypeExtension on BuildContext {
  Breakpoint get breakpoint => CommonUtils.getBreakpointByWidth(MediaQuery.of(this).size.width);

  bool get isMobileBreakpoint => breakpoint == Breakpoint.XS;
}

extension DependencyExtension on BuildContext {
  DependencyFactory get dependencyFactory => DependencyScope.getDependenciesFactory(this);

  RepositoryFactory get repositoryFactory => DependencyScope.getRepositoryFactory(this);

  BlocFactory get blocFactory => DependencyScope.getBlocFactory(this);
}

extension ThemeContext on BuildContext {
  ThemeData get theme => Theme.of(this);

  TextTheme get textTheme => Theme.of(this).textTheme;

  CustomColors get colors => Theme.of(this).extension<CustomColors>()!;
}

extension SnackBarExtension on BuildContext {
  void showInfoSnackBar({
    required String message,
    bool showCloseIcon = false,
    SnackBarBehavior behavior = SnackBarBehavior.fixed,
  }) =>
      ScaffoldMessenger.of(this)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(message),
            behavior: behavior,
            showCloseIcon: showCloseIcon,
          ),
        );
}

extension NavigatorExtension on BuildContext {
  void pop() => Navigator.of(this).pop();

  Future<T?> pushReplacement<T extends Object?, TO extends Object?>(Widget widget) =>
      Navigator.of(this).pushReplacement(CommonUtils.getRoute(widget));

  Future<T?> push<T extends Object?>(Widget widget) => Navigator.of(this).push(CommonUtils.getRoute(widget));
}
