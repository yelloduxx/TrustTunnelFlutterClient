// You have generated a new plugin project without specifying the `--platforms`
// flag. A plugin project with no platform support was generated. To add a
// platform, run `flutter create -t plugin --platforms <platforms> .` under the
// same directory. You can also find a detailed instruction on how to add
// platforms in the `pubspec.yaml` at
// https://flutter.dev/docs/development/packages-and-plugins/developing-packages#plugin-platforms.

import 'package:flutter/services.dart';
import 'package:vpn_plugin/platform_api.g.dart';

class VpnPlugin {
  VpnPlugin({EventChannel? channel})
    : _api = IVpnManager(),
      _channel = channel ?? const EventChannel('vpn_plugin_event_channel');

  final IVpnManager _api;
  final EventChannel _channel;

  Future<VpnManagerState> getCurrentState() => _api.getCurrentState();

  Future<void> start({required Server server, required RoutingProfile routingProfile}) {
    final vpnMode = routingProfile.defaultMode == RoutingMode.vpn ? 'general' : 'selective';
    final exclusions = vpnMode == 'general' ? routingProfile.bypassRules : routingProfile.vpnRules;
    final dnsUpstreams = server.dnsServers.map((dns) => '$dns:53').toList();
    final isIpv6 = server.ipAddress.contains(':');
    final addresses = isIpv6 ? ['[${server.ipAddress}]:443'] : ['${server.ipAddress}:443'];
    final upstreamProtocol = server.vpnProtocol == VpnProtocol.http2 ? 'http2' : 'http3';
    final certificateValue =
        server.certificatePem != null && server.certificatePem.isNotEmpty ? '"""\n${server.certificatePem}\n"""' : '""';

    var exclusionsValue = exclusions.map((e) => '"$e"').join(', ');
    if (exclusionsValue.isEmpty) {
      exclusionsValue = '""';
    }
    final config = '''
# Logging level [info, debug, trace]
loglevel = "debug"

# VPN mode.
# Defines client connections routing policy:
# * general: route through a VPN endpoint all connections except ones which destinations are in exclusions,
# * selective: route through a VPN endpoint only the connections which destinations are in exclusions.
vpn_mode = "$vpnMode"

# When disabled, all connection requests are routed directly to target hosts
# in case connection to VPN endpoint is lost. This helps not to break an
# Internet connection if user has poor connectivity to an endpoint.
# When enabled, incoming connection requests which should be routed through
# an endpoint will not be routed directly in that case.
killswitch_enabled = true

# When enabled, a post-quantum group may be used for key exchange
# in TLS handshakes initiated by the VPN client.
post_quantum_group_enabled = false

# Domains and addresses which should be routed in a special manner.
# Supported syntax:
#   * domain name
#     * if starts with "*.", any subdomain of the domain will be matched including
#       www-subdomain, but not the domain itself (e.g., `*.example.com`  will match
#       `sub.example.com` , `sub.sub.example.com` , `www.example.com` , but not `example.com` )
#     * if starts with "www." or it's just a domain name, the domain itself and its
#       www-subdomain will be matched (e.g. `example.com`  and `www.example.com`  will
#       match `example.com`  `www.example.com` , but not `sub.example.com` )
#   * ip address
#     * recognized formats are:
#       * [IPv6Address]:port
#       * [IPv6Address]
#       * IPv6Address
#       * IPv4Address:port
#       * IPv4Address
#     * if port is not specified, any port will be matched
#   * CIDR range
#     * recognized formats are:
#       * IPv4Address/mask
#       * IPv6Address/mask
exclusions = [$exclusionsValue]

# DNS upstreams.
# If specified, the library intercepts and routes plain DNS queries
# going through the endpoint to the DNS resolvers.
# One of the following kinds:
#   * 8.8.8.8:53 -- plain DNS
#   * tcp://8.8.8.8:53 -- plain DNS over TCP
#   * tls://1.1.1.1 -- DNS-over-TLS
#   * https://dns.adguard.com/dns-query -- DNS-over-HTTPS
#   * sdns://... -- DNS stamp (see https://dnscrypt.info/stamps-specifications)
#   * quic://dns.adguard.com:8853 -- DNS-over-QUIC
dns_upstreams = [${dnsUpstreams.map((d) => '"$d"').join(', ')}]

# The set of endpoint connection settings
[endpoint]
# Endpoint host name, used for TLS session establishment
hostname = "${server.domain}"
# Endpoint addresses.
# The exact address is selected by the pinger. Absence of IPv6 addresses in
# the list makes the VPN client reject IPv6 connections which must be routed
# through the endpoint with unreachable code.
addresses = [${addresses.map((a) => '"$a"').join(', ')}]
# Whether IPv6 traffic can be routed through the endpoint
has_ipv6 = ${server.hasIpv6}
# Username for authorization
username = "${server.login}"
# Password for authorization
password = "${server.password}"
# TLS client random prefix (hex string)
client_random = "${server.tlsClientRandomPrefix ?? ''}"
# Skip the endpoint certificate verification?
# That is, any certificate is accepted with this one set to true.
skip_verification = false
# Endpoint certificate in PEM format.
# If not specified, the endpoint certificate is verified using the system storage.
certificate = $certificateValue
# Protocol to be used to communicate with the endpoint [http2, http3]
upstream_protocol = "$upstreamProtocol"
# Fallback protocol to be used in case the main one fails [<none>, http2, http3]
upstream_fallback_protocol = ""
# Is anti-DPI measures should be enabled
anti_dpi = false


# Defines the way to listen to network traffic by the kind of the nested table.
# Possible types:
#   * socks: SOCKS5 proxy with UDP support,
#   * tun: TUN device.
[listener]

[listener.tun]
# Name of the interface used for connections made by the VPN client.
# On Linux and Windows, it is detected automatically if not specified.
# On macOS, it defaults to `en0`  if not specified.
# On Windows, an interface index as shown by `route print` , written as a string, may be used instead of a name.
# bound_if = "en0"
# Routes in CIDR notation to set to the virtual interface
included_routes = ["0.0.0.0/0", "2000::/3"]
# Routes in CIDR notation to exclude from routing through the virtual interface
excluded_routes = ["0.0.0.0/8", "10.0.0.0/8", "169.254.0.0/16", "172.16.0.0/12", "192.168.0.0/16", "224.0.0.0/3"]
# MTU size on the interface
mtu_size = 1500

# [listener.socks]
# # IP address to bind the listener to
# address = "127.0.0.1:1080"
# # Username for authentication if desired
# username = ""
# # Password for authentication if desired
# password = ""
''';

    return _api.start(config: config);
  }

  Future<void> stop() => _api.stop();

  Stream<VpnManagerState> get states => _channel.receiveBroadcastStream().map(_mapNativeToState).distinct();

  static VpnManagerState _mapNativeToState(dynamic raw) {
    if (raw is int) {
      switch (raw) {
        case 0:
          return VpnManagerState.disconnected;
        case 1:
          return VpnManagerState.connecting;
        case 2:
          return VpnManagerState.connected;
        case 3:
          return VpnManagerState.waitingForRecovery;
        case 4:
          return VpnManagerState.recovering;
        case 5:
          return VpnManagerState.waitingForNetwork;
      }
    }

    return VpnManagerState.disconnected;
  }
}
