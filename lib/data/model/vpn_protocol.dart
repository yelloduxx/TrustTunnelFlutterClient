enum VpnProtocol {
  quic._(1),
  http2._(2);

  final int value;
  
  const VpnProtocol._(this.value);
}
