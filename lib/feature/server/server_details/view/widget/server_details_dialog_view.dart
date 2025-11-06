import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vpn/common/extensions/context_extensions.dart';
import 'package:vpn/common/extensions/theme_extensions.dart';
import 'package:vpn/common/localization/localization.dart';
import 'package:vpn/feature/server/server_details/bloc/server_details_bloc.dart';
import 'package:vpn/view/custom_alert_dialog.dart';

class ServerDetailsDialogView extends StatelessWidget {
  final Widget body;
  final ValueChanged<bool> onDiscardChanges;

  const ServerDetailsDialogView({
    super.key,
    required this.body,
    required this.onDiscardChanges,
  });

  @override
  Widget build(BuildContext context) => BlocBuilder<ServerDetailsBloc, ServerDetailsState>(
    buildWhen: (previous, current) => previous.hasChanges != current.hasChanges,
    builder: (context, state) => CustomAlertDialog(
      title: state.isEditing ? context.ln.editServer : context.ln.addServer,
      onClose: () => onDiscardChanges(state.hasChanges),
      scrollable: true,
      content: body,
      contentPadding: const EdgeInsets.all(0),

      actionsBuilder: (_) => [
        TextButton(
          onPressed: () => onDiscardChanges(state.hasChanges),
          child: Text(context.ln.cancel),
        ),
        Theme(
          data: context.theme.copyWith(
            textButtonTheme: context.theme.extension<CustomTextButtonTheme>()!.success,
          ),
          child: TextButton(
            onPressed: state.hasChanges
                ? () => context.read<ServerDetailsBloc>().add(const ServerDetailsEvent.submit())
                : null,
            child: Text(
              state.isEditing ? context.ln.save : context.ln.add,
            ),
          ),
        ),
      ],
    ),
  );
}
