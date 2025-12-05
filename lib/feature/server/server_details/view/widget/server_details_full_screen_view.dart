import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vpn/common/localization/localization.dart';
import 'package:vpn/feature/server/server_details/bloc/server_details_bloc.dart';
import 'package:vpn/feature/server/server_details/view/widget/server_details_screen_app_bar_action.dart';
import 'package:vpn/view/custom_app_bar.dart';

class ServerDetailsFullScreenView extends StatelessWidget {
  final Widget body;
  final ValueChanged<bool> onDiscardChanges;

  const ServerDetailsFullScreenView({
    super.key,
    required this.body,
    required this.onDiscardChanges,
  });

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Scaffold(
      body: BlocBuilder<ServerDetailsBloc, ServerDetailsState>(
        buildWhen: (previous, current) => previous.hasChanges != current.hasChanges,
        builder: (context, state) => CustomScrollView(
          physics: const ClampingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: CustomAppBar(
                actions: const [ServerDetailsScreenAppBarAction()],
                leadingIconType: AppBarLeadingIconType.back,
                centerTitle: true,
                onBackPressed: () => onDiscardChanges.call(state.hasChanges),
                title: state.isEditing ? context.ln.editServer : context.ln.addServer,
              ),
            ),
            SliverToBoxAdapter(
              child: body,
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              fillOverscroll: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: FilledButton(
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
            ),
          ],
        ),
      ),
    ),
  );
}
