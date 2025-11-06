import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vpn/common/error/model/enum/presentation_field_name.dart';
import 'package:vpn/common/extensions/context_extensions.dart';
import 'package:vpn/common/extensions/enum_extensions.dart';
import 'package:vpn/common/localization/localization.dart';
import 'package:vpn/common/utils/validation_utils.dart';
import 'package:vpn/data/model/routing_profile.dart';
import 'package:vpn/data/model/vpn_protocol.dart';
import 'package:vpn/feature/server/server_details/bloc/server_details_bloc.dart';
import 'package:vpn/view/inputs/custom_text_field.dart';
import 'package:vpn/view/menu/custom_dropdown_menu.dart';

class ServerDetailsForm extends StatefulWidget {
  const ServerDetailsForm({super.key});

  @override
  State<ServerDetailsForm> createState() => _ServerDetailsFormState();
}

class _ServerDetailsFormState extends State<ServerDetailsForm> {
  @override
  Widget build(BuildContext context) {
    const separator32 = SizedBox(height: 32);
    return BlocBuilder<ServerDetailsBloc, ServerDetailsState>(
      buildWhen: (prev, curr) => prev.action == curr.action,
      builder: (context, state) => ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        shrinkWrap: true,
        children: [
          CustomTextField(
            value: state.data.serverName,
            label: context.ln.serverName,
            hint: context.ln.serverName,
            onChanged: (serverName) => _onDataChanged(
              context,
              serverName: serverName,
            ),
            error: ValidationUtils.getErrorString(
              context,
              state.fieldErrors,
              PresentationFieldName.serverName,
            ),
          ),
          separator32,
          CustomTextField(
            value: state.data.ipAddress,
            label: context.ln.enterIpAddressLabel,
            hint: context.ln.enterIpAddressHint,
            onChanged: (ipAddress) => _onDataChanged(
              context,
              ipAddress: ipAddress,
            ),
            error: ValidationUtils.getErrorString(
              context,
              state.fieldErrors,
              PresentationFieldName.ipAddress,
            ),
          ),
          separator32,
          CustomTextField(
            value: state.data.domain,
            label: context.ln.enterDomainLabel,
            hint: context.ln.enterDomainHint,
            onChanged: (domain) => _onDataChanged(
              context,
              domain: domain,
            ),
            error: ValidationUtils.getErrorString(
              context,
              state.fieldErrors,
              PresentationFieldName.domain,
            ),
          ),
          separator32,
          CustomTextField(
            value: state.data.username,
            label: context.ln.username,
            hint: context.ln.enterUsername,
            onChanged: (username) => _onDataChanged(
              context,
              username: username,
            ),
            error: ValidationUtils.getErrorString(
              context,
              state.fieldErrors,
              PresentationFieldName.userName,
            ),
          ),
          separator32,
          CustomTextField(
            value: state.data.password,
            label: context.ln.password,
            hint: context.ln.enterPassword,
            onChanged: (password) => _onDataChanged(
              context,
              password: password,
            ),
            error: ValidationUtils.getErrorString(
              context,
              state.fieldErrors,
              PresentationFieldName.password,
            ),
          ),
          separator32,
          CustomDropdownMenu<VpnProtocol>.expanded(
            value: state.data.protocol,
            values: VpnProtocol.values,
            toText: (value) => value.stringValue,
            labelText: context.ln.protocol,
            onChanged: (protocol) => _onDataChanged(
              context,
              protocol: protocol,
            ),
          ),
          separator32,
          CustomDropdownMenu<RoutingProfile>.expanded(
            value: state.selectedRoutingProfile,
            values: state.availableRoutingProfiles,
            toText: (value) => value.name,
            labelText: context.ln.routingProfile,
            onChanged: (profile) => _onDataChanged(
              context,
              routingProfileId: profile?.id,
            ),
          ),
          const SizedBox(
            height: 27,
          ),
          Text(
            context.ln.dnsServers,
            style: context.textTheme.bodyLarge,
          ),
          const SizedBox(
            height: 11,
          ),
          CustomTextField(
            value: state.data.dnsServers.join('\n'),
            hint: context.ln.enterDnsServerHint,
            label: context.ln.enterDnsServerLabel,
            minLines: 1,
            maxLines: 4,
            onChanged: (dns) => _onDataChanged(
              context,
              dnsServers: dns.trim().split('\n'),
            ),
            error: ValidationUtils.getErrorString(
              context,
              state.fieldErrors,
              PresentationFieldName.dnsServers,
            ),
          ),
        ],
      ),
    );
  }

  void _onDataChanged(
    BuildContext context, {
    String? serverName,
    String? ipAddress,
    String? domain,
    String? username,
    String? password,
    VpnProtocol? protocol,
    int? routingProfileId,
    List<String>? dnsServers,
  }) => context.read<ServerDetailsBloc>().add(
    ServerDetailsEvent.dataChanged(
      serverName: serverName,
      ipAddress: ipAddress,
      domain: domain,
      username: username,
      password: password,
      protocol: protocol,
      routingProfileId: routingProfileId,
      dnsServers: dnsServers,
    ),
  );
}
