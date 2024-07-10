import 'package:vpn/common/extensions/common_extensions.dart';
import 'package:vpn/common/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomRadioListTile<T> extends StatelessWidget {
  final T type;
  final T currentValue;
  final String? title;
  final Widget? titleWidget;

  final String? subTitle;
  final String? iconPath;
  final ValueChanged<T?> onChanged;

  const CustomRadioListTile({
    super.key,
    required this.type,
    required this.currentValue,
    required this.title,
    required this.onChanged,
    this.iconPath,
    this.subTitle,
  }) : titleWidget = null;

  const CustomRadioListTile.titleWidget({
    super.key,
    required this.type,
    required this.currentValue,
    required this.titleWidget,
    required this.onChanged,
    this.iconPath,
    this.subTitle,
  }) : title = null;

  @override
  Widget build(BuildContext context) {
    const double iconSize = 24;

    return InkWell(
      onTap: () => onChanged(type),
      child: Ink(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox.square(
                dimension: 24,
                child: Radio<T>(
                  value: type,
                  splashRadius: 0,
                  groupValue: currentValue,
                  onChanged: (_) => onChanged(type),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: title != null ? Text(title!).labelLarge(context) : titleWidget!,
                    ),
                    if (subTitle != null) ...[
                      Text(
                        subTitle!,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colors.gray1,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (iconPath != null) ...[
                const SizedBox(width: 16),
                SvgPicture.asset(
                  iconPath!,
                  width: iconSize,
                  height: iconSize,
                  colorFilter: ColorFilter.mode(
                    context.colors.contrast1,
                    BlendMode.srcIn,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
