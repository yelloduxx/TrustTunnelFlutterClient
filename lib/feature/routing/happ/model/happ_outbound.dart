enum HappOutbound {
  proxy('proxy'),
  direct('direct'),
  block('block');

  final String value;

  const HappOutbound(this.value);

  static HappOutbound? tryParse(String raw) {
    final normalized = raw.trim().toLowerCase();

    return switch (normalized) {
      'proxy' => HappOutbound.proxy,
      'direct' => HappOutbound.direct,
      'block' => HappOutbound.block,
      _ => null,
    };
  }
}
