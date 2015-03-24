package com.parse.anydevice.app;

import android.content.IntentFilter;

import com.parse.anydevice.BuildConfig;

import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

public class Constants {
    public static final String PARSE_APP_ID = BuildConfig.PARSE_APP_ID;
    public static final String PARSE_CLIENT_KEY = BuildConfig.PARSE_CLIENT_KEY;

    public static final String EVENT_INTENT_ACTION = "com.parse.anydevice.EVENT";
    public static final IntentFilter EVENT_INTENT_FILTER = new IntentFilter(EVENT_INTENT_ACTION);

    public static final String PLATFORM_CC3200 = "CC3200";

    private static final Map<String, String> PLATFORM_SSDID_MAP = Collections.unmodifiableMap(
            new HashMap<String, String>() {{
                put("TL04-", PLATFORM_CC3200);
            }});

    /**
     * Return true if the SSID has a prefix that represents a supported application.
     *
     * @param ssid SSID of device access point
     * @return true if SSID is supported
     * @see #PLATFORM_SSDID_MAP
     */
    public static boolean isPlatformSupportedBySSID(final String ssid) {
        final String prefix = getSSIDPrefix(ssid);
        return prefix != null && PLATFORM_SSDID_MAP.containsKey(prefix);
    }

    public static String getPlatform(final String ssid) {
        return Constants.PLATFORM_SSDID_MAP.get(getSSIDPrefix(ssid));
    }

    private static String getSSIDPrefix(final String ssid) {
        final int index = ssid.indexOf("-");
        String prefix = null;
        if (index >= 0) {
            prefix = ssid.substring(0, index + 1);
        }
        return prefix;
    }
}
