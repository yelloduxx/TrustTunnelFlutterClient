enum ConnectionProtocol {
  tcp('tcp'),
  udp('udp');

  final String value;

  const ConnectionProtocol(this.value);
}
