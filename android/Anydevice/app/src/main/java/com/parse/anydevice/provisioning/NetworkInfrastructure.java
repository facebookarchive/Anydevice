package com.parse.anydevice.provisioning;

/**
 * Data model representing an access point
 */
public class NetworkInfrastructure {

    private String ssid;
    private String password;
    private int security;

    public void setSsid(String ssid) {
        this.ssid = ssid;
    }

    public String getSsid() {
        return ssid;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getPassword() {
        return password;
    }

    public void setSecurity(int security) {
        this.security = security;
    }

    public int getSecurity() {
        return security;
    }
}
