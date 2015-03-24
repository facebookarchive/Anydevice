package com.parse.anydevice.app;

import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.NotificationCompat;
import android.support.v4.app.TaskStackBuilder;
import android.util.Log;

import com.parse.ParsePushBroadcastReceiver;
import com.parse.anydevice.R;
import com.parse.anydevice.models.Installation;
import com.parse.anydevice.registered.BlinkDeviceActivity;
import com.parse.anydevice.registered.RegisteredDevicesActivity;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;

public class PushReceiver extends ParsePushBroadcastReceiver {

    private final String TAG = PushReceiver.class.getName();
    private final static Map<String, Integer> map = new HashMap<>();
    private static int notificationCount, intentCount;

    @Override
    public void onReceive(Context context, Intent intent) {
        super.onReceive(context, intent);
        switch (intent.getAction()) {
            case Constants.EVENT_INTENT_ACTION: {
                final NotificationManager nm = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
                try {
                    final JSONObject dataJson = new JSONObject(intent.getStringExtra(KEY_PUSH_DATA));
                    final String alertMessage = dataJson.getString("alert");
                    final String userSessionId = dataJson.getString("userSessionId");
                    final String installationId = dataJson.getString("installationId");

                    final Notification notification = new NotificationCompat.Builder(context)
                            .setContentTitle(alertMessage)
                            .setSmallIcon(R.drawable.anydevice)
                            .setContentIntent(createPendingIntent(context, installationId))
                            .setAutoCancel(true)
                            .build();
                    if (!map.containsKey(userSessionId)) {
                        map.put(userSessionId, ++notificationCount);
                    }

                    nm.notify(userSessionId, map.get(userSessionId), notification);
                } catch (JSONException e) {
                    Log.e(TAG, "Failed to parse JSON", e);
                }
            }
            break;
        }
    }

    /**
     * Create a pending intent to open the device detail activity.
     * Synchronized for intentCount
     *
     * @param context        Received context
     * @param installationId {@link Installation} uuid for the device
     * @return PendingIntent
     */
    private synchronized PendingIntent createPendingIntent(final Context context, final String installationId) {
        final Intent deviceActivityIntent = BlinkDeviceActivity.getDeviceActivityIntent(context, BlinkDeviceActivity.class, installationId);
        TaskStackBuilder stackBuilder = TaskStackBuilder.create(context);
        stackBuilder.addParentStack(RegisteredDevicesActivity.class);
        stackBuilder.addNextIntent(new Intent(context, RegisteredDevicesActivity.class));
        stackBuilder.addNextIntentWithParentStack(deviceActivityIntent);
        return stackBuilder.getPendingIntent(++intentCount, PendingIntent.FLAG_ONE_SHOT);
    }

    /**
     * Overrides the default behaviour to create an ordered broadcast.
     * This way an activity can cancel the broadcast and stop notifications from being shown.
     */
    @Override
    protected void onPushReceive(final Context context, final Intent intent) {
        JSONObject pushData = null;
        try {
            pushData = new JSONObject(intent.getStringExtra(KEY_PUSH_DATA));
        } catch (JSONException e) {
            Log.e(TAG, "Unexpected JSONException when receiving push data: ", e);
        }
        String action = null;
        if (pushData != null) {
            action = pushData.optString("action", null);
        }
        if (action != null) {
            final Bundle extras = intent.getExtras();
            Intent broadcastIntent = new Intent();
            broadcastIntent.putExtras(extras);
            broadcastIntent.setAction(action);
            broadcastIntent.setPackage(context.getPackageName());
            context.sendOrderedBroadcast(broadcastIntent, null);
        }
    }

}
