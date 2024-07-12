import 'package:flutter/material.dart';
import 'package:vpn/common/extensions/context_extensions.dart';
import 'package:vpn/feature/servers/server_details/server_details_screen.dart';
import 'package:vpn/view/scaffold_wrapper.dart';

class ServersScreen extends StatelessWidget {
  const ServersScreen({super.key});

  @override
  Widget build(BuildContext context) => ScaffoldWrapper(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Servers'),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              context.push(
                const ServerDetailsScreen(),
              );
            },
            backgroundColor: Colors.green,
            child: const Icon(Icons.add),
          ),
        ),
      );
}
