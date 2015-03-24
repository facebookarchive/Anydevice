package com.parse.anydevice.models;

import com.parse.ParseClassName;
import com.parse.ParseInstallation;
import com.parse.ParseUser;

/**
 * Extension of the ParseInstallation with details about the device
 */
@ParseClassName(Installation.PARSE_CLASS_NAME)
public class Installation extends ParseInstallation {
    public static final String PARSE_CLASS_NAME = "_Installation";
    public static final String INSTALLATION_ID = "installationId";
    public static final String OWNER = "owner";
    public static final String DEVICE_NAME = "deviceName";
    public static final String MODEL = "model";
    public static final String LATEST_EVENT = "latestEvent";
    public static final String DEVICE_TYPE = "deviceType";
    public static final String CHANNELS = "channels";

    public Installation() {}

    public ParseUser getOwner() {
        return (ParseUser) getParseObject(OWNER);
    }

    public void setOwner(final ParseUser owner) {
        put(OWNER, owner);
    }

    public String getDeviceName() {
        return getString(DEVICE_NAME);
    }

    public void setDeviceName(final String deviceName) {
        put(DEVICE_NAME, deviceName);
    }

    public Model getModel() {
        return (Model) getParseObject(MODEL);
    }

    public void setModel(final Model model) {
        put(MODEL, model);
    }

    public Event getLatestEvent() {
        return (Event) getParseObject(LATEST_EVENT);
    }

    public boolean hasRecentEvent() {
        return getLatestEvent() != null && getLatestEvent().isRecent();
    }

    public static Installation getCurrentInstallation() {
        return (Installation) ParseInstallation.getCurrentInstallation();
    }
}
