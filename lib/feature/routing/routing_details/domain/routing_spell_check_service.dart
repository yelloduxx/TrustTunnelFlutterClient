import 'package:flutter/services.dart';
import 'package:vpn/common/utils/validation_utils.dart';

class RoutingSpellCheckService implements SpellCheckService {
  final ValueChanged<bool> onChecked;

  RoutingSpellCheckService({required this.onChecked});

  final _ipv4WithPort = RegExp(
    r'^(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)'
    r'(?:\.(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}'
    r':(?:6553[0-5]|655[0-2]\d|65[0-4]\d{2}|6[0-4]\d{3}|[1-5]\d{4}|[1-9]\d{0,3})$',
  );

  final _ipv4Cidr = RegExp(
    r'^(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)'
    r'(?:\.(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}'
    r'/(?:3[0-2]|[12]?\d)$',
  );

  final _plainIp = RegExp(ValidationUtils.plainRawRegex);

  final _domain = RegExp(ValidationUtils.domainRawRegex);

  final _tokenizer = RegExp(r'\S+');

  bool _isValidToken(String s) =>
      _plainIp.hasMatch(s) || _ipv4WithPort.hasMatch(s) || _ipv4Cidr.hasMatch(s) || _domain.hasMatch(s);

  @override
  Future<List<SuggestionSpan>?> fetchSpellCheckSuggestions(_, String text) async {
    final invalidSpans = <SuggestionSpan>[];

    for (final m in _tokenizer.allMatches(text)) {
      final token = m.group(0)!;

      if (_isValidToken(token)) continue;

      invalidSpans.add(
        SuggestionSpan(
          TextRange(start: m.start, end: (m.end - 1).clamp(0, m.end)),
          const [],
        ),
      );
    }

    onChecked(invalidSpans.isEmpty);

    return invalidSpans;
  }
}
