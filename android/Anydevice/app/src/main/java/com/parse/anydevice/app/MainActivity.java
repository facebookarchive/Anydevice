package com.parse.anydevice.app;

import android.content.Intent;
import android.os.Bundle;
import android.support.v7.app.ActionBarActivity;
import android.util.Log;

import com.parse.ParseAnalytics;
import com.parse.ParseException;
import com.parse.ParseUser;
import com.parse.SaveCallback;
import com.parse.anydevice.login.ParseLoginActivity;
import com.parse.anydevice.models.Installation;
import com.parse.anydevice.registered.RegisteredDevicesActivity;

public class MainActivity extends ActionBarActivity {

    private static final String TAG = MainActivity.class.getName();
    private static final int LOGIN_REQUEST_CODE = 1;
    private static final int LOGGED_IN_PAGE_REQUEST_CODE = 2;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        ParseAnalytics.trackAppOpenedInBackground(getIntent());

        // Login the user
        final ParseUser currentUser = ParseUser.getCurrentUser();
        if (currentUser != null && currentUser.isAuthenticated()) {
            startWithUser(currentUser);
        } else {
            navigateToLogin();
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == LOGIN_REQUEST_CODE && resultCode == RESULT_OK) {
            startWithUser(ParseUser.getCurrentUser());
        } else if (requestCode == LOGIN_REQUEST_CODE || ParseUser.getCurrentUser() != null) {
            finish();
        } else {
            navigateToLogin();
        }
    }

    private void startWithUser(final ParseUser parseUser) {
        associateUserWithInstallation(parseUser);
        navigateIntoApp();
    }

    /**
     * Associate the current installation with the current user
     *
     * @param parseUser Current {@link ParseUser}
     */
    private void associateUserWithInstallation(final ParseUser parseUser) {
        final Installation currentInstallation = Installation.getCurrentInstallation();
        if (null != currentInstallation) {
            currentInstallation.setOwner(parseUser);
            currentInstallation.saveInBackground(new SaveCallback() {
                @Override
                public void done(ParseException e) {
                    if (e == null) {
                        Log.i(TAG, "Saved phone installation");
                    } else {
                        Log.e(TAG, e.getLocalizedMessage() + ": " + e.getCode());
                    }
                }
            });
        } else {
            Log.w(TAG, "Installation object is null");
        }
    }

    private void navigateIntoApp() {
        startActivityForResult(new Intent(this, RegisteredDevicesActivity.class), LOGGED_IN_PAGE_REQUEST_CODE);
    }

    private void navigateToLogin() {
        startActivityForResult(new Intent(this, ParseLoginActivity.class), LOGIN_REQUEST_CODE);
    }

}
