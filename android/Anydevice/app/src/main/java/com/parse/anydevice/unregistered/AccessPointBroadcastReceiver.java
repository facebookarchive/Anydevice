package com.parse.anydevice.unregistered;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.net.wifi.ScanResult;
import android.net.wifi.WifiManager;
import android.support.annotation.NonNull;

import com.parse.FindCallback;
import com.parse.ParseException;
import com.parse.ParseQuery;
import com.parse.anydevice.app.Constants;
import com.parse.anydevice.models.Model;

import java.util.ArrayList;
import java.util.List;

class AccessPointBroadcastReceiver extends BroadcastReceiver {
    private final List<AccessPointObserver> observers = new ArrayList<>();

    public static interface AccessPointObserver {
        public void receiveResults(@NonNull final List<NewDevice> newDevices);
    }

    /**
     * When we receive a broadcast with action {@value WifiManager#SCAN_RESULTS_AVAILABLE_ACTION}
     * <p/>
     * We request board Models from Parse.com and then pass the information for processing to {@link #notifyObservers(List, List)}
     */
    @Override
    public void onReceive(final Context context, final Intent intent) {
        final WifiManager manager = (WifiManager) context.getSystemService(Context.WIFI_SERVICE);
        final List<ScanResult> results = manager.getScanResults();
        final ParseQuery<Model> query = Model.getQuery();
        query.findInBackground(new FindCallback<Model>() {
            @Override
            public void done(final List<Model> models, final ParseException e) {
                if (e == null) {
                    notifyObservers(results, models);
                }
            }
        });
    }

    /**
     * Inform observers about the access points detected and provide the board models from server
     *
     * @param results The access points {@link ScanResult} detected
     * @param models  List of {@link Model}s queried from Parse.com
     */
    private void notifyObservers(final List<ScanResult> results, final List<Model> models) {
        final List<NewDevice> newDevices = new ArrayList<>();
        for (int i = 0; i < results.size(); i++) {
            final ScanResult current = results.get(i);
            if (Constants.isPlatformSupportedBySSID(current.SSID)) {
                newDevices.add(new NewDevice(current, models));
            }
        }
        for (AccessPointObserver observer : observers) {
            observer.receiveResults(newDevices);
        }
    }

    public void addObserver(@NonNull final AccessPointObserver observer) {
        if (!observers.contains(observer)) {
            observers.add(observer);
        }
    }

    public void removeObserver(@NonNull final AccessPointObserver observer) {
        if (observers.contains(observer)) {
            observers.remove(observer);
        }
    }
}
