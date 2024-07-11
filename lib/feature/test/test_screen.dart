import 'package:flutter/material.dart';
import 'package:vpn_plugin/api.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final _api = PlatformApi();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Test widget'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: _getPlatformType,
            child: const Text('Get platform version'),
          ),
        ),
      );

  Future<void> _getPlatformType() async {
    final request = GetPlatformTypeRequest()..testParam = 42;
    final response = await _api.getPlatformType(request);
    debugPrint(response.platformType);
  }
}
