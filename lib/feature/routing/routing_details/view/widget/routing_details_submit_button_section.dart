import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vpn/common/extensions/context_extensions.dart';
import 'package:vpn/common/localization/localization.dart';
import 'package:vpn/feature/routing/routing_details/bloc/routing_details_bloc.dart';

class RoutingDetailsSubmitButtonSection extends StatelessWidget {
  const RoutingDetailsSubmitButtonSection({super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: context.isMobileBreakpoint
        ? const _Button()
        : const Align(
            alignment: Alignment.centerRight,
            child: _Button(),
          ),
  );
}

class _Button extends StatelessWidget {
  const _Button();

  @override
  Widget build(BuildContext context) => BlocBuilder<RoutingDetailsBloc, RoutingDetailsState>(
    buildWhen: (previous, current) => previous.action == current.action,
    builder: (context, state) => FilledButton(
      onPressed: state.hasChanges && !state.hasInvalidRules ? () => _addRouting(context) : null,
      child: Text(
        state.isEditing ? context.ln.save : context.ln.add,
      ),
    ),
  );

  void _addRouting(BuildContext context) => context.read<RoutingDetailsBloc>().add(
    const RoutingDetailsEvent.submit(),
  );
}
