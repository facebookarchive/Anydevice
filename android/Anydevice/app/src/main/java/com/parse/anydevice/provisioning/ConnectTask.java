package com.parse.anydevice.provisioning;

import android.annotation.TargetApi;
import android.content.Context;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.support.annotation.NonNull;

import java.util.concurrent.TimeUnit;

class ConnectTask {
    private final DeviceWifiConnector deviceWifiConnector;
    private final Handler handler = new Handler(Looper.getMainLooper());
    private final Runnable timeoutRunnable = new TimeoutRunnable();
    private ProvisioningCallback callback;

    public ConnectTask(@NonNull Context context) {
        deviceWifiConnector = new DeviceWifiConnector(context);
    }

    /**
     * Try to connect to the board at given BSSID & SSID
     * Sets a timeout of 30 seconds before it gives up trying to connect to the board
     *
     * @param config    {@link DeviceConfig} that contains the data for the BSSID & SSID
     * @param callback  The callback that is triggered on success or timeout
     */
    @TargetApi(Build.VERSION_CODES.LOLLIPOP)
    public void connect(@NonNull final DeviceConfig config, @NonNull final ProvisioningCallback callback) {
        this.callback = callback;
        deviceWifiConnector.attemptToConnect(config.getBssid(), config.getSsid(), new ConnectionCallback());
        handler.postDelayed(timeoutRunnable, TimeUnit.SECONDS.toMillis(30));
    }

    /**
     * Called from outside the class once all data has been sent to the board
     * @see DeviceWifiConnector
     */
    public void disconnect() {
        deviceWifiConnector.disconnect();
    }

    private class ConnectionCallback implements DeviceWifiConnector.Callback {
        /**
         * We've successfully connected to the board and should kill the timeout and notify about success
         */
        @Override
        public void success() {
            handler.removeCallbacks(timeoutRunnable);
            callback.success();
        }
    }

    private class TimeoutRunnable implements Runnable {
        /**
         * We've hit the timeout and need to cleanup and notify about failure
         */
        @Override
        public void run() {
            deviceWifiConnector.disconnect();
            callback.failure();
        }
    }
}


