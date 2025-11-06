import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/platform_api.g.dart',
    dartOptions: DartOptions(),
    cppOptions: CppOptions(namespace: 'vpn_plugin'),
    cppHeaderOut: 'windows/runner/platform_api.g.h',
    cppSourceOut: 'windows/runner/platform_api.g.cpp',
    kotlinOut: 'android/src/main/kotlin/com/adguard/trusttunnel/vpn_plugin/PlatformApi.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'com.adguard.trusttunnel.vpn_plugin',
    ),
    swiftOptions: SwiftOptions(),
  ),
)
@HostApi()
abstract class IVpnManager {
  @TaskQueue(type: TaskQueueType.serialBackgroundThread)
  void start({required String config});

  @TaskQueue(type: TaskQueueType.serialBackgroundThread)
  void stop();

  VpnManagerState getCurrentState();
}

enum RoutingMode {
  bypass,
  vpn,
}

enum PlatformErrorCode {
  unknown,
}

enum PlatformFieldErrorCode {
  fieldWrongValue,
  alreadyExists,
}

enum PlatformFieldName {
  ipAddress,
  domain,
  serverName,
  dnsServers,
}

class PlatformErrorResponse {
  final PlatformErrorCode? code;
  final List<PlatformFieldError?>? fieldErrors;

  const PlatformErrorResponse({
    this.code,
    this.fieldErrors,
  });
}

class PlatformFieldError {
  final PlatformFieldErrorCode code;
  final PlatformFieldName fieldName;

  const PlatformFieldError({
    required this.code,
    required this.fieldName,
  });
}

class RoutingProfile {
  final int id; // deprecated
  final String name;
  final RoutingMode defaultMode;
  final List<String> bypassRules;
  final List<String> vpnRules;

  const RoutingProfile({
    required this.id,
    required this.name,
    required this.defaultMode,
    required this.bypassRules,
    required this.vpnRules,
  });
}

class Server {
  final int id; // deprecated
  final String ipAddress;
  final String domain;
  final String login;
  final String password;
  final List<String> dnsServers;
  final VpnProtocol vpnProtocol;
  final int routingProfileId;
  final String tlsClientRandomPrefix;
  final bool hasIpv6;
  final String certificatePem;

  const Server({
    required this.id,
    required this.ipAddress,
    required this.domain,
    required this.login,
    required this.password,
    required this.vpnProtocol,
    required this.routingProfileId,
    required this.dnsServers,
    required this.tlsClientRandomPrefix,
    required this.hasIpv6,
    required this.certificatePem,
  });
}

enum VpnManagerState {
  disconnected,
  connecting,
  connected,
  waitingForRecovery,
  recovering,
  waitingForNetwork,
}

enum VpnProtocol {
  quic,
  http2;

  const VpnProtocol();
}

/////////////////// DEPRECATED ZONE //////////////////////
@HostApi()
abstract class IStorageManager {
  void setExcludedRoutes(String routes);

  void setRoutingProfiles(List<RoutingProfile> profiles);

  void setSelectedServerId(int id);

  void setServers(List<Server> servers);

  List<VpnRequest> getAllRequests();

  String getExcludedRoutes();

  List<RoutingProfile> getRoutingProfiles();

  int? getSelectedServerId();

  List<Server> getAllServers();
}

@HostApi()
abstract class ServersManager {
  AddNewServerResult addNewServer({
    required String name,
    required String ipAddress,
    required String domain,
    required String username,
    required String password,
    required VpnProtocol protocolName,
    required int routingProfileId,
    required String dnsServers,
  });

  List<Server> getAllServers();

  AddNewServerResult setNewServer({
    required int id,
    required String name,
    required String ipAddress,
    required String domain,
    required String username,
    required String password,
    required VpnProtocol protocolName,
    required int routingProfileId,
    required String dnsServers,
  });

  void setSelectedServerId(int id);

  void removeServer(int id);
}

@HostApi()
abstract class RoutingProfilesManager {
  void addNewProfile();

  List<RoutingProfile> getAllProfiles();

  void setDefaultRoutingMode({required int id, required RoutingMode mode});

  void setProfileName({required int id, required String name});

  void setRules({required int id, required RoutingMode mode, required String rules});

  void removeAllRules(int id);
}

enum AddNewServerResult {
  ok,
  ipAddressIncorrect,
  domainIncorrect,
  usernameIncorrect,
  passwordIncorrect,
  dnsServersIncorrect,
}

class VpnRequest {
  // TODO: Make it DateTime with parsing options
  // Konstantin Gorynin <k.gorynin@adguard.com>, 22 August 2025
  final String zonedDateTime;
  final String protocolName;
  final RoutingMode decision;
  final String sourceIpAddress;
  final String destinationIpAddress;
  final String? sourcePort;
  final String? destinationPort;
  final String? domain;

  const VpnRequest({
    required this.zonedDateTime,
    required this.protocolName,
    required this.decision,
    required this.sourceIpAddress,
    required this.destinationIpAddress,
    this.sourcePort,
    this.destinationPort,
    this.domain,
  });
}
