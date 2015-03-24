package com.parse.anydevice.views;

import android.content.Context;
import android.util.AttributeSet;
import android.view.View;

import com.parse.anydevice.R;

/**
 * Empty state view for list of devices available for provisioning
 */
public class UnregisteredDeviceListEmptyStateView extends DeviceListEmptyStateView {
    private static final int layoutRes = R.layout.layout_empty_state_unregistered;

    public UnregisteredDeviceListEmptyStateView(final Context context) {
        super(context, layoutRes);
    }

    public UnregisteredDeviceListEmptyStateView(final Context context, final AttributeSet attrs) {
        super(context, attrs, layoutRes);
    }

    public UnregisteredDeviceListEmptyStateView(final Context context, final AttributeSet attrs, final int defStyleAttr) {
        super(context, attrs, defStyleAttr, layoutRes);
    }

    @Override
    protected void setupInitialState() {
        setupNoResultsState();
    }

    /**
     * Show 'no results' view
     */
    public void setupNoResultsState() {
        progressBar.setVisibility(View.INVISIBLE);
        primaryText.setText(R.string.empty_unregistered_device_list);
        secondaryText.setText(R.string.empty_unregistered_device_list_secondary);
    }

    /**
     * Show loading view
     */
    public void setupLoadingState() {
        progressBar.setVisibility(View.VISIBLE);
        primaryText.setText(R.string.searching_for_devices);
        secondaryText.setText(R.string.one_moment_please);
    }
}
