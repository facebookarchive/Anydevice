package com.parse.anydevice.unregistered;

import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentTransaction;
import android.support.v7.app.ActionBarActivity;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.Toolbar;
import android.view.Menu;
import android.view.MenuItem;

import com.parse.anydevice.R;
import com.parse.anydevice.views.EmptyStateRecyclerView;
import com.parse.anydevice.views.UnregisteredDeviceListEmptyStateView;

import java.util.List;

/**
 * Activity for finding and provisioning available devices
 */
public class UnregisteredDevicesActivity extends ActionBarActivity implements NewDeviceListAdapter.OnDeviceAddClickListener, AccessPointDiscovery.Callback {
    private static final String ADD_DEVICE_DIALOG_TAG = "addDeviceDialog";

    private AccessPointDiscovery discovery;
    private NewDeviceListAdapter adapter;
    private UnregisteredDeviceListEmptyStateView emptyStateView;

    @Override
    protected void onCreate(final Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_unregistered_devices);
        setupToolbar();
        emptyStateView = (UnregisteredDeviceListEmptyStateView) findViewById(R.id.empty_list);
        discovery = new AccessPointDiscovery(this, this);
        adapter = new NewDeviceListAdapter();
        setupList();
        startDiscovery();
    }

    @Override
    protected void onStop() {
        if (discovery.isRunning()) {
            discovery.stop();
            emptyStateView.setupNoResultsState();
        }
        super.onStop();
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.action_menu_unregistered_devices, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(@NonNull final MenuItem item) {
        switch (item.getItemId()) {
            case android.R.id.home: {
                finish();
                return true;
            }
            case R.id.action_refresh: {
                startDiscovery();
                return true;
            }
        }
        return super.onOptionsItemSelected(item);
    }

    @Override
    public void onAddClick(@NonNull final NewDevice device) {
        showAddDeviceDialog(device);
    }

    @Override
    public void done(@NonNull final List<NewDevice> devices) {
        if (devices.isEmpty()) {
            emptyStateView.setupNoResultsState();
        } else {
            adapter.setDevices(devices);
        }
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
     * Setup list with adapter and listener
     */
    private void setupList() {
        adapter.setOnDeviceAddClickListener(this);
        final EmptyStateRecyclerView recyclerView = (EmptyStateRecyclerView) findViewById(R.id.list);
        recyclerView.setEmptyView(emptyStateView);
        recyclerView.setLayoutManager(new LinearLayoutManager(this));
        recyclerView.setAdapter(adapter);
    }

    /**
     * Start wifi scan to discover devices
     */
    private void startDiscovery() {
        adapter.clear();
        emptyStateView.setupLoadingState();
        discovery.start();
    }

    /**
     * Show dialog for provisioning the device
     *
     * @param device {@link NewDevice} to be provisioned
     */
    private void showAddDeviceDialog(final NewDevice device) {
        final Bundle args = createBundle(device);
        final FragmentTransaction ft = getSupportFragmentManager().beginTransaction();
        final Fragment prev = getSupportFragmentManager().findFragmentByTag(ADD_DEVICE_DIALOG_TAG);
        if (prev != null) {
            ft.remove(prev);
        }
        ft.addToBackStack(null);

        final AddDeviceDialogFragment fragment = new AddDeviceDialogFragment();
        fragment.setArguments(args);
        fragment.show(ft, ADD_DEVICE_DIALOG_TAG);
    }

    /**
     * Create args bundle for add device dialog fragmnet
     *
     * @param device {@link NewDevice} to show in the dialog
     *
     * @return Bundle of arguments for dialog fragment
     */
    private Bundle createBundle(final NewDevice device) {
        final Bundle args = new Bundle();
        args.putString(AddDeviceDialogFragment.ARGS_BSSID, device.getBssid());
        args.putString(AddDeviceDialogFragment.ARGS_SSID, device.getTitle());
        if (device.getModel() != null) {
            args.putString(AddDeviceDialogFragment.ARGS_APP_NAME, device.getModel().getAppName());
        }
        if (device.getBoardType() != null) {
            args.putString(AddDeviceDialogFragment.ARGS_BOARD_TYPE, device.getBoardType());
        } else {
            args.putString(AddDeviceDialogFragment.ARGS_BOARD_TYPE, getResources().getString(R.string.default_device_board_type));
        }
        return args;
    }
}
