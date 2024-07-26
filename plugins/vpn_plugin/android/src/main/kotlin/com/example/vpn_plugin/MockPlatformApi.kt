package com.example.vpn_plugin

import io.flutter.plugin.common.EventChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.cancel
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import java.io.Closeable

class MockPlatformApi: PlatformApi, EventChannel.StreamHandler, Closeable {
    private val scope = CoroutineScope(Dispatchers.Main)
    private var job: Job? = null
    private var eventSink: EventChannel.EventSink? = null
    private var servers: MutableList<Server> = mutableListOf()
    private var requests = mutableListOf<VpnRequest>()
    private var selectedServerId: Long? = null
    private var state: VpnManagerState = VpnManagerState.DISCONNECTED
    private var excludedRoutes = ""
    private var routingProfiles: MutableList<RoutingProfile> = mutableListOf()


    init {
        for (i in 1..10) {
            servers.add(Server(
                id = i.toLong(),
                name = "Server $i",
                ipAddress = "192.168.1.$i",
                domain = "server$i.com",
                login = "login$i",
                password = "password$i",
                vpnProtocol = VpnProtocol.HTTP2,
                routingProfileId = 0,
                dnsServers = listOf("1.1.1.$i", "123.123.123.$i"),
            ))
        }
        for (i in 1..20) {
            requests.add(VpnRequest(
                time = "01.07.2024 18.48.11",
                vpnProtocol = VpnProtocol.HTTP2,
                decision = RoutingMode.BYPASS,
                sourceIpAddress = "192.168.1.$i",
                destinationIpAddress = "192.168.1.$i",
                sourcePort = "80",
                destinationPort = "80",
                domain = "server$i.com",
            ))
        }
        for (i in 0..20) {
            routingProfiles.add(RoutingProfile(
                id = i.toLong(),
                name = "Profile $i",
                defaultMode = RoutingMode.BYPASS,
                bypassRules = listOf("bypass rule 1", "bypass rule2 "),
                vpnRules = listOf("vpn rule 1", "vpn rule2 "),
            ))
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events!!
        onStateChanged()
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    override fun getAllServers(): List<Server> {
        return servers
    }

    override fun getServerById(id: Long): Server {
        return servers.find { it.id == id }!!
    }

    override fun addServer(request: AddServerRequest): Server {
        val errors = mutableListOf<PlatformFieldError>()
        if (request.name.length == 1) {
            errors.add(PlatformFieldError(
                code = PlatformFieldErrorCode.ALREADY_EXISTS,
                fieldName = PlatformFieldName.SERVER_NAME,))
        }
        if (request.ipAddress.length == 1) {
            errors.add(PlatformFieldError(
                code = PlatformFieldErrorCode.FIELD_WRONG_VALUE,
                fieldName = PlatformFieldName.IP_ADDRESS,))
        }
        if (request.domain.length == 1) {
            errors.add(PlatformFieldError(
                code = PlatformFieldErrorCode.FIELD_WRONG_VALUE,
                fieldName = PlatformFieldName.DOMAIN,))
        }
        if (request.dnsServers.size == 2) {
            errors.add(PlatformFieldError(
                code = PlatformFieldErrorCode.FIELD_WRONG_VALUE,
                fieldName = PlatformFieldName.DNS_SERVERS,))
        }

        if (errors.isNotEmpty()) {
            throw FlutterError(
                code = "",
                message = null,
                details = PlatformErrorResponse(
                    fieldErrors = errors,
                )
            )
        }

        val server = Server(
            id = servers.size.toLong() + 1,
            name = request.name,
            ipAddress = request.ipAddress,
            domain = request.domain,
            login = request.login,
            password = request.password,
            vpnProtocol = request.vpnProtocol,
            routingProfileId = request.routingProfileId,
            dnsServers = request.dnsServers,
        )
        servers.add(server)

        return server
    }

    override fun updateServer(request: UpdateServerRequest): Server {
        val index = servers.indexOfFirst { it.id == request.id }
        if (index == -1) {
            throw FlutterError(
                    code = "",
                    message = null,
            )
        }

        val updatedServer = Server(
                id = request.id,
                name = request.name,
                ipAddress = request.ipAddress,
                domain = request.domain,
                login = request.login,
                password = request.password,
                vpnProtocol = request.vpnProtocol,
                routingProfileId = request.routingProfileId,
                dnsServers = request.dnsServers,
        )
        servers[index] = updatedServer

        return updatedServer
    }

    override fun removeServer(id: Long) {
        servers = servers.filter { it.id != id }.toMutableList()
    }

    override fun getSelectedServerId(): Long? {
        return selectedServerId
    }

    override fun setSelectedServerId(id: Long) {
        selectedServerId = id
    }

    override fun getAllRoutingProfiles(): List<RoutingProfile> {
        return routingProfiles
    }

    override fun getRoutingProfileById(id: Long): RoutingProfile {
        return routingProfiles.find { it.id == id }!!
    }

    override fun addRoutingProfile(request: AddRoutingProfileRequest): RoutingProfile {
        val routingProfile = RoutingProfile(
            id = routingProfiles.size.toLong() + 1,
            name = request.name,
            defaultMode = request.defaultMode,
            bypassRules = request.bypassRules,
            vpnRules = request.vpnRules,
        )
        routingProfiles.add(routingProfile)

        return routingProfile
    }

    override fun updateRoutingProfile(request: UpdateRoutingProfileRequest): RoutingProfile {
        val index = routingProfiles.indexOfFirst { it.id == request.id }
        if (index == -1) {
            throw FlutterError(
                code = "",
                message = null,
            )
        }

        val existingRoutingProfile = routingProfiles[index]
        val updatedRoutingProfile = RoutingProfile(
            id = request.id,
            name = existingRoutingProfile.name,
            defaultMode = request.defaultMode,
            bypassRules = request.bypassRules,
            vpnRules = request.vpnRules,
        )
        routingProfiles[index] = updatedRoutingProfile

        return updatedRoutingProfile
    }

    override fun setRoutingProfileName(id: Long, name: String) : RoutingProfile {
        val index = routingProfiles.indexOfFirst { it.id == id }
        if (index == -1) {
            throw FlutterError(
                    code = "",
                    message = null,
            )
        }

        val existingRoutingProfile = routingProfiles[index]
        val updatedRoutingProfile = RoutingProfile(
                id = id,
                name = name,
                defaultMode = existingRoutingProfile.defaultMode,
                bypassRules = existingRoutingProfile.bypassRules,
                vpnRules = existingRoutingProfile.vpnRules,
        )
        routingProfiles[index] = updatedRoutingProfile

        return updatedRoutingProfile
    }

    override fun removeRoutingProfile(id: Long) {
        routingProfiles = routingProfiles.filter { it.id != id }.toMutableList()
    }

    override fun getAllRequests(): List<VpnRequest> {
        return requests
    }

    override fun setExcludedRoutes(routes: String) {
        excludedRoutes = routes
    }

    override fun getExcludedRoutes(): String {
        return excludedRoutes
    }

    override fun start() {
        job?.cancel()
        state = VpnManagerState.CONNECTING
        onStateChanged()
        job = scope.launch {
            delay(3000)
            state = VpnManagerState.CONNECTED
            onStateChanged()
        }
    }

    override fun stop() {
        job?.cancel()
        state = VpnManagerState.DISCONNECTED
        onStateChanged()
    }

    override fun errorStub(error: PlatformErrorResponse) {
        TODO("Not yet implemented")
    }

    override fun close() {
        scope.cancel()
    }

    private fun onStateChanged() {
        eventSink?.success(state.ordinal)
    }

}