import 'package:flutter/cupertino.dart';
import 'package:vpn/common/error/model/enum/presentation_field_name.dart';
import 'package:vpn/common/error/model/presentation_field.dart';

abstract class ValidationUtils {
  static const plainRawRegex = r'^(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(?:\.(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}$';

  static const domainRawRegex =
      r'^(?:localhost|'
      r'(?:[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?\.)+'
      r'(?:[A-Za-z]{2,63}|xn--[A-Za-z0-9-]{2,58}))\.?$';

  static const dotRawRegex =
      r'^tls://'
      r'(?:localhost|'
      r'(?:[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?\.)+'
      r'(?:[A-Za-z]{2,63}|xn--[A-Za-z0-9-]{2,58}))$';

  // DoH (https://host[/…], обычно /dns-query)
  static const dohRawRegex =
      r'^https://'
      r'(?:localhost|'
      r'(?:[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?\.)+'
      r'(?:[A-Za-z]{2,63}|xn--[A-Za-z0-9-]{2,58}))'
      r'(?:/[^ \t\r\n]*)?$';

  // DoQ (quic://host)
  static const quicRawRegex =
      r'^quic://'
      r'(?:localhost|'
      r'(?:[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?\.)+'
      r'(?:[A-Za-z]{2,63}|xn--[A-Za-z0-9-]{2,58}))$';

  // DoH over HTTP/3 (https://host[/…]#h3)
  static const h3RawRegex =
      r'^https://'
      r'(?:localhost|'
      r'(?:[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?\.)+'
      r'(?:[A-Za-z]{2,63}|xn--[A-Za-z0-9-]{2,58}))'
      r'(?:/[^ \t\r\n]*)?#h3$';

  static String? getErrorString(
    BuildContext context,
    List<PresentationField> fieldErrors,
    PresentationFieldName fieldName,
  ) => fieldErrors.where((element) => element.fieldName == fieldName).firstOrNull?.toLocalizedString(context);
}
