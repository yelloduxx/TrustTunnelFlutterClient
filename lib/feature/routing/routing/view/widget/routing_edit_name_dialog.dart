import 'package:flutter/material.dart';
import 'package:vpn/common/extensions/context_extensions.dart';
import 'package:vpn/common/extensions/theme_extensions.dart';
import 'package:vpn/common/localization/localization.dart';
import 'package:vpn/view/custom_alert_dialog.dart';
import 'package:vpn/view/inputs/custom_text_field.dart';

class RoutingEditNameDialog extends StatefulWidget {
  final ValueChanged<String> onSavePressed;
  final String currentRoutingName;

  const RoutingEditNameDialog({
    super.key,
    required this.onSavePressed,
    required this.currentRoutingName,
  });

  @override
  State<RoutingEditNameDialog> createState() => _RoutingEditNameDialogState();
}

class _RoutingEditNameDialogState extends State<RoutingEditNameDialog> {
  late String _routingName = widget.currentRoutingName;

  @override
  Widget build(BuildContext context) => CustomAlertDialog(
        title: context.ln.editProfile,
        scrollable: true,
        content: Padding(
          padding: const EdgeInsets.only(top: 24),
          child: CustomTextField(
            label: context.ln.routingProfile,
            value: _routingName,
            onChanged: _onRoutingNameChanged,
          ),
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
                widget.onSavePressed(_routingName);
              },
              child: Text(context.ln.save),
            ),
          ),
        ],
      );

  void _onRoutingNameChanged(String? name) {
    if (name == null || name == _routingName) return;
    _routingName = name;
  }
}
