import 'package:flutter/material.dart';

class ServerDetailsScreen extends StatelessWidget {
  const ServerDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Server details'),
        ),
        body: const Center(
          child: Text('Server details'),
        ),
      );
}
