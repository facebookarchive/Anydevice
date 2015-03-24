package com.parse.anydevice.models;

import com.parse.ParseClassName;
import com.parse.ParseObject;
import com.parse.ParseQuery;

import java.util.concurrent.TimeUnit;

@ParseClassName(InfrastructureKey.PARSE_CLASS_NAME)
public class InfrastructureKey extends ParseObject {
    public static final String PARSE_CLASS_NAME = "InfrastructureKey";
    public static final String SSID = "ssid";
    public static final String BSSID = "bssid";
    public static final String KEY = "key";
    public static final String SECURITY = "security";

    public InfrastructureKey(){}

    public String getSsid() {
        return getString(SSID);
    }

    public void setSsid(final String ssid) {
        put(SSID, ssid);
    }

    public String getBssid() {
        return getString(BSSID);
    }

    public void setBssid(final String bssid) {
        put(BSSID, bssid);
    }

    public String getKey() {
        return getString(KEY);
    }

    public void setKey(final String key) {
        put(KEY, key);
    }

    public int getSecurity() {
        return getInt(SECURITY);
    }

    public void setSecurity(final int security) {
        put(SECURITY, security);
    }

    /**
     * Helper to create a query with a cache
     *
     * @return InfrastructureKey query
     */
    public static ParseQuery<InfrastructureKey> getQuery() {
        final ParseQuery<InfrastructureKey> query = ParseQuery.getQuery(InfrastructureKey.class);
        query.setMaxCacheAge(TimeUnit.DAYS.toMillis(30));
        query.setCachePolicy(ParseQuery.CachePolicy.CACHE_THEN_NETWORK);
        return query;
    }
}
