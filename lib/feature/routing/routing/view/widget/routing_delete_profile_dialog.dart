import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vpn/common/extensions/context_extensions.dart';
import 'package:vpn/common/extensions/theme_extensions.dart';
import 'package:vpn/common/localization/localization.dart';
import 'package:vpn/feature/routing/routing/bloc/routing_bloc.dart';
import 'package:vpn/feature/routing/routing/model/routing_profile_modification_result.dart';
import 'package:vpn/view/custom_alert_dialog.dart';

class RoutingDeleteProfileDialog extends StatelessWidget {
  final String profileName;
  final VoidCallback onDeletePressed;

  const RoutingDeleteProfileDialog({
    super.key,
    required this.profileName,
    required this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) => BlocListener<RoutingBloc, RoutingState>(
    listenWhen: (_, current) => current.action != const RoutingAction.none(),
    listener: (context, state) {
      switch (state.action) {
        case RoutingActionDeleted():
          if (Navigator.canPop(context)) context.pop(result: RoutingProfileModificationResult.deleted);
        default:
      }
    },
    child: CustomAlertDialog(
      title: context.ln.deleteProfileDialogTitle,
      scrollable: true,
      content: Text(context.ln.deleteProfileDescription(profileName)),
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
            onPressed: () => onDeletePressed(),
            child: Text(context.ln.delete),
          ),
        ),
      ],
    ),
  );
}
