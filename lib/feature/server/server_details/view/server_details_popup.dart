import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vpn/common/extensions/context_extensions.dart';
import 'package:vpn/feature/server/server_details/bloc/server_details_bloc.dart';
import 'package:vpn/feature/server/server_details/view/widget/server_details_view.dart';
import 'package:vpn/view/scaffold_wrapper.dart';

class ServerDetailsPopUp extends StatelessWidget {
  final int? serverId;

  const ServerDetailsPopUp({super.key, this.serverId});

  @override
  Widget build(BuildContext context) => ScaffoldWrapper(
    child: BlocProvider<ServerDetailsBloc>(
      create: (context) => context.blocFactory.serverDetailsBloc(
        serverId: serverId,
      )..add(const ServerDetailsEvent.fetch()),
      child: const ServerDetailsView(),
    ),
  );
}
