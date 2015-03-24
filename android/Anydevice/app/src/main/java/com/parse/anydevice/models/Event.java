package com.parse.anydevice.models;

import com.parse.ParseClassName;
import com.parse.ParseObject;

import org.json.JSONException;
import org.json.JSONObject;

import java.lang.reflect.Field;
import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;
import java.util.SimpleTimeZone;
import java.util.concurrent.TimeUnit;

/**
 * Event represents a message from the board (e.g. light on)
 */
@ParseClassName(Event.PARSE_CLASS_NAME)
public class Event extends ParseObject {
    public static final String PARSE_CLASS_NAME = "Event";
    public static final String INSTALLATION_ID = "installationId";
    public static final String VALUE = "value";
    private static final String CREATED_AT = "createdAt";

    public Event() {}

    public static Event fromJson(final JSONObject object) {
        try {
            final Event event = ParseObject.create(Event.class);
            event.put(INSTALLATION_ID, object.getString(INSTALLATION_ID));
            event.put(VALUE, new JSONObject(object.getString(VALUE)));

            event.setCreatedAt(object.getString(CREATED_AT));
            return event;
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return null;
    }

    public String getInstallationId() {
        return getString(INSTALLATION_ID);
    }

    public JSONObject getValue() {
        return getJSONObject(VALUE);
    }

    private void setCreatedAt(final String createdAtString) {
        final DateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.US);
        sdf.setTimeZone(new SimpleTimeZone(0, "GMT"));

        try {
            final Field createdAtField = ParseObject.class.getDeclaredField("createdAt");
            createdAtField.setAccessible(true);
            createdAtField.set(this, sdf.parse(createdAtString));
            createdAtField.setAccessible(false);
        } catch (NoSuchFieldException | IllegalAccessException | ParseException e) {
            e.printStackTrace();
        }
    }

    public boolean isRecent() {
        return getCreatedAt().after(new Date(new Date().getTime() - TimeUnit.DAYS.toMillis(3)));
    }
}
