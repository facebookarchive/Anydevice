package com.parse.anydevice.provisioning;

import android.support.annotation.NonNull;
import android.support.v4.util.Pair;
import android.util.Log;

import com.parse.anydevice.app.Constants;
import com.parse.anydevice.models.Installation;
import com.parse.anydevice.models.UserSession;

import java.io.IOException;

class BoardTask implements Runnable {
    private static final String TAG = BoardTask.class.getSimpleName();
    private final NetworkInfrastructure networkInfrastructure;
    private final DeviceConfig config;
    private final ProvisioningCallback callback;
    private final String sessionToken;
    private final String installationId;

    /**
     * Task for sending data to the board about the wifi configuration, installation and Parse constants
     * @param networkInfrastructure The network configuration {@link NetworkInfrastructure}
     * @param config                The {@link DeviceConfig} (for the device name)
     * @param sessionToken          The {@link UserSession}'s token
     * @param installationId        The {@link Installation} UUID
     * @param callback              Triggered once the sending of data either succeeds or fails
     */
    public BoardTask(@NonNull final NetworkInfrastructure networkInfrastructure, @NonNull final DeviceConfig config, @NonNull final String sessionToken, @NonNull final String installationId, @NonNull final ProvisioningCallback callback) {
        this.networkInfrastructure = networkInfrastructure;
        this.config = config;
        this.sessionToken = sessionToken;
        this.installationId = installationId;
        this.callback = callback;
    }

    /**
     * Will determine what type of board it is based on SSID and the either make a POST or PUT request
     */
    @Override
    public void run() {
        final String platform = Constants.getPlatform(config.getSsid());
        switch (platform) {
            case Constants.PLATFORM_CC3200: {
                tryToPost();
                break;
            }
            default: {
                Log.d(TAG, "Not a supported platform");
                break;
            }
        }
    }

    /**
     * Sends provisioning information to the board via POST
     * <p/>
     * First creates a request using {@link Request}
     * and then executes it from {@link #executeRequest(Request)}
     */
    void tryToPost() {
        final Request request = new Request()
                .url("http://192.168.1.1:8080/parse_config.html")
                .post()
                .param("__SL_P_USA", networkInfrastructure.getSsid())
                .param("__SL_P_USB", getSecurityString())
                .param("__SL_P_USC", networkInfrastructure.getPassword())
                .param("__SL_P_USD", Constants.PARSE_APP_ID)
                .param("__SL_P_USE", Constants.PARSE_CLIENT_KEY)
                .param("__SL_P_USF", installationId)
                .param("__SL_P_USG", sessionToken)
                .param("__SL_P_USH", config.getName())
                .param("__SL_P_USZ", "Add");

        executeRequest(request);
    }

    /**
     * Makes the actual request to the board for provisioning and handles the response appropriately
     *
     * @param request The constructed request from {@link #tryToPost()}
     */
    private void executeRequest(@NonNull final Request request) {
        try {
            final Pair<Integer, String> response = request.execute();
            if (response.first == 200) {
                callback.success();
            } else {
                callback.failure();
            }
        } catch (IOException e) {
            Log.e(TAG, "Failed to send", e);
            callback.failure();
        }
    }

    /**
     * Helper to obtain the string version of the security type
     *
     * @return The security type as a string
     */
    private String getSecurityString() {
        switch (networkInfrastructure.getSecurity()) {
            case 1:
                return "1";
            case 2:
                return "2";
            default:
                return "0";
        }
    }
}
