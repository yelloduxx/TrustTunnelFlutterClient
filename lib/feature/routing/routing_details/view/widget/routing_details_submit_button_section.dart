import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vpn/common/extensions/context_extensions.dart';
import 'package:vpn/common/localization/localization.dart';
import 'package:vpn/feature/routing/routing_details/bloc/routing_details_bloc.dart';

class RoutingDetailsSubmitButtonSection extends StatelessWidget {
  final int? routingId;

  const RoutingDetailsSubmitButtonSection({
    super.key,
    required this.routingId,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(16),
        child: context.isMobileBreakpoint
            ? _Button(routingId: routingId)
            : Align(
                alignment: Alignment.centerRight,
                child: _Button(routingId: routingId),
              ),
      );
}

class _Button extends StatelessWidget {
  final int? routingId;

  const _Button({required this.routingId});

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: () => _addRouting(context),
      child: Text(
        routingId == null ? context.ln.add : context.ln.save,
      ),
    );
  }

  void _addRouting(BuildContext context) =>
      context.read<RoutingDetailsBloc>().add(
            const RoutingDetailsEvent.addRouting(),
          );
}
