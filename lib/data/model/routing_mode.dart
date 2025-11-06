enum RoutingMode {
  bypass._(1),
  vpn._(2);

  final int value;

  const RoutingMode._(this.value);
}