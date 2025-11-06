
import UIKit
import Flutter

public class VpnPlugin: NSObject, FlutterPlugin {
    private static var vpnApi: IVpnManagerImpl?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let messenger = registrar.messenger()

        let storage = MockStorage()

        // TODO: Make separated plugin initialization
        // Konstantin Gorynin <k.gorynin@adguard.com>, 25 August 2025
        // Setup all platform managers
        let vpnImpl = IVpnManagerImpl()
        IVpnManagerSetup.setUp(binaryMessenger: messenger, api: vpnImpl)

        let storageManagerImpl = StorageManagerImpl(storage: storage)
        IStorageManagerSetup.setUp(binaryMessenger: messenger, api: storageManagerImpl)

        let serversManagerImpl = ServersManagerImpl(storage: storage)
        ServersManagerSetup.setUp(binaryMessenger: messenger, api: serversManagerImpl)

        let routingProfilesManagerImpl = RoutingProfilesManagerImpl(storage: storage)
        RoutingProfilesManagerSetup.setUp(binaryMessenger: messenger, api: routingProfilesManagerImpl)

        let events = FlutterEventChannel(name: "vpn_plugin_event_channel", binaryMessenger: messenger)
        events.setStreamHandler(vpnImpl)

        self.vpnApi = vpnImpl
    }
}

// MARK: - IVpnManager mock + EventChannel

final class IVpnManagerImpl: NSObject, IVpnManager, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?

    private var state: VpnManagerState = .disconnected {
        didSet { emitState(state) }
    }

    // MARK: IVpnManager (Pigeon HostApi)

    func start() throws {
        state = .connecting
        // Эмулируем быстрое успешное подключение
        DispatchQueue.main.async { [weak self] in
            self?.state = .connected
        }
    }

    func stop() throws {
        state = .disconnected
    }

    func getCurrentState() throws -> VpnManagerState {
        return state
    }

    // MARK: FlutterStreamHandler

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        emitState(state)
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }

    private func emitState(_ s: VpnManagerState) {
        eventSink?(s.rawValue)
    }
}

// MARK: - Mock Storage

final class MockStorage {
    var servers: [Server] = []
    var routingProfiles: [RoutingProfile] = []
    var selectedServerId: Int64? = nil
    var excludedRoutes: String = ""
    var vpnState: VpnManagerState = .disconnected
    var requests: [VpnRequest] = []

    init() {
        setupMockData()
    }

    private func setupMockData() {
        // Профили маршрутизации
        routingProfiles = [
            RoutingProfile(
                id: 1,
                name: "Default Profile",
                defaultMode: .vpn,
                bypassRules: ["192.168.1.0/24", "10.0.0.0/8"],
                vpnRules: ["*"]
            ),
            RoutingProfile(
                id: 2,
                name: "Work Profile",
                defaultMode: .bypass,
                bypassRules: ["company.com", "*.internal"],
                vpnRules: ["social.com", "*.entertainment"]
            ),
        ]

        // Серверы
        servers = [
            Server(
                id: 1,
                ipAddress: "192.168.1.100",
                domain: "vpn1.example.com",
                login: "user1",
                password: "password1",
                dnsServers: ["8.8.8.8", "8.8.4.4"],
                vpnProtocol: .quic,
                routingProfileId: 1
            ),
            Server(
                id: 2,
                ipAddress: "10.0.0.50",
                domain: "vpn2.example.com",
                login: "user2",
                password: "password2",
                dnsServers: ["1.1.1.1", "1.0.0.1"],
                vpnProtocol: .http2,
                routingProfileId: 2
            ),
        ]

        selectedServerId = 1
        excludedRoutes = "192.168.0.0/16,10.0.0.0/8"

        // Запросы
        requests = [
            VpnRequest(
                zonedDateTime: "2024-08-22T12:00:00Z",
                protocolName: "HTTPS",
                decision: .vpn,
                sourceIpAddress: "192.168.1.10",
                destinationIpAddress: "8.8.8.8",
                sourcePort: "54321",
                destinationPort: "443",
                domain: "google.com"
            )
        ]
    }

    // MARK: Getters/Setters совместимые с реализациями менеджеров

    var allServers: [Server] {
        get { servers }
        set { servers = newValue }
    }

    var allRoutingProfiles: [RoutingProfile] {
        get { routingProfiles }
        set { routingProfiles = newValue }
    }

    var currentSelectedServerId: Int64? {
        get { selectedServerId }
        set { selectedServerId = newValue }
    }

    var currentExcludedRoutes: String {
        get { excludedRoutes }
        set { excludedRoutes = newValue }
    }

    var currentVpnState: VpnManagerState {
        get { vpnState }
        set { vpnState = newValue }
    }

    var allRequests: [VpnRequest] {
        get { requests }
        set { requests = newValue }
    }
}

// MARK: - Storage Manager

final class StorageManagerImpl: NSObject, IStorageManager {
    private let storage: MockStorage

    init(storage: MockStorage) {
        self.storage = storage
    }

    func setExcludedRoutes(routes: String) throws {
        storage.currentExcludedRoutes = routes
    }

    func setRoutingProfiles(profiles: [RoutingProfile]) throws {
        storage.allRoutingProfiles = profiles
    }

    func setSelectedServerId(id: Int64) throws {
        storage.currentSelectedServerId = id
    }

    func setServers(servers: [Server]) throws {
        storage.allServers = servers
    }

    func getAllRequests() throws -> [VpnRequest] {
        storage.allRequests
    }

    func getExcludedRoutes() throws -> String {
        storage.currentExcludedRoutes
    }

    func getRoutingProfiles() throws -> [RoutingProfile] {
        storage.allRoutingProfiles
    }

    func getSelectedServerId() throws -> Int64? {
        storage.currentSelectedServerId
    }

    func getAllServers() throws -> [Server] {
        storage.allServers
    }
}

// MARK: - Servers Manager

final class ServersManagerImpl: NSObject, ServersManager {
    private let storage: MockStorage

    init(storage: MockStorage) {
        self.storage = storage
    }

    func addNewServer(
        name: String,
        ipAddress: String,
        domain: String,
        username: String,
        password: String,
        protocolName: VpnProtocol,
        routingProfileId: Int64,
        dnsServers: String
    ) throws -> AddNewServerResult {
        // Валидация
        if ipAddress.isEmpty || !isValidIP(ipAddress) { return .ipAddressIncorrect }
        if domain.isEmpty { return .domainIncorrect }
        if username.isEmpty { return .usernameIncorrect }
        if password.isEmpty { return .passwordIncorrect }

        let dnsArray = dnsServers
            .split(separator: ",")
            .map { String($0.trimmingCharacters(in: .whitespaces)) }
            .filter { !$0.isEmpty }

        if dnsArray.isEmpty { return .dnsServersIncorrect }

        let newId = (storage.allServers.map { $0.id }.max() ?? 0) + 1
        let newServer = Server(
            id: newId,
            ipAddress: ipAddress,
            domain: domain,
            login: username,
            password: password,
            dnsServers: dnsArray,
            vpnProtocol: protocolName,
            routingProfileId: routingProfileId
        )

        storage.allServers.append(newServer)
        return .ok
    }

    func getAllServers() throws -> [Server] {
        storage.allServers
    }

    func setNewServer(
        id: Int64,
        name: String,
        ipAddress: String,
        domain: String,
        username: String,
        password: String,
        protocolName: VpnProtocol,
        routingProfileId: Int64,
        dnsServers: String
    ) throws -> AddNewServerResult {
        if ipAddress.isEmpty || !isValidIP(ipAddress) { return .ipAddressIncorrect }
        if domain.isEmpty { return .domainIncorrect }
        if username.isEmpty { return .usernameIncorrect }
        if password.isEmpty { return .passwordIncorrect }

        let dnsArray = dnsServers
            .split(separator: ",")
            .map { String($0.trimmingCharacters(in: .whitespaces)) }
            .filter { !$0.isEmpty }

        if dnsArray.isEmpty { return .dnsServersIncorrect }

        if let index = storage.allServers.firstIndex(where: { $0.id == id }) {
            let updated = Server(
                id: id,
                ipAddress: ipAddress,
                domain: domain,
                login: username,
                password: password,
                dnsServers: dnsArray,
                vpnProtocol: protocolName,
                routingProfileId: routingProfileId
            )
            storage.allServers[index] = updated
        }

        return .ok
    }

    func setSelectedServerId(id: Int64) throws {
        storage.currentSelectedServerId = id
    }

    func removeServer(id: Int64) throws {
        storage.allServers.removeAll { $0.id == id }
        if storage.currentSelectedServerId == id {
            storage.currentSelectedServerId = nil
        }
    }

    private func isValidIP(_ ip: String) -> Bool {
        let parts = ip.split(separator: ".").map(String.init)
        guard parts.count == 4 else { return false }
        for part in parts {
            guard let num = Int(part), num >= 0 && num <= 255 else { return false }
        }
        return true
    }
}

// MARK: - Routing Profiles Manager

final class RoutingProfilesManagerImpl: NSObject, RoutingProfilesManager {
    private let storage: MockStorage

    init(storage: MockStorage) {
        self.storage = storage
    }

    func addNewProfile() throws {
        let newId = (storage.allRoutingProfiles.map { $0.id }.max() ?? 0) + 1
        let newProfile = RoutingProfile(
            id: newId,
            name: "Profile \(newId)",
            defaultMode: .vpn,
            bypassRules: [],
            vpnRules: []
        )
        storage.allRoutingProfiles.append(newProfile)
    }

    func getAllProfiles() throws -> [RoutingProfile] {
        storage.allRoutingProfiles
    }

    func setDefaultRoutingMode(id: Int64, mode: RoutingMode) throws {
        if let idx = storage.allRoutingProfiles.firstIndex(where: { $0.id == id }) {
            let p = storage.allRoutingProfiles[idx]
            storage.allRoutingProfiles[idx] = RoutingProfile(
                id: p.id,
                name: p.name,
                defaultMode: mode,
                bypassRules: p.bypassRules,
                vpnRules: p.vpnRules
            )
        }
    }

    func setProfileName(id: Int64, name: String) throws {
        if let idx = storage.allRoutingProfiles.firstIndex(where: { $0.id == id }) {
            let p = storage.allRoutingProfiles[idx]
            storage.allRoutingProfiles[idx] = RoutingProfile(
                id: p.id,
                name: name,
                defaultMode: p.defaultMode,
                bypassRules: p.bypassRules,
                vpnRules: p.vpnRules
            )
        }
    }

    func setRules(id: Int64, mode: RoutingMode, rules: String) throws {
        if let idx = storage.allRoutingProfiles.firstIndex(where: { $0.id == id }) {
            let p = storage.allRoutingProfiles[idx]
            let arr = rules
                .split(separator: "\n")
                .map { String($0.trimmingCharacters(in: .whitespaces)) }

            let updated: RoutingProfile
            if mode == .bypass {
                updated = RoutingProfile(
                    id: p.id,
                    name: p.name,
                    defaultMode: p.defaultMode,
                    bypassRules: arr,
                    vpnRules: p.vpnRules
                )
            } else {
                updated = RoutingProfile(
                    id: p.id,
                    name: p.name,
                    defaultMode: p.defaultMode,
                    bypassRules: p.bypassRules,
                    vpnRules: arr
                )
            }
            storage.allRoutingProfiles[idx] = updated
        }
    }

    func removeAllRules(id: Int64) throws {
        if let idx = storage.allRoutingProfiles.firstIndex(where: { $0.id == id }) {
            let p = storage.allRoutingProfiles[idx]
            storage.allRoutingProfiles[idx] = RoutingProfile(
                id: p.id,
                name: p.name,
                defaultMode: p.defaultMode,
                bypassRules: [],
                vpnRules: []
            )
        }
    }
}