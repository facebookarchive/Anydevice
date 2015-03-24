package com.parse.anydevice.models;

import com.parse.ParseACL;
import com.parse.ParseClassName;
import com.parse.ParseObject;
import com.parse.ParseUser;

/**
 * Messages are used to send data to the device (e.g. turn light on)
 */
@ParseClassName(Message.PARSE_CLASS_NAME)
public class Message extends ParseObject {
    public static final String PARSE_CLASS_NAME = "Message";
    public static final String OWNER = "owner";
    public static final String FORMAT = "format";
    public static final String VALUE = "value";
    public static final String INSTALLATION_ID = "installationId";
    public static final String FORMAT_JSON = "text/json";

    public void setInstallationId(final String installationId) {
        put(INSTALLATION_ID, installationId);
    }

    public void putOwner(ParseUser owner) {
        put(OWNER, owner);
    }

    public void putValue(String data, String dataFormat) {
        put(VALUE, data);
        put(FORMAT, dataFormat);
    }

    /**
     * When the message is saved the cloud code sends a push to the device by installationId.
     * Alias for saveInBackground.
     */
    public void send() {
        // We need to set the ACL for messages to protect them from other users
        setACL(new ParseACL(ParseUser.getCurrentUser()));
        saveInBackground();
    }
}
