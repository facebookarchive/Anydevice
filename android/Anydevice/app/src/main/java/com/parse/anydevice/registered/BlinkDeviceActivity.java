package com.parse.anydevice.registered;

import android.annotation.SuppressLint;
import android.app.ProgressDialog;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.support.annotation.NonNull;
import android.support.v7.widget.Toolbar;
import android.view.View;
import android.widget.RadioButton;
import android.widget.TextView;
import android.widget.Toast;

import com.parse.ParseImageView;
import com.parse.ParsePushBroadcastReceiver;
import com.parse.ParseUser;
import com.parse.anydevice.R;
import com.parse.anydevice.app.Constants;
import com.parse.anydevice.models.Event;
import com.parse.anydevice.models.Message;
import com.parse.anydevice.models.Model;

import org.json.JSONException;
import org.json.JSONObject;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Collections;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;
import java.util.concurrent.TimeUnit;

public class BlinkDeviceActivity extends BaseDeviceDetailsActivity implements View.OnClickListener {

    @SuppressLint("UseSparseArrays")
    private static final Map<Integer, String> stateMap = Collections.unmodifiableMap(new HashMap<Integer, String>(3) {{
        put(R.id.led_on, "on");
        put(R.id.led_off, "off");
        put(R.id.blink_led, "blink");
    }});

    private ParseImageView deviceImage;
    private TextView deviceName;
    private TextView deviceType;
    private TextView deviceLastSeen;
    private UpdateProgressDialog progressDialog;
    private EventReceiver eventReceiver = new EventReceiver();
    private Event lastEvent;

    @Override
    protected void onCreate(final Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_blink_device);
        setupToolbar();
        progressDialog = new UpdateProgressDialog(this);
        deviceImage = (ParseImageView) findViewById(R.id.device_img);
        deviceName = (TextView) findViewById(R.id.device_name);
        deviceType = (TextView) findViewById(R.id.device_type);
        deviceLastSeen = (TextView) findViewById(R.id.device_last_seen);

        for (Integer id : stateMap.keySet()) {
            findViewById(id).setOnClickListener(this);
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
        registerReceiver(eventReceiver, Constants.EVENT_INTENT_FILTER);
    }

    @Override
    protected void onPause() {
        progressDialog.dismiss();
        unregisterReceiver(eventReceiver);
        super.onPause();
    }

    @Override
    protected void onUserSessionLoaded() {
        final String deviceName = installation.getDeviceName();
        final Model deviceModel = installation.getModel();
        Model.putLogoIntoImageView(deviceModel, deviceImage, R.drawable.board_icon_details);
        this.deviceName.setText(deviceName);
        deviceType.setText(deviceModel.getBoardType());
        displayLastSeen();
        final TextView errorMessage = (TextView) findViewById(R.id.error);
        errorMessage.setVisibility((installation.hasRecentEvent()) ? View.INVISIBLE : View.VISIBLE);
        final Event latestEvent = installation.getLatestEvent();
        if (latestEvent != null) {
            displayEvent(latestEvent);
            errorMessage.setText(R.string.error_device_inactive_for_time);
        } else {
            errorMessage.setText(R.string.error_device_no_events);
        }
    }

    /**
     * OnClick for radio buttons (on/off/blink)
     *
     * @param view Clicked RadioButton
     */
    @Override
    public void onClick(final View view) {
        trySendMessage(stateMap.get(view.getId()));
    }

    /**
     * Initialize toolbar
     */
    private void setupToolbar() {
        final Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setHomeAsUpIndicator(R.drawable.back_arrow);
    }

    /**
     * Sends a message up to Parse to be pushed to the associated board
     *
     * @param state the current state of the LED ("on", "off", "blink")
     */
    private void trySendMessage(@NonNull final String state) {
        if (installation != null) {
            progressDialog.show();
            Message message = new Message();
            message.setInstallationId(installation.getInstallationId());
            message.putOwner(ParseUser.getCurrentUser());
            message.putValue(String.format("{\"alert\": \"%s\"}", state), Message.FORMAT_JSON);
            message.send();
        }
    }

    /**
     * Populate views for given event
     *
     * @param event {@link Event} to be displayed
     */
    private void displayEvent(final Event event) {
        findViewById(R.id.led_on).setEnabled(true);
        findViewById(R.id.led_off).setEnabled(true);
        findViewById(R.id.blink_led).setEnabled(true);
        lastEvent = event;
        displayLastSeen();
        final JSONObject value = event.getValue();
        try {
            final String type = value.getString("state");
            for (Integer id : stateMap.keySet()) {
                ((RadioButton) findViewById(id)).setChecked(stateMap.get(id).equals(type));
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    /**
     * Show last seen date in header
     */
    private void displayLastSeen() {
        final DateFormat sdf = new SimpleDateFormat("h:mm a d MMM yy", Locale.US);
        final String lastSeen;
        if (lastEvent != null && lastEvent.getCreatedAt().after(userSession.getUpdatedAt())) {
            lastSeen = sdf.format(lastEvent.getCreatedAt());
        } else {
            lastSeen = sdf.format(userSession.getUpdatedAt());
        }
        deviceLastSeen.setText(String.format(getString(R.string.last_seen), lastSeen));
    }

    private class UpdateProgressDialog extends ProgressDialog {
        private final Handler handler = new Handler();
        private final Runnable failRunnable = new Runnable() {
            @Override
            public void run() {
                Toast.makeText(getContext(), "Failed to receive update from board", Toast.LENGTH_SHORT).show();
                dismiss();
                if (lastEvent != null) {
                    displayEvent(lastEvent);
                }
            }
        };

        public UpdateProgressDialog(Context context) {
            super(context);
            setMessage("Updating...");
            setIndeterminate(true);
            setCancelable(false);
        }


        @Override
        public void show() {
            super.show();
            handler.postDelayed(failRunnable, TimeUnit.SECONDS.toMillis(10));
        }

        @Override
        public void dismiss() {
            handler.removeCallbacks(failRunnable);
            super.dismiss();
        }
    }

    private class EventReceiver extends BroadcastReceiver {

        @Override
        public void onReceive(final Context context, final Intent intent) {
            progressDialog.dismiss();
            final String data = intent.getStringExtra(ParsePushBroadcastReceiver.KEY_PUSH_DATA);
            try {
                final JSONObject dataJson = new JSONObject(data);
                final String userSessionId = dataJson.getString("userSessionId");
                if (userSession == null || !userSessionId.equals(userSession.getObjectId())) {
                    return;
                }
                // Consume the broadcast so that we don't show a notification in the status bar
                abortBroadcast();
                final Event event = Event.fromJson(dataJson.getJSONObject("event"));
                displayEvent(event);
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
    }

}
