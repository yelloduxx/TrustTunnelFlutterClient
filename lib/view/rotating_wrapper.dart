import 'package:flutter/material.dart';

class RotatingWidget extends StatefulWidget {
  final Duration duration;
  final Widget child;

  const RotatingWidget({
    super.key,
    required this.duration,
    required this.child,
  });

  @override
  State<RotatingWidget> createState() => _RotatingWidgetState();
}

class _RotatingWidgetState extends State<RotatingWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();
  }

  @override
  Widget build(BuildContext context) => RotationTransition(
    turns: _controller,
    child: widget.child,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
