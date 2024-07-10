import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class SeparatedColumn extends StatelessWidget {
  final List<Widget> children;
  final Widget Function(BuildContext context, int index) separatorBuilder;
  final MainAxisSize mainAxisSize;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;

  const SeparatedColumn({
    super.key,
    required this.children,
    required this.separatorBuilder,
    this.mainAxisSize = MainAxisSize.max,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: mainAxisSize,
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: children.expandIndexed(
          (i, e) {
            if (i == children.length - 1) {
              return [e];
            }

            return [
              e,
              separatorBuilder(context, i),
            ];
          },
        ).toList(),
      );
}
