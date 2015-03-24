package com.parse.anydevice.models;

import com.parse.ParseClassName;
import com.parse.ParseSession;
import com.parse.ParseUser;

/**
 * Represents a session used for a device. Contains a {@link ParseUser} and an {@link Installation}.
 */
@ParseClassName(UserSession.PARSE_CLASS_NAME)
public class UserSession extends ParseSession {
    public static final String PARSE_CLASS_NAME = "_Session";
    public static final String INSTALLATION_ID = "installationId";

    // Used to register subclass
    public UserSession() {}
}
