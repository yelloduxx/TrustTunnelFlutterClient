import 'package:flutter/material.dart';
import 'package:vpn/common/extensions/context_extensions.dart';
import 'package:vpn/common/extensions/theme_extensions.dart';
import 'package:vpn/common/localization/localization.dart';
import 'package:vpn/data/model/routing_mode.dart';
import 'package:vpn/view/custom_alert_dialog.dart';
import 'package:vpn/view/menu/custom_dropdown_menu.dart';

class RoutingDetailsChangeRoutingDialog extends StatefulWidget {
  final ValueChanged<RoutingMode> onSavePressed;
  final RoutingMode currentRoutingMode;

  const RoutingDetailsChangeRoutingDialog({
    super.key,
    required this.onSavePressed,
    required this.currentRoutingMode,
  });

  @override
  State<RoutingDetailsChangeRoutingDialog> createState() =>
      _RoutingDetailsChangeRoutingDialogState();
}

class _RoutingDetailsChangeRoutingDialogState
    extends State<RoutingDetailsChangeRoutingDialog> {
  late RoutingMode _selectedRoutingMode = widget.currentRoutingMode;

  @override
  Widget build(BuildContext context) => CustomAlertDialog(
        title: context.ln.changeDefaultRoutingMode,
        scrollable: true,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.ln.changeDefaultRoutingModeDialogDescription),
            const SizedBox(height: 40),
            CustomDropdownMenu<RoutingMode>.expanded(
              value: _selectedRoutingMode,
              values: RoutingMode.values,
              toText: (value) => value.toString(),
              labelText: context.ln.defaultProfile,
              onChanged: _onRoutingChanged,
            ),
          ],
        ),
        actionsBuilder: (spacing) => [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(context.ln.cancel),
          ),
          Theme(
            data: context.theme.copyWith(
              textButtonTheme:
                  context.theme.extension<CustomTextButtonTheme>()!.success,
            ),
            child: TextButton(
              onPressed: () {
                context.pop();
                widget.onSavePressed(_selectedRoutingMode);
              },
              child: Text(context.ln.save),
            ),
          ),
        ],
      );

  void _onRoutingChanged(RoutingMode? mode) {
    if (mode == null || mode == _selectedRoutingMode) return;
    _selectedRoutingMode = mode;
  }
}
