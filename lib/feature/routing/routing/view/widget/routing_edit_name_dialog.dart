import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vpn/common/error/model/enum/presentation_field_name.dart';
import 'package:vpn/common/extensions/context_extensions.dart';
import 'package:vpn/common/extensions/theme_extensions.dart';
import 'package:vpn/common/localization/localization.dart';
import 'package:vpn/feature/routing/routing/bloc/routing_bloc.dart';
import 'package:vpn/feature/routing/routing/model/routing_profile_modification_result.dart';
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
  Widget build(BuildContext context) => BlocListener<RoutingBloc, RoutingState>(
    listenWhen: (_, current) => current.action != const RoutingAction.none(),
    listener: (context, state) {
      switch (state.action) {
        case RoutingActionSaved():
          if (Navigator.canPop(context)) context.pop(result: RoutingProfileModificationResult.saved);
          break;
        default:
      }
    },
    child: CustomAlertDialog(
      title: context.ln.editProfile,
      scrollable: true,
      content: Padding(
        padding: const EdgeInsets.only(top: 24),
        child: BlocBuilder<RoutingBloc, RoutingState>(
          builder: (context, state) {
            final error = state.fieldErrors
                .where(
                  (element) => element.fieldName == PresentationFieldName.profileName,
                )
                .firstOrNull;

            return CustomTextField(
              label: context.ln.routingProfile,
              value: _routingName,
              error: error?.toLocalizedString(context),
              onChanged: (name) => _onRoutingNameChanged(name, error != null),
            );
          },
        ),
      ),
      actionsBuilder: (spacing) => [
        TextButton(
          onPressed: () => context.pop(),
          child: Text(context.ln.cancel),
        ),
        Theme(
          data: context.theme.copyWith(
            textButtonTheme: context.theme.extension<CustomTextButtonTheme>()!.success,
          ),
          child: TextButton(
            onPressed: () => widget.onSavePressed(_routingName),
            child: Text(context.ln.save),
          ),
        ),
      ],
    ),
  );

  void _onRoutingNameChanged(String? name, bool hasErrors) {
    if (name == null || name == _routingName) return;
    _routingName = name;
    if (hasErrors) {
      context.read<RoutingBloc>().add(
        const RoutingEvent.dataChanged(
          fieldError: [],
        ),
      );
    }
  }
}
