import 'package:flutter/material.dart';
import 'package:vpn/view/scaffold_wrapper.dart';

class RoutersScreen extends StatelessWidget {
  const RoutersScreen({super.key});

  @override
  Widget build(BuildContext context) => ScaffoldWrapper(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Routers'),
          ),
          body: const Center(
            child: Text('Routers'),
          ),
        ),
      );
}
