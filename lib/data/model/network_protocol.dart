enum NetworkProtocol {
  tcp;

  @override
  String toString() => switch (this) {
      NetworkProtocol.tcp => 'TCP',
    };
}
