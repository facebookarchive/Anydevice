package com.parse.anydevice.provisioning;

import android.content.Context;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.Looper;
import android.support.annotation.NonNull;
import android.widget.Toast;

import com.parse.ParseException;
import com.parse.SaveCallback;
import com.parse.anydevice.models.Installation;
import com.parse.anydevice.models.UserSession;

import java.util.UUID;

/**
 * Provisions devices with the following steps:
 * 1. Create UserSession for device
 * 2. Connect to device as Access Point
 * 3. Send generated Installation UUID and WiFi connection data to device & reconnect to WiFi
 * 4. Wait for event from the board (over Parse.com cloud)
 * 5. Failure: Close progress spinner and go back to new device list with error
 * OR
 * Success: Close progress spinner and go back to registered device list
 */
public class ProvisioningDispatcher {

    private final Context context;
    private final Handler mainHandler = new Handler(Looper.getMainLooper());
    private final Handler backgroundHandler;
    private final HandlerThread handlerThread;
    private ProvisioningCallback listener;
    private DeviceConfig config;
    private NetworkInfrastructure networkInfrastructure;
    private ConnectTask connectTask;

    public ProvisioningDispatcher(Context context) {
        this.context = context;
        handlerThread = new HandlerThread("provision");
        handlerThread.start();
        backgroundHandler = new Handler(handlerThread.getLooper());
    }

    /**
     * Kicks off the provisioning process with {@link #registerWithParse()}
     *
     * @param config                {@link DeviceConfig}
     * @param networkInfrastructure The wifi configuration ({@link NetworkInfrastructure})
     * @param listener              Callback for when done provisioning
     */
    public void beginProvisioning(@NonNull final DeviceConfig config, @NonNull final NetworkInfrastructure networkInfrastructure, @NonNull final ProvisioningCallback listener) {
        this.listener = listener;
        this.config = config;
        this.networkInfrastructure = networkInfrastructure;
        registerWithParse();
    }

    /**
     * Stage 1 of provisioning:
     * <p/>
     * Creates {@link UserSession} on server
     * Calls stage 2 ({@link #provision(UserSession, String)}) on success
     */
    private void registerWithParse() {
        final UserSession userSession = new UserSession();
        userSession.saveInBackground(new SaveCallback() {
            @Override
            public void done(final ParseException e) {
                if (e == null) {
                    provision(userSession, UUID.randomUUID().toString());
                } else {
                    provisionComplete(false);
                }
            }
        });
    }

    /**
     * Stage 2 of provisioning:
     * <p/>
     * Connects to the board
     * Calls stage 3 ({@link #sendInfoToDevice(UserSession, String)}) on connected or timeout
     * If failure to connect, we clean up the user session
     *
     * @param userSession       The {@link UserSession} we created
     * @param installationId    The UUID of the {@link Installation}
     */
    private void provision(@NonNull final UserSession userSession, @NonNull final String installationId) {
        connectTask = new ConnectTask(context);
        connectTask.connect(config, new ProvisioningCallback() {
            @Override
            public void success() {
                sendInfoToDevice(userSession, installationId);
            }

            @Override
            public void failure() {
                // We need to clean up the user session that was created earlier
                userSession.deleteInBackground();
                provisionComplete(false);
            }
        });
    }

    /**
     * Stage 3 of provisioning:
     * <p/>
     * Sends data to the board
     * Disconnects after response received
     * Dismisses listener when successful
     * Calls step 4 ({@link #waitForEvent(String)}) when info successfully sent
     * If failure to send information, we cleanup the user session
     *
     * @param userSession       The {@link UserSession} we created
     * @param installationId    The UUID of the {@link Installation}
     */
    private void sendInfoToDevice(@NonNull final UserSession userSession, @NonNull final String installationId) {
        final BoardTask boardTask = new BoardTask(networkInfrastructure, config, userSession.getSessionToken(), installationId, new ProvisioningCallback() {

            @Override
            public void success() {
                connectTask.disconnect();
                waitForEvent(userSession.getObjectId());
            }

            @Override
            public void failure() {
                connectTask.disconnect();
                // We need to clean up the user session that we created earlier
                userSession.deleteInBackground();
                provisionComplete(false);
            }
        });
        backgroundHandler.post(boardTask);
    }

    /**
     * Stage 4 of provisioning:
     * <p/>
     * Waits to receive first event from board (board is off)
     * Calls stage 5 ({@link #provisionComplete(boolean)}) when either timeout hit or event received
     * (because the UI will reflect the correct state)
     *
     * @param userSessionId The {@link UserSession} object id of the board
     */
    private void waitForEvent(@NonNull final String userSessionId) {
        final WaitForEventTask task = new WaitForEventTask(context, userSessionId, new ProvisioningCallback() {
            @Override
            public void success() {
                provisionComplete(true);
            }

            @Override
            public void failure() {
                // If the event has not been received the board might just be slow
                // Here we follow the same flow as success, but the user will see a '!'
                // This indicates that the device has not sent an event
                provisionComplete(true);
            }
        });
        task.waitForEvent();
    }

    /**
     * Stage 5 of provisioning:
     * <p/>
     * Dismisses the listener
     * Cleans up the handler thread
     *
     * @param isSuccess Whether an event was received before the timeout or not
     */
    private void provisionComplete(final boolean isSuccess) {
        mainHandler.post(new Runnable() {
            @Override
            public void run() {
                handlerThread.quit();
                if (isSuccess) {
                    listener.success();
                } else {
                    listener.failure();
                    Toast.makeText(context, "Failed to provision device", Toast.LENGTH_LONG).show();
                }
            }
        });
    }

}
