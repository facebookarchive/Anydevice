package com.parse.anydevice.provisioning;

import com.parse.anydevice.models.Model;

/**
 * Represents an embedded device by application {@link Model} and wifi network
 */
public class DeviceConfig {

    private String name;
    private String bssid;
    private String ssid;
    private Model model;

    public void setName(final String name) {
        this.name = name;
    }

    public String getName() {
        return name;
    }

    public void setSsid(final String ssid) {
        this.ssid = ssid;
    }

    public String getSsid() {
        return ssid;
    }

    public void setBssid(final String bssid) {
        this.bssid = bssid;
    }

    public String getBssid() {
        return bssid;
    }

    public void setModel(final Model model) {
        this.model = model;
    }

    public Model getModel() {
        return model;
    }
}
