package com.parse.anydevice.provisioning;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Handler;
import android.os.Looper;
import android.support.annotation.NonNull;

import com.parse.ParsePushBroadcastReceiver;
import com.parse.anydevice.app.Constants;
import com.parse.anydevice.models.UserSession;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.concurrent.TimeUnit;

class WaitForEventTask {
    private final Context context;
    private final String userSessionId;
    private final Handler handler = new Handler(Looper.getMainLooper());
    private final EventReceiver receiver = new EventReceiver();
    private final ProvisioningCallback callback;
    private final Runnable timeoutRunnable = new Runnable() {
        @Override
        public void run() {
            done(false);
        }
    };

    /**
     * Task that will wait for an event from the server that says the board is properly connected
     * (the board's current state)
     *
     * @param context       The context to register/unregister the receiver from
     * @param userSessionId The {@link UserSession} used for checking if the event received is the one we want
     * @param callback      For notifying the {@link ProvisioningDispatcher}
     */
    public WaitForEventTask(@NonNull final Context context, @NonNull final String userSessionId, @NonNull final ProvisioningCallback callback) {
        this.context = context;
        this.userSessionId = userSessionId;
        this.callback = callback;
    }

    private class EventReceiver extends BroadcastReceiver {
        /**
         * When we receive a push event, check that it matches the user session we created
         * If so, we need to stop the broadcast from propagating and call {@link #done(boolean)}
         */
        @Override
        public void onReceive(final Context context, final Intent intent) {
            final String data = intent.getStringExtra(ParsePushBroadcastReceiver.KEY_PUSH_DATA);
            try {
                final JSONObject dataJson = new JSONObject(data);
                final String sessionId = dataJson.getString("userSessionId");
                if (userSessionId.equals(sessionId)) {
                    abortBroadcast();
                    done(true);
                }
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
    }

    /**
     * Starts a 1 minute timeout for failure
     * Registers the event receiver
     */
    void waitForEvent() {
        handler.postDelayed(timeoutRunnable, TimeUnit.MINUTES.toMillis(1));
        context.registerReceiver(receiver, Constants.EVENT_INTENT_FILTER);
    }

    /**
     * Called when either a desired event was received or the timeout was reached
     * We unregister the receiver to prevent multiple callbacks
     *
     * @param wasEventReceived  If true, we have successfully received a response event from the board
     */
    private void done(final boolean wasEventReceived) {
        handler.removeCallbacks(timeoutRunnable);
        handler.post(new Runnable() {
            public void run() {
                // we must post the unregister otherwise the abortBroadcast doesn't work
                context.unregisterReceiver(receiver);
            }
        });
        if (wasEventReceived) {
            callback.success();
        } else {
            callback.failure();
        }
    }
}
