import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vpn/common/extensions/context_extensions.dart';
import 'package:vpn/common/extensions/enum_extensions.dart';
import 'package:vpn/common/localization/localization.dart';
import 'package:vpn/data/model/routing_mode.dart';
import 'package:vpn/feature/routing/routing_details/domain/routing_spell_check_service.dart';
import 'package:vpn/feature/routing/routing_details/bloc/routing_details_bloc.dart';
import 'package:vpn/view/inputs/custom_text_field.dart';

class RoutingDetailsForm extends StatelessWidget {
  const RoutingDetailsForm({super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16.0),
    child: BlocBuilder<RoutingDetailsBloc, RoutingDetailsState>(
      buildWhen: (prev, curr) => prev.action == curr.action,
      builder: (context, state) => context.isMobileBreakpoint
          ? TabBarView(
              children: [
                _bypassRulesTextField(context, state),
                _vpnRulesTextField(context, state),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: _bypassRulesTextField(context, state, showLabel: true),
                ),
                const SizedBox(width: 16),
                Flexible(
                  child: _vpnRulesTextField(context, state, showLabel: true),
                ),
              ],
            ),
    ),
  );

  CustomTextField _vpnRulesTextField(
    BuildContext context,
    RoutingDetailsState state, {
    bool showLabel = false,
  }) => CustomTextField(
    label: showLabel ? RoutingMode.vpn.stringValue : null,
    value: state.data.vpnRules.join('\n'),
    hint: context.ln.enterRulesHint,
    spellCheckService: RoutingSpellCheckService(
      onChecked: (spellValid) => _onDataChanged(
        context,
        hasInvalidRules: !spellValid,
      ),
    ),
    minLines: 40,
    maxLines: 40,
    showClearButton: false,
    onChanged: (vpnRules) => _onDataChanged(
      context,
      vpnRules: vpnRules.trim().split('\n'),
    ),
  );

  CustomTextField _bypassRulesTextField(
    BuildContext context,
    RoutingDetailsState state, {
    bool showLabel = false,
  }) => CustomTextField(
    label: showLabel ? RoutingMode.bypass.stringValue : null,
    value: state.data.bypassRules.join('\n'),
    hint: context.ln.enterRulesHint,
    minLines: 40,
    maxLines: 40,
    spellCheckService: RoutingSpellCheckService(
      onChecked: (spellValid) => _onDataChanged(
        context,
        hasInvalidRules: !spellValid,
      ),
    ),
    showClearButton: false,
    onChanged: (bypassRules) => _onDataChanged(
      context,
      bypassRules: bypassRules.trim().split('\n'),
    ),
  );

  void _onDataChanged(
    BuildContext context, {
    RoutingMode? mode,
    List<String>? vpnRules,
    List<String>? bypassRules,
    bool? hasInvalidRules,
  }) => context.read<RoutingDetailsBloc>().add(
    RoutingDetailsEvent.dataChanged(
      defaultMode: mode,
      vpnRules: vpnRules,
      bypassRules: bypassRules,
      hasInvalidRules: hasInvalidRules,
    ),
  );
}
