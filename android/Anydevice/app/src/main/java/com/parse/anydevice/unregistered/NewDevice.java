package com.parse.anydevice.unregistered;

import android.net.wifi.ScanResult;
import android.support.annotation.NonNull;

import com.parse.anydevice.models.Model;

import java.util.List;

/**
 * Model representing a device that can be provisioned
 */
public class NewDevice {
    private final ScanResult wifiAP;

    private final String title;
    private String boardType;
    private Model model;
    private final String bssid;

    public NewDevice(@NonNull final ScanResult scanResult, @NonNull final List<Model> models) {
        wifiAP = scanResult;
        title = wifiAP.SSID;
        bssid = wifiAP.BSSID;
        setupModelName(models);
    }

    /**
     * Extract the board model name from the SSID and assign a corresponding model
     *
     * @param models List of {@link Model}s to try matching the model name against
     */
    private void setupModelName(@NonNull final List<Model> models) {
        final int first = wifiAP.SSID.indexOf("-");
        final int last = wifiAP.SSID.lastIndexOf("-");
        final String modelName = wifiAP.SSID.substring(first + 1, last);
        if (!modelName.isEmpty()) {
            for (Model foundModel : models) {
                if (modelName.equals(foundModel.getAppName())) {
                    model = foundModel;
                    boardType = model.getBoardType();
                }
            }
        }
    }

    public String getTitle() {
        return title;
    }

    public String getBoardType() {
        return boardType;
    }

    public Model getModel() {
        return model;
    }

    public String getBssid() {
        return bssid;
    }
}
