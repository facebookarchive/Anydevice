package com.parse.anydevice.registered;

import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.support.annotation.NonNull;
import android.support.v7.app.ActionBarActivity;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.Toast;

import com.parse.DeleteCallback;
import com.parse.GetCallback;
import com.parse.ParseException;
import com.parse.ParseQuery;
import com.parse.anydevice.R;
import com.parse.anydevice.models.Installation;
import com.parse.anydevice.models.UserSession;

/**
 * Base Activity for device detail screens.
 * <p/>
 * Devices are identified by their {@link Installation} and {@link UserSession} which references an Installation UUID.
 */
public abstract class BaseDeviceDetailsActivity extends ActionBarActivity {
    private static final String TAG = BaseDeviceDetailsActivity.class.getSimpleName();
    private static final String INSTALLATION_ID = "installationId";

    protected UserSession userSession;
    protected Installation installation;

    /**
     * Create intent to open an implementation of a device details page
     *
     * @param context
     * @param clazz             Class of the implementation
     * @param installationId    The UUID of the {@link Installation}
     *
     * @return Intent for launching activity
     */
    public static Intent getDeviceActivityIntent(final Context context, final Class<? extends BaseDeviceDetailsActivity> clazz, @NonNull final String installationId) {
        final Intent intent = new Intent(context, clazz);
        intent.putExtra(INSTALLATION_ID, installationId);
        return intent;
    }

    @Override
    protected void onResume() {
        super.onResume();
        loadInstallation(getIntent().getStringExtra(INSTALLATION_ID));
    }

    @Override
    protected void onNewIntent(final Intent intent) {
        super.onNewIntent(intent);
        setIntent(intent);
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.action_menu_device_details, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {
            case android.R.id.home: {
                finish();
                return true;
            }
            case R.id.delete_device: {
                showDeleteDialog();
                return true;
            }
        }

        return super.onOptionsItemSelected(item);
    }

    /**
     * Query to load installation based on UUID
     *
     * @param installationId    Which {@link Installation} we're looking for
     */
    private void loadInstallation(final String installationId) {
        if (installationId != null && !installationId.isEmpty()) {
            final ParseQuery<Installation> query = ParseQuery.getQuery(Installation.class);
            query.setCachePolicy(ParseQuery.CachePolicy.CACHE_THEN_NETWORK);
            query.include(Installation.MODEL);
            query.include(Installation.LATEST_EVENT);
            query.whereEqualTo(Installation.INSTALLATION_ID, installationId);
            query.getFirstInBackground(new InstallationGetCallback());
        } else {
            finish();
        }
    }

    /**
     * Creates and shows dialog allowing the user to cancel or proceed with deletion
     */
    private void showDeleteDialog() {
        final AlertDialog dialog = new AlertDialog.Builder(this).create();
        dialog.setTitle(R.string.remove_device);
        dialog.setMessage(getString(R.string.remove_device_message));
        dialog.setCancelable(true);
        final DialogOnClickListener listener = new DialogOnClickListener();
        dialog.setButton(AlertDialog.BUTTON_POSITIVE, getString(R.string.remove), listener);
        dialog.setButton(AlertDialog.BUTTON_NEGATIVE, getString(android.R.string.cancel), listener);
        dialog.show();
    }

    /**
     * Delete the {@link UserSession} and show a progress dialog. Finish the activity when complete.
     */
    private void deleteUserSession() {
        if (userSession != null) {
            final ProgressDialog dialog = new ProgressDialog(this);
            dialog.setIndeterminate(true);
            dialog.setCancelable(false);
            dialog.setMessage(getString(R.string.delete_user_session_message));
            dialog.show();
            userSession.deleteInBackground(new DeleteCallback() {
                @Override
                public void done(ParseException e) {
                    dialog.hide();
                    if (e == null) {
                        Toast.makeText(BaseDeviceDetailsActivity.this, "Successfully deleted user session", Toast.LENGTH_SHORT).show();
                        dialog.dismiss();
                        finish();
                    } else {
                        Toast.makeText(BaseDeviceDetailsActivity.this, "Failed to delete user session", Toast.LENGTH_SHORT).show();
                        Log.e(TAG, "Error deleting user session", e);
                    }
                }
            });
        }
    }

    /**
     * Used for passing down the {@link UserSession} and device information
     *  */
    protected abstract void onUserSessionLoaded();


    private class InstallationGetCallback implements GetCallback<Installation> {

        /**
         * Callback when installation is retrieved from Parse.
         * If installation fails to load for anything other than a cache miss, the activity is finished.
         *
         * @param returnedInstallation  {@link Installation} coming from cache or server
         * @param e                     {@link ParseException} for retrieve call
         */
        @Override
        public void done(final Installation returnedInstallation, final ParseException e) {
            if (e == null) {
                installation = returnedInstallation;
                final ParseQuery<UserSession> query = ParseQuery.getQuery(UserSession.class);
                query.setCachePolicy(ParseQuery.CachePolicy.CACHE_THEN_NETWORK);
                query.whereEqualTo(UserSession.INSTALLATION_ID, installation.getInstallationId());
                query.getFirstInBackground(new UserSessionGetCallback());
            } else if (e.getCode() == ParseException.CACHE_MISS) {
                Log.w(TAG, e.getLocalizedMessage());
            } else {
                Log.e(TAG, e.getLocalizedMessage());
                finish();
            }
        }
    }

    private class UserSessionGetCallback implements GetCallback<UserSession> {

        /**
         * Callback when user session has been retrieved from Parse.
         * If the session fails to load for anything other than a cache miss, the activity is finished.
         *
         * @param returnedUserSession {@link UserSession} coming from cache or server
         * @param e                   {@link ParseException} for retrieve call
         */
        @Override
        public void done(final UserSession returnedUserSession, final ParseException e) {
            if (e == null) {
                userSession = returnedUserSession;
                onUserSessionLoaded();
            } else if (e.getCode() == ParseException.CACHE_MISS) {
                Log.w(TAG, e.getLocalizedMessage());
            } else {
                Log.e(TAG, e.getLocalizedMessage());
                finish();
            }
        }
    }

    private class DialogOnClickListener implements DialogInterface.OnClickListener {

        @Override
        public void onClick(final DialogInterface dialog, final int which) {
            if (which == AlertDialog.BUTTON_POSITIVE) {
                deleteUserSession();
            }
            dialog.dismiss();
        }
    }
}
