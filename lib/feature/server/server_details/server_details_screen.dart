import 'package:flutter/material.dart';
import 'package:vpn/view/scaffold_wrapper.dart';

class ServerDetailsScreen extends StatelessWidget {
  const ServerDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) => ScaffoldWrapper(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Server details'),
          ),
          body: const Center(
            child: Text('Server details'),
          ),
        ),
      );
}
