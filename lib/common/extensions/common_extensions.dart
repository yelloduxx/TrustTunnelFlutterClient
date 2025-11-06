import 'dart:ui' as ui show TextHeightBehavior;

import 'package:flutter/material.dart';
import 'package:vpn/common/extensions/context_extensions.dart';

extension TextX on Text {
  Text displayLarge(BuildContext context) => copyWith(
    data: data!,
    style: context.theme.textTheme.displayLarge!,
  );
  Text displayMedium(BuildContext context) => copyWith(
    data: data!,
    style: context.theme.textTheme.displayMedium!,
  );
  Text displaySmall(BuildContext context) => copyWith(
    data: data!,
    style: context.theme.textTheme.displaySmall!,
  );
  Text headlineLarge(BuildContext context) => copyWith(
    data: data!,
    style: context.theme.textTheme.headlineLarge!,
  );
  Text headlineMedium(BuildContext context) => copyWith(
    data: data!,
    style: context.theme.textTheme.headlineMedium!,
  );
  Text headlineSmall(BuildContext context) => copyWith(
    data: data!,
    style: context.theme.textTheme.headlineSmall!,
  );
  Text titleLarge(BuildContext context) => copyWith(
    data: data!,
    style: context.theme.textTheme.titleLarge!,
  );
  Text titleMedium(BuildContext context) => copyWith(
    data: data!,
    style: context.theme.textTheme.titleMedium!,
  );
  Text titleSmall(BuildContext context) => copyWith(
    data: data!,
    style: context.theme.textTheme.titleSmall!,
  );
  Text labelLarge(BuildContext context) => copyWith(
    data: data!,
    style: context.theme.textTheme.labelLarge!,
  );
  Text labelMedium(BuildContext context) => copyWith(
    data: data!,
    style: context.theme.textTheme.labelMedium!,
  );
  Text labelSmall(BuildContext context) => copyWith(
    data: data!,
    style: context.theme.textTheme.labelSmall!,
  );
  Text bodyLarge(BuildContext context) => copyWith(
    data: data!,
    style: context.theme.textTheme.bodyLarge!,
  );
  Text bodyMedium(BuildContext context) => copyWith(
    data: data!,
    style: context.theme.textTheme.bodyMedium!,
  );
  Text bodySmall(BuildContext context) => copyWith(
    data: data!,
    style: context.theme.textTheme.bodySmall!,
  );

  Text copyWith({
    required String data,
    InlineSpan? textSpan,
    TextStyle? style,
    StrutStyle? strutStyle,
    TextAlign? textAlign,
    TextDirection? textDirection,
    Locale? locale,
    bool? softWrap,
    TextOverflow? overflow,
    double? textScaleFactor,
    TextScaler? textScaler,
    int? maxLines,
    String? semanticsLabel,
    TextWidthBasis? textWidthBasis,
    ui.TextHeightBehavior? textHeightBehavior,
    Color? selectionColor,
  }) => Text(
    this.data ?? data,
    style: style ?? this.style,
    strutStyle: strutStyle ?? this.strutStyle,
    textAlign: textAlign ?? this.textAlign,
    textDirection: textDirection ?? this.textDirection,
    locale: locale ?? this.locale,
    softWrap: softWrap ?? this.softWrap,
    overflow: overflow ?? this.overflow,
    // ignore: deprecated_member_use
    textScaleFactor: textScaleFactor ?? this.textScaleFactor,
    textScaler: textScaler ?? this.textScaler,
    maxLines: maxLines ?? this.maxLines,
    semanticsLabel: semanticsLabel ?? this.semanticsLabel,
    textWidthBasis: textWidthBasis ?? this.textWidthBasis,
    textHeightBehavior: textHeightBehavior ?? this.textHeightBehavior,
    selectionColor: selectionColor ?? this.selectionColor,
  );
}
