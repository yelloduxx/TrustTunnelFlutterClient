import 'package:vpn/common/assets/asset_icons.dart';
import 'package:vpn/common/extensions/common_extensions.dart';
import 'package:vpn/common/extensions/context_extensions.dart';
import 'package:vpn/data/model/breakpoint.dart';
import 'package:vpn/view/buttons/icon_button_svg.dart';
import 'package:flutter/material.dart';

const _titlePadding = EdgeInsets.fromLTRB(24, 24, 24, 16);

const _contentPadding = EdgeInsets.symmetric(horizontal: 24);

const _actionsPadding = EdgeInsets.all(24);

const _buttonPadding = EdgeInsets.symmetric(horizontal: 8);

const _scrollable = false;
const _actionsAlignment = MainAxisAlignment.end;
const _showCloseButton = false;

class CustomAlertDialog extends StatelessWidget {
  final String? title;
  final Widget? titleWidget;
  final double? width;
  final double? height;
  final MainAxisAlignment actionsAlignment;
  final bool scrollable;
  final EdgeInsets titlePadding;
  final EdgeInsets contentPadding;
  final EdgeInsets actionsPadding;
  final EdgeInsets buttonPadding;
  final Widget? content;
  final List<Widget> Function(double spacing)? actionsBuilder;
  final bool showCloseButton;
  final VoidCallback? onClose;

  const CustomAlertDialog({
    super.key,
    required this.title,
    this.width,
    this.height,
    this.actionsAlignment = _actionsAlignment,
    this.scrollable = _scrollable,
    this.titlePadding = _titlePadding,
    this.contentPadding = _contentPadding,
    this.actionsPadding = _actionsPadding,
    this.buttonPadding = _buttonPadding,
    this.content,
    this.actionsBuilder,
    this.showCloseButton = _showCloseButton,
    this.onClose,
  })  : titleWidget = null,
        assert(width != null ? width >= 0 : true),
        assert(height != null ? height >= 0 : true);

  const CustomAlertDialog.customTitle({
    super.key,
    required Widget title,
    this.width,
    this.height,
    this.actionsAlignment = _actionsAlignment,
    this.scrollable = _scrollable,
    this.titlePadding = _titlePadding,
    this.contentPadding = _contentPadding,
    this.actionsPadding = _actionsPadding,
    this.buttonPadding = _buttonPadding,
    this.content,
    this.actionsBuilder,
    this.showCloseButton = _showCloseButton,
    this.onClose,
  })  : title = null,
        titleWidget = title,
        assert(width != null ? width >= 0 : true),
        assert(height != null ? height >= 0 : true);

  @override
  Widget build(BuildContext context) {
    final windowWidth = width ??
        switch (context.breakpoint) {
          Breakpoint.XS => double.maxFinite,
          _ => 312.0,
        };

    final actionsSpacing = buttonPadding.horizontal / 2;

    final dialogTitle = ColoredBox(
      color: context.colors.background1,
      child: Padding(
        padding: titlePadding,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            title == null
                ? Expanded(child: titleWidget!)
                : Expanded(
                    child: Text(
                      title!,
                      overflow: TextOverflow.ellipsis,
                    ).headlineSmall(context),
                  ),
            if (showCloseButton)
              IconButtonSvg(
                icon: AssetIcons.close,
                onPressed: onClose ?? Navigator.of(context).pop,
              )
          ],
        ),
      ),
    );

    final dialogContent = Padding(
      padding: contentPadding,
      child: SizedBox(
        width: windowWidth,
        child: content,
      ),
    );

    final dialogActions = ColoredBox(
      color: context.colors.background1,
      child: Padding(
        padding: actionsPadding,
        child: OverflowBar(
          alignment: actionsAlignment,
          spacing: actionsSpacing,
          children: actionsBuilder?.call(actionsSpacing) ?? [],
        ),
      ),
    );

    final List<Widget> columnChildren = [
      dialogTitle,
      if (content != null)
        Flexible(
          child: scrollable
              ? SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      if (content != null) dialogContent,
                    ],
                  ),
                )
              : dialogContent,
        ),
      if (actionsBuilder != null) ...[
        if (content == null)
          const SizedBox(
            height: 24,
          ),
        dialogActions,
      ],
    ];

    return PopScope(
      canPop: onClose == null,
      onPopInvoked: (didPop) => !didPop ? onClose?.call() : null,
      child: Dialog(
        child: SizedBox(
          width: windowWidth + contentPadding.horizontal,
          height: height,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: columnChildren,
            ),
          ),
        ),
      ),
    );
  }
}
