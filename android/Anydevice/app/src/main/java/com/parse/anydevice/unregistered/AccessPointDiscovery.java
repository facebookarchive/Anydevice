package com.parse.anydevice.unregistered;

import android.content.Context;
import android.content.IntentFilter;
import android.net.wifi.WifiManager;
import android.support.annotation.NonNull;
import android.util.Log;

import java.util.List;

class AccessPointDiscovery implements AccessPointBroadcastReceiver.AccessPointObserver {
    private final static String TAG = AccessPointDiscovery.class.getSimpleName();

    private final Context context;
    private final WifiManager wifiManager;
    private final AccessPointBroadcastReceiver wifiReceiver;
    private final Callback callback;
    private final IntentFilter intentFilter;

    private boolean running = false;

    public interface Callback {
        void done(@NonNull final List<NewDevice> devices);
    }

    /**
     * Observer that listens for changes in the detected networks
     *
     * @param context  Used for registering receivers
     * @param callback Used for sending back the detected devices from the network scan
     */
    public AccessPointDiscovery(@NonNull final Context context, @NonNull final Callback callback) {
        this.context = context;
        this.callback = callback;
        wifiManager = (WifiManager) context.getSystemService(Context.WIFI_SERVICE);
        intentFilter = new IntentFilter(WifiManager.SCAN_RESULTS_AVAILABLE_ACTION);
        wifiReceiver = new AccessPointBroadcastReceiver();
    }

    /**
     * Begin scanning the network for access points
     * <p/>
     * If already running, it will first stop the discovery
     * <p/>
     * If wifi is not already enabled, it will enable it
     */
    public void start() {
        Log.d(TAG, "start discovery");
        if (running) {
            stop();
        }
        if (!wifiManager.isWifiEnabled()) {
            wifiManager.setWifiEnabled(true);
        }
        wifiReceiver.addObserver(this);
        context.registerReceiver(wifiReceiver, intentFilter);
        wifiManager.startScan();
        running = true;
    }

    /**
     * Stop scanning and clean up
     */
    public void stop() {
        Log.d(TAG, "stop discovery");
        if (running) {
            wifiReceiver.removeObserver(this);
            context.unregisterReceiver(wifiReceiver);
            running = false;
        }
    }

    public boolean isRunning() {
        return running;
    }

    /**
     * Used to pass back devices that have been by their access point
     *
     * @param newDevices The list of {@link NewDevice} to pass down
     */
    @Override
    public void receiveResults(@NonNull final List<NewDevice> newDevices) {
        callback.done(newDevices);
        stop();
    }
}
