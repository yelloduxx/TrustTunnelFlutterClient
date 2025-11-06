// plugins/vpn_plugin/android/src/main/kotlin/com/adguard/trusttunnel/vpn_plugin/NativeVpnImpl.kt
package com.adguard.trusttunnel.vpn_plugin

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.Log
import com.adguard.trusttunnel.StateNotifier
import com.adguard.trusttunnel.VpnService
import io.flutter.plugin.common.EventChannel

class NativeVpnImpl(
    private val appContext: Context
) : EventChannel.StreamHandler, StateNotifier {

    private var events: EventChannel.EventSink? = null
    private var currentState = VpnManagerState.DISCONNECTED
    private val main = Handler(Looper.getMainLooper())

    init {
        VpnService.startNetworkManager(appContext)
    }

    fun startPrepared(ctx: Context, config: String) {
        Log.i("VPN_PLUGIN", "startPrepared()")
        VpnService.start(ctx, config)
    }

    fun stop() {
        Log.i("VPN_PLUGIN", "stop()")
        VpnService.stop(appContext)
    }

    fun getCurrentState(): VpnManagerState = currentState

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        Log.i("VPN_PLUGIN", "onListen() -> subscribe state notifier")
        this.events = events
        try {
            VpnService.setStateNotifier(this) 
        } catch (t: Throwable) {
            Log.w("VPN_PLUGIN", "setStateNotifier failed", t)
        }

        postEvent(currentState.ordinal)
    }

    override fun onCancel(arguments: Any?) {
        Log.i("VPN_PLUGIN", "onCancel() -> unsubscribe")
        try {
    events = null
        } catch (t: Throwable) {
            Log.w("VPN_PLUGIN", "clearStateNotifier failed", t)
        }
        events = null
    }

    override fun onStateChanged(state: Int) {
        Log.i("VPN_PLUGIN", "onStateChanged($state)")
        currentState = VpnManagerState.entries[state]
        postEvent(state)
    }

    private fun postEvent(value: Any) {
        if (Looper.myLooper() == Looper.getMainLooper()) {
            events?.success(value)
        } else {
            main.post { events?.success(value) }
        }
    }
}