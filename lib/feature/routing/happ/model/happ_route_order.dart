import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:trusttunnel/feature/routing/happ/model/happ_outbound.dart';

@immutable
class HappRouteOrder {
  static const fallback = HappRouteOrder._([
    HappOutbound.block,
    HappOutbound.proxy,
    HappOutbound.direct,
  ]);

  final List<HappOutbound> values;

  const HappRouteOrder._(this.values);

  factory HappRouteOrder.parse(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return fallback;
    }

    final items = raw
        .split(RegExp(r'[,\s\-]+'))
        .map((item) => HappOutbound.tryParse(item))
        .whereType<HappOutbound>()
        .toList();

    if (items.isEmpty) {
      return fallback;
    }

    final uniq = <HappOutbound>[];
    for (final outbound in items) {
      if (!uniq.contains(outbound)) {
        uniq.add(outbound);
      }
    }

    for (final outbound in fallback.values) {
      if (!uniq.contains(outbound)) {
        uniq.add(outbound);
      }
    }

    return HappRouteOrder._(uniq);
  }

  String serialize() => values.map((item) => item.value).join(',');

  @override
  int get hashCode => Object.hashAll(values);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is HappRouteOrder && listEquals(values, other.values);
}
