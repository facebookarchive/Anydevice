package com.parse.anydevice.provisioning;

import android.annotation.TargetApi;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.net.ConnectivityManager;
import android.net.Network;
import android.net.NetworkCapabilities;
import android.net.NetworkInfo;
import android.net.NetworkRequest;
import android.net.wifi.WifiConfiguration;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.os.Build;
import android.support.annotation.NonNull;
import android.util.Log;

import java.util.List;

/**
 * Used to connect to WiFi AP provided by an embedded device
 */
class DeviceWifiConnector {
    private static final String TAG = DeviceWifiConnector.class.getName();
    private static final IntentFilter NETWORK_STATE_CHANGED_FILTER = new IntentFilter();

    static {
        NETWORK_STATE_CHANGED_FILTER.addAction(WifiManager.NETWORK_STATE_CHANGED_ACTION);
    }

    private final Context context;
    private final WifiManager wifiManager;
    private final BroadcastReceiver networkChangedReceiver = new NetworkChangedReceiver();
    private final ConnectivityManager connectivityManager;
    private ConnectivityManager.NetworkCallback networkCallback;
    private Ap previous, desired;
    private Callback callback;

    public interface Callback {
        public abstract void success();
    }

    public DeviceWifiConnector(@NonNull final Context context) {
        this.context = context.getApplicationContext();
        wifiManager = (WifiManager) context.getSystemService(Context.WIFI_SERVICE);
        connectivityManager = (ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE);
    }

    /**
     * Adds the embedded device's WiFi configuration to Android's WiFi manager.
     * Then attempts to connect to that access point.
     *
     * @param bssid     MAC address of the board's access point
     * @param ssid      Access point name
     * @param callback  Triggers success when the desired network is connected
     */
    public void attemptToConnect(@NonNull final String bssid, @NonNull final String ssid, @NonNull final Callback callback) {
        this.callback = callback;
        context.registerReceiver(networkChangedReceiver, NETWORK_STATE_CHANGED_FILTER);
        WifiInfo previousConnection = wifiManager.getConnectionInfo();
        previous = new Ap(previousConnection.getSSID(), previousConnection.getBSSID(), previousConnection.getNetworkId());

        final WifiConfiguration config = createDeviceWifiConfiguration(bssid, ssid);
        int desiredApId = wifiManager.addNetwork(config);
        desired = new Ap(ssid, bssid, desiredApId);

        wifiManager.disconnect();
        wifiManager.enableNetwork(desired.apId, true);
        wifiManager.reconnect();

    }

    /**
     * Helper to build the device wifi configuration
     */
    private WifiConfiguration createDeviceWifiConfiguration(final String bssid, final String ssid) {
        final WifiConfiguration config = new WifiConfiguration();
        config.BSSID = bssid;
        config.SSID = String.format("\"%s\"", ssid);
        config.priority = getMaxWifiPriority(wifiManager) + 1;
        config.allowedKeyManagement.set(WifiConfiguration.KeyMgmt.NONE);
        config.allowedGroupCiphers.set(WifiConfiguration.GroupCipher.TKIP);
        config.allowedAuthAlgorithms.set(WifiConfiguration.AuthAlgorithm.OPEN);
        config.status = WifiConfiguration.Status.ENABLED;
        return config;
    }

    /**
     * Remove the board network from saved networks and disconnect.
     * Then re-enable and reconnect to the previous network.
     */
    @TargetApi(Build.VERSION_CODES.LOLLIPOP)
    public void disconnect() {
        context.unregisterReceiver(networkChangedReceiver);
        callback = null;
        if (previous != null && desired != null) {
            if (wifiManager.disconnect()) {
                Log.i(TAG, "successfully disconnecting from '" + desired.ssid + "'");
            } else {
                Log.e(TAG, "failed to disconnect from '" + desired.ssid + "'");
            }

            wifiManager.removeNetwork(desired.apId);
            wifiManager.enableNetwork(previous.apId, true);
            wifiManager.reconnect();

            previous = null;
            desired = null;

            // On Lollipop cancel the network request, so we don't make extra
            // attempts to call the device when we disconnect from the device AP
            // and reconnect to the primary phone wifi
            if (Build.VERSION.SDK_INT == Build.VERSION_CODES.LOLLIPOP) {
                ConnectivityManager.setProcessDefaultNetwork(null);
                if (networkCallback != null) {
                    connectivityManager.unregisterNetworkCallback(networkCallback);
                }
            }
            networkCallback = null;
        } else {
            Log.d(TAG, "Disconnect called, but never called attemptToConnect");
        }
    }

    private class NetworkChangedReceiver extends BroadcastReceiver {

        @Override
        public void onReceive(final Context context, final Intent intent) {
            if (WifiManager.NETWORK_STATE_CHANGED_ACTION.equals(intent.getAction())) {
                NetworkInfo networkInfo = intent.getParcelableExtra(WifiManager.EXTRA_NETWORK_INFO);
                WifiInfo info = DeviceWifiConnector.this.wifiManager.getConnectionInfo();

                // Checks that you're connected to the desired network
                if (networkInfo.isConnected() && info.getBSSID() != null) {
                    final String ssid = info.getSSID().replaceAll("\"", "");
                    final String bssid = info.getBSSID();
                    Log.i(TAG, "Connected to '" + ssid + "' @ " + bssid);
                    if (previous != null && !ssid.equals(previous.ssid)) {
                        if (bssid.equals(desired.bssid)) {
                            onSuccessfulConnection();
                        }
                    }
                }
            }
        }
    }

    /**
     * We've successfully connected to the board
     *
     * For API {@value Build.VERSION_CODES#LOLLIPOP}, we do special setup for connecting to a board
     * that has no internet connection itself
     */
    @TargetApi(Build.VERSION_CODES.LOLLIPOP)
    private void onSuccessfulConnection() {
        // On Lollipop the OS routes network requests through mobile data
        // when phone is attached to a wifi that doesn't have Internet connection
        // We use the ConnectivityManager to force bind all requests from our process
        // to the device wifi
        if (Build.VERSION.SDK_INT == Build.VERSION_CODES.LOLLIPOP) {
            final NetworkRequest request = new NetworkRequest.Builder()
                    .addTransportType(NetworkCapabilities.TRANSPORT_WIFI)
                    .build();
            networkCallback = new ConnectivityManager.NetworkCallback() {
                @Override
                public void onAvailable(Network network) {
                    ConnectivityManager.setProcessDefaultNetwork(network);
                    notifyAndClear();
                }
            };
            connectivityManager.requestNetwork(request, networkCallback);
        } else {
            notifyAndClear();
        }
    }

    /**
     * Trigger the callback to say we're successfully connected now, and remove the callback to
     * prevent multiple callbacks
     */
    private void notifyAndClear() {
        if (callback != null) {
            callback.success();
            callback = null;
        }
    }

    /**
     * Figure out what the highest priority network in the network list is and return that priority
     */
    private static int getMaxWifiPriority(@NonNull final WifiManager wifiManager) {
        final List<WifiConfiguration> configurations = wifiManager.getConfiguredNetworks();
        int maxPriority = 0;
        for (WifiConfiguration config : configurations) {
            if (config.priority > maxPriority) {
                maxPriority = config.priority;
            }
        }
        return maxPriority;
    }

    /**
     * User for storing access point information
     */
    private static class Ap {
        final String ssid, bssid;
        final int apId;

        Ap(final String ssid, final String bssid, int apId) {
            this.ssid = ssid;
            this.bssid = bssid;
            this.apId = apId;
        }
    }
}
