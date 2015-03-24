package com.parse.anydevice.app;

import android.app.Application;

import com.parse.Parse;
import com.parse.ParseObject;
import com.parse.anydevice.models.Event;
import com.parse.anydevice.models.InfrastructureKey;
import com.parse.anydevice.models.Installation;
import com.parse.anydevice.models.Message;
import com.parse.anydevice.models.Model;
import com.parse.anydevice.models.UserSession;

public class AnydeviceApplication extends Application {
    @Override
    public void onCreate() {
        super.onCreate();
        // Register strongly-typed subclasses
        ParseObject.registerSubclass(Installation.class);
        ParseObject.registerSubclass(Event.class);
        ParseObject.registerSubclass(Model.class);
        ParseObject.registerSubclass(Message.class);
        ParseObject.registerSubclass(UserSession.class);
        ParseObject.registerSubclass(InfrastructureKey.class);

        // Initialize Parse
        Parse.setLogLevel(Parse.LOG_LEVEL_DEBUG);
        Parse.initialize(this, Constants.PARSE_APP_ID, Constants.PARSE_CLIENT_KEY);
    }
}
