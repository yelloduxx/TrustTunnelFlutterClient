import 'package:flutter/material.dart';
import 'package:vpn/common/extensions/context_extensions.dart';
import 'package:vpn/common/extensions/theme_extensions.dart';
import 'package:vpn/common/localization/localization.dart';
import 'package:vpn/view/custom_alert_dialog.dart';

class ServerDetailsDeleteDialog extends StatelessWidget {
  final String serverName;
  final VoidCallback onDeletePressed;

  const ServerDetailsDeleteDialog({
    super.key,
    required this.serverName,
    required this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) => CustomAlertDialog(
        title: context.ln.deleteServerDialogTitle,
        scrollable: true,
        content: Text(context.ln.deleteServerDescription(serverName)),
        actionsBuilder: (spacing) => [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(context.ln.cancel),
          ),
          Theme(
            data: context.theme.copyWith(
              textButtonTheme: context.theme.extension<CustomTextButtonTheme>()!.danger,
            ),
            child: TextButton(
              onPressed: () {
                context.pop();
                onDeletePressed();
              },
              child: Text(context.ln.delete),
            ),
          ),
        ],
      );
}
