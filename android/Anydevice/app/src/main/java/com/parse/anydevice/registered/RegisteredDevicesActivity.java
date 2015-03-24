package com.parse.anydevice.registered;

import android.app.AlertDialog;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.v7.app.ActionBarActivity;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.Toolbar;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;

import com.parse.ParseQuery;
import com.parse.ParseUser;
import com.parse.anydevice.R;
import com.parse.anydevice.app.Constants;
import com.parse.anydevice.app.MainActivity;
import com.parse.anydevice.models.Installation;
import com.parse.anydevice.unregistered.UnregisteredDevicesActivity;
import com.parse.anydevice.views.EmptyStateRecyclerView;

public class RegisteredDevicesActivity extends ActionBarActivity implements RegisteredDeviceListAdapter.OnDeviceClickListener {
    private RegisteredDeviceListAdapter adapter;
    private BroadcastReceiver eventReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(final Context context, final Intent intent) {
            adapter.loadObjects();
        }
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_registered_devices);

        final Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        findViewById(R.id.device_add).setOnClickListener(new AddButtonClickListener());
        setupList();
    }

    @Override
    protected void onResume() {
        super.onResume();
        adapter.loadObjects();
        registerReceiver(eventReceiver, Constants.EVENT_INTENT_FILTER);
    }

    @Override
    protected void onPause() {
        unregisterReceiver(eventReceiver);
        super.onPause();
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.action_menu_main, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(final MenuItem item) {
        switch (item.getItemId()) {
            case R.id.action_logout: {
                showLogoutDialog();
                return true;
            }
        }
        return super.onOptionsItemSelected(item);
    }

    @Override
    public void onDeviceClicked(@NonNull final Installation installation) {
        final Intent devicePageIntent = BlinkDeviceActivity.getDeviceActivityIntent(RegisteredDevicesActivity.this, BlinkDeviceActivity.class, installation.getInstallationId());
        if (devicePageIntent != null) {
            startActivity(devicePageIntent);
        }
    }

    /**
     * Initialize recycler view with adapter and empty state
     */
    private void setupList() {
        adapter = new RegisteredDeviceListAdapter();
        adapter.setOnDeviceClickListener(this);
        final EmptyStateRecyclerView recyclerView = (EmptyStateRecyclerView) findViewById(R.id.list);
        recyclerView.setEmptyView(findViewById(R.id.empty_list));
        recyclerView.setLayoutManager(new LinearLayoutManager(this));
        recyclerView.setAdapter(adapter);
    }

    /**
     * Show dialog to confirm user wishes to logout
     */
    private void showLogoutDialog() {
        final AlertDialog dialog = new AlertDialog.Builder(this).create();
        dialog.setTitle(R.string.logout);
        dialog.setMessage(getString(R.string.logout_message));
        dialog.setCancelable(true);
        final LogoutDialogClickListener listener = new LogoutDialogClickListener();
        dialog.setButton(AlertDialog.BUTTON_POSITIVE, getString(R.string.logout), listener);
        dialog.setButton(AlertDialog.BUTTON_NEGATIVE, getString(android.R.string.cancel), listener);
        dialog.show();
    }

    private class LogoutDialogClickListener implements DialogInterface.OnClickListener {

        @Override
        public void onClick(final DialogInterface dialog, final int which) {
            if (which == AlertDialog.BUTTON_POSITIVE) {
                ParseUser.logOut();
                ParseQuery.clearAllCachedResults();

                // Open launch activity
                final Intent intent = new Intent(RegisteredDevicesActivity.this, MainActivity.class);
                intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK | Intent.FLAG_ACTIVITY_NEW_TASK);
                startActivity(intent);
            }
            dialog.dismiss();
        }
    }

    private class AddButtonClickListener implements View.OnClickListener {

        @Override
        public void onClick(final View v) {
            final Intent unregisteredDevicesIntent = new Intent(RegisteredDevicesActivity.this, UnregisteredDevicesActivity.class);
            startActivity(unregisteredDevicesIntent);
        }
    }


}
