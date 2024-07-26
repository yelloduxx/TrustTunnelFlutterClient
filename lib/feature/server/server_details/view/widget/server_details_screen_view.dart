import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vpn/common/extensions/context_extensions.dart';
import 'package:vpn/common/localization/localization.dart';
import 'package:vpn/feature/server/server_details/bloc/server_details_bloc.dart';
import 'package:vpn/feature/server/server_details/view/widget/server_details_discard_changes_dialog.dart';
import 'package:vpn/feature/server/server_details/view/widget/server_details_form.dart';
import 'package:vpn/feature/server/server_details/view/widget/server_details_screen_app_bar_action.dart';
import 'package:vpn/feature/server/server_details/view/widget/server_details_submit_button_section.dart';
import 'package:vpn/view/custom_app_bar.dart';
import 'package:vpn/view/scaffold_wrapper.dart';

class ServerDetailsScreenView extends StatefulWidget {
  const ServerDetailsScreenView({
    super.key,
  });

  @override
  State<ServerDetailsScreenView> createState() => _ServerDetailsScreenViewState();
}

class _ServerDetailsScreenViewState extends State<ServerDetailsScreenView> {
  @override
  Widget build(BuildContext context) => ScaffoldWrapper(
        child: BlocConsumer<ServerDetailsBloc, ServerDetailsState>(
          listenWhen: (_, curr) => curr.action != const ServerDetailsAction.none(),
          listener: (context, state) {
            switch (state.action) {
              case ServerDetailsPresentationError(:final error):
                context.showInfoSnackBar(message: error.toLocalizedString(context));
              case ServerDetailsSaved():
              case ServerDetailsDeleted():
                context.pop();
              default:
                break;
            }
          },
          buildWhen: (prev, curr) => prev.action == curr.action,
          builder: (context, state) => Scaffold(
            appBar: CustomAppBar(
              showBackButton: true,
              centerTitle: true,
              onBackPressed: state.hasChanges ? () => _showNotSavedChangesWarning(context) : null,
              title: state.isEditing ? context.ln.editServer : context.ln.addServer,
              actions: const [ServerDetailsScreenAppBarAction()],
            ),
            body: BlocBuilder<ServerDetailsBloc, ServerDetailsState>(
              buildWhen: (previous, current) => previous.loadingStatus != current.loadingStatus,
              builder: (context, state) {
                return state.loadingStatus == ServerDetailsLoadingStatus.idle
                    ? const Column(
                        children: [
                          Expanded(child: ServerDetailsForm()),
                          ServerDetailsSubmitButtonSection(),
                        ],
                      )
                    : const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

  void _showNotSavedChangesWarning(BuildContext context) => showDialog(
        context: context,
        builder: (_) => ServerDetailsDiscardChangesDialog(
          onDiscardPressed: () => context.pop(),
        ),
      );
}
