import 'package:meta/meta.dart';

@immutable
class HappRoutingImportResult {
  final int profileId;
  final String profileName;
  final bool reusedExistingProfile;
  final int unsupportedBlockRules;

  const HappRoutingImportResult({
    required this.profileId,
    required this.profileName,
    required this.reusedExistingProfile,
    required this.unsupportedBlockRules,
  });
}
