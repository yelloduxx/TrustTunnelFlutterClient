import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vpn/common/extensions/context_extensions.dart';
import 'package:vpn/common/extensions/enum_extensions.dart';
import 'package:vpn/feature/routing/routing_details/bloc/routing_details_bloc.dart';
import 'package:vpn/feature/routing/routing_details/view/widget/routing_details_discard_changes_dialog.dart';
import 'package:vpn/feature/routing/routing_details/view/widget/routing_details_form.dart';
import 'package:vpn/feature/routing/routing_details/view/widget/routing_details_screen_app_bar_action.dart';
import 'package:vpn/feature/routing/routing_details/view/widget/routing_details_submit_button_section.dart';
import 'package:vpn/view/custom_app_bar.dart';
import 'package:vpn/view/scaffold_wrapper.dart';
import 'package:vpn_plugin/platform_api.g.dart';

class RoutingDetailsScreenView extends StatelessWidget {
  const RoutingDetailsScreenView({super.key});

  @override
  Widget build(BuildContext context) => ScaffoldWrapper(
        child: DefaultTabController(
          length: RoutingMode.values.length,
          child: BlocConsumer<RoutingDetailsBloc, RoutingDetailsState>(
            listenWhen: (previous, current) => current.action != const RoutingDetailsAction.none(),
            listener: (context, state) {
              switch (state.action) {
                case RoutingDetailsPresentationError(:final error):
                  context.showInfoSnackBar(message: error.toLocalizedString(context));
                case RoutingDetailsSaved():
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
                title: state.routingName,
                actions: const [
                  RoutingDetailsScreenAppBarAction(),
                ],
                bottomHeight: context.isMobileBreakpoint ? 48 : 0,
                bottomPadding: EdgeInsets.zero,
                bottom: context.isMobileBreakpoint
                    ? TabBar(
                        tabs: [
                          ...RoutingMode.values.map(
                            (item) {
                              return Text(
                                item.stringValue,
                              );
                            },
                          ),
                        ],
                      )
                    : null,
              ),
              body: state.loadingStatus == RoutingDetailsLoadingStatus.idle
                  ? const Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: RoutingDetailsForm(),
                        ),
                        RoutingDetailsSubmitButtonSection(),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ),
      );

  void _showNotSavedChangesWarning(BuildContext context) => showDialog(
        context: context,
        builder: (_) => RoutingDetailsDiscardChangesDialog(
          onDiscardPressed: () => context.pop(),
        ),
      );
}
